# 登录与会话管理系统设计方案

> **文档版本**: 2.0
> **创建日期**: 2026-07-02
> **作者**: Ryan
> **状态**: 已适配现有框架

---

## 一、需求背景

### 1.1 项目目标

基于 Spring Boot + JWT + Redis 实现一套完整的用户登录与会话管理系统，支持：

- 多终端同时在线（web、app、小程序、PC等）
- Token 版本管理（互踢机制）
- 灵活的登录/注销策略配置
- 管理后台会话管理
- "记住我"功能
- OAuth2 认证（SSO + 密码模式）

### 1.2 术语定义

| 术语 | 定义 |
|------|------|
| 设备类型 (deviceType) | 如 web, app, miniprogram, pc |
| 设备标识 (deviceId) | 由客户端上传的设备唯一ID |
| 端 (Terminal) | deviceType + deviceId 的组合，登录的最小单位 |
| 会话 (Session) | 用户的一次登录行为，包含Token和状态信息 |
| Token版本 (tokenVersion) | 递增序号，用于识别新旧Token |

---

## 二、策略定义

### 2.1 登录策略（控制同时在线）

| 策略 | 编号 | 名称 | 说明 |
|------|------|------|------|
| 单端登录 | 1 | SINGLE | 同一用户同时只能在一个"端"登录，新登录踢旧登录 |
| 多端登录 | 2 | MULTI | 同一用户可在不同"端"同时登录，新旧共存 |
| 同端互斥 | 3 | DEVICE_EXCLUSIVE | 同一deviceType只允许单端登录，不同deviceType可共存 |

### 2.2 注销策略（控制注销范围）

| 策略 | 编号 | 名称 | 说明 |
|------|------|------|------|
| 单端注销 | 1 | SINGLE | 只注销当前端（deviceType+deviceId） |
| 全端注销 | 2 | ALL | 一端注销，全部端下线 |
| 同端注销 | 3 | DEVICE_SAME | 同deviceType的所有端都注销 |

---

## 三、数据结构设计

### 3.1 数据库表清单

| 表名 | 说明 |
|------|------|
| sys_login_strategy | 登录策略配置表 |
| sys_online_session | 在线会话表 |
| sys_oauth2_client | OAuth2客户端表（扩展） |
| sys_oauth2_access_token | 访问令牌表（扩展） |
| sys_oauth2_refresh_token | 刷新令牌表（扩展） |

### 3.2 sys_login_strategy 表

```sql
CREATE TABLE sys_login_strategy (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID，0表示全局策略',
    
    -- 登录策略配置
    login_policy TINYINT NOT NULL DEFAULT 3 COMMENT '登录策略: 1-单端, 2-多端, 3-同端互斥',
    
    -- 注销策略配置
    logout_policy TINYINT NOT NULL DEFAULT 3 COMMENT '注销策略: 1-单端, 2-全端, 3-同端',
    
    -- 记住我功能配置
    allow_remember_me TINYINT NOT NULL DEFAULT 1 COMMENT '是否允许记住我: 0-否, 1-是',
    remember_me_expire_seconds INT DEFAULT 2592000 COMMENT '记住我有效期: 30天(秒)',
    
    -- 会话配置
    offline_timeout_seconds INT DEFAULT 1800 COMMENT '离线超时时间(秒): 默认30分钟',
    
    -- Token有效期配置
    access_token_expire_seconds INT DEFAULT 7200 COMMENT 'AccessToken有效期(秒): 默认2小时',
    refresh_token_expire_seconds INT DEFAULT 604800 COMMENT 'RefreshToken有效期(秒): 默认7天',
    
    -- 状态
    is_active TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用: 0-禁用, 1-启用',
    
    -- 审计字段
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME,
    
    UNIQUE KEY uk_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='登录策略表';
```

### 3.3 sys_online_session 表

```sql
CREATE TABLE sys_online_session (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    
    -- 用户信息
    user_id BIGINT NOT NULL COMMENT '用户ID',
    username VARCHAR(64) NOT NULL COMMENT '用户名',
    tenant_id BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    enterprise_id BIGINT COMMENT '企业ID',
    department_id BIGINT COMMENT '部门ID',
    
    -- 设备信息
    device_type VARCHAR(32) NOT NULL COMMENT '设备类型: web,app,miniprogram,pc',
    device_id VARCHAR(128) NOT NULL COMMENT '设备唯一标识',
    device_name VARCHAR(128) COMMENT '设备名称(可选，用于展示)',
    
    -- Token信息
    token_version INT NOT NULL DEFAULT 1 COMMENT 'Token版本号',
    access_token VARCHAR(512) COMMENT '访问令牌(加密存储)',
    refresh_token VARCHAR(512) COMMENT '刷新令牌(加密存储)',
    
    -- OAuth2信息
    client_id VARCHAR(64) COMMENT 'OAuth2客户端ID(密码模式时使用)',
    login_method VARCHAR(32) COMMENT '登录方式: password,oauth2_authorization_code,oauth2_password',
    
    -- 时间信息
    login_time DATETIME NOT NULL COMMENT '登录时间',
    last_access_time DATETIME COMMENT '最后访问时间',
    expire_time DATETIME NOT NULL COMMENT '会话过期时间',
    
    -- 会话状态
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 1-在线, 2-离线, 3-已下线, 4-被踢出',
    
    -- 客户端信息
    ip_address VARCHAR(64) COMMENT 'IP地址',
    user_agent VARCHAR(512) COMMENT 'User-Agent/客户端信息',
    remember_me TINYINT DEFAULT 0 COMMENT '是否记住我: 0-否, 1-是',
    
    -- 审计字段
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME,
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0-正常, 1-删除',
    
    -- 索引
    UNIQUE KEY uk_user_device (user_id, device_type, device_id),
    INDEX idx_user_id (user_id),
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_enterprise_id (enterprise_id),
    INDEX idx_device_type (device_type),
    INDEX idx_status (status),
    INDEX idx_last_access_time (last_access_time),
    INDEX idx_expire_time (expire_time),
    INDEX idx_client_id (client_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='在线会话表';
```

### 3.4 sys_oauth2_access_token 表扩展

```sql
-- 现有表结构扩展字段
ALTER TABLE sys_oauth2_access_token ADD COLUMN device_type VARCHAR(32) COMMENT '设备类型';
ALTER TABLE sys_oauth2_access_token ADD COLUMN device_id VARCHAR(128) COMMENT '设备唯一标识';
ALTER TABLE sys_oauth2_access_token ADD COLUMN token_version INT DEFAULT 1 COMMENT 'Token版本号';
ALTER TABLE sys_oauth2_access_token ADD COLUMN login_time DATETIME COMMENT '登录时间';
ALTER TABLE sys_oauth2_access_token ADD COLUMN last_access_time DATETIME COMMENT '最后访问时间';
ALTER TABLE sys_oauth2_access_token ADD COLUMN status TINYINT DEFAULT 1 COMMENT '状态: 1-正常, 2-离线, 3-已注销, 4-被踢出';
```

### 3.5 sys_oauth2_client 表扩展

```sql
-- 现有表结构扩展字段
ALTER TABLE sys_oauth2_client ADD COLUMN client_type TINYINT DEFAULT 1 COMMENT '客户端类型: 1-Web应用, 2-移动App, 3-小程序, 4-第三方应用';
ALTER TABLE sys_oauth2_client ADD COLUMN allowed_grant_types VARCHAR(256) COMMENT '允许的授权类型: authorization_code,password,refresh_token';
ALTER TABLE sys_oauth2_client ADD COLUMN allowed_scopes VARCHAR(512) COMMENT '允许的权限范围: user_info,profile,orders';
ALTER TABLE sys_oauth2_client ADD COLUMN redirect_uris VARCHAR(1024) COMMENT '授权回调地址(多个逗号分隔)';
ALTER TABLE sys_oauth2_client ADD COLUMN is_public_client TINYINT DEFAULT 0 COMMENT '是否公开客户端: 0-机密客户端, 1-公开客户端';
ALTER TABLE sys_oauth2_client ADD COLUMN is_active TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用: 0-禁用, 1-启用';
```

---

## 四、框架适配说明

### 4.1 现有框架能力

| 组件 | 支持情况 | 说明 |
|------|----------|------|
| JwtTokenUtils | ✅ 已支持 | 通过 extraClaims 传入扩展参数 |
| LoginUser DTO | ⚠️ 需扩展 | 需增加 deviceType, tokenVersion, rememberMe |
| TokenCacheService | ⚠️ 需调整 | 需按 userId:deviceType:deviceId 组织 Key |
| AuthService | ⚠️ 需扩展 | 需增加 deviceType, rememberMe 参数 |
| OAuth2AccessToken | ⚠️ 需扩展 | 需增加 deviceType, tokenVersion 字段 |
| RedisKeyConstants | ⚠️ 需扩展 | 需增加会话相关 Key 常量 |

### 4.2 LoginUser DTO 扩展

```java
// 位置: smart-framework-security/.../dto/LoginUser.java

// 新增字段
private String deviceType;     // 设备类型: web,app,miniprogram,pc
private Integer tokenVersion; // Token版本号
private Boolean rememberMe;   // 是否记住我
```

### 4.3 JWT Token Claims 扩展

**AccessToken Claims**:
```json
{
  "type": "access",
  "jti": "uuid",
  "sub": "userId",
  "userId": 10001,
  "username": "admin",
  "tenantId": "001",
  "deviceType": "web",
  "deviceId": "xxx",
  "tokenVersion": 3,
  "clientId": "smart-admin"
}
```

**RefreshToken Claims**:
```json
{
  "type": "refresh",
  "jti": "uuid",
  "sub": "userId",
  "userId": 10001,
  "deviceType": "web",
  "deviceId": "xxx",
  "tokenVersion": 3,
  "rememberMe": true
}
```

### 4.4 Redis Key 结构

```
# 会话缓存 (Key = userId:deviceType:deviceId)
security:session:{userId}:{deviceType}:{deviceId}
  → JSON: {tokenVersion, accessToken, loginTime, lastAccessTime, rememberMe, status}

# 用户所有会话 Hash
security:user:sessions:{userId}
  → Hash: {deviceType:deviceId → sessionJson}

# 设备类型下所有会话 Hash
security:device.sessions:{deviceType}
  → Hash: {userId:deviceId → sessionJson}

# Token黑名单
security:blacklist:{token}
  → 1 (TTL=token剩余有效时间)
```

---

## 五、管理后台接口设计

### 5.1 会话管理

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/admin/session/list` | GET | 查询在线会话 |
| `/api/admin/session/{id}/kick` | POST | 踢出指定会话 |
| `/api/admin/session/user/{userId}/kick-all` | POST | 踢出用户全部会话 |
| `/api/admin/session/device-type/{deviceType}/kick-all` | POST | 踢出同类型设备的所有会话 |
| `/api/admin/session/batch-kick` | POST | 批量踢出 |

### 5.2 登录策略管理

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/admin/login-strategy/get` | GET | 获取登录策略 |
| `/api/admin/login-strategy/update` | PUT | 更新登录策略 |

### 5.3 在线用户统计

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/admin/online/statistics` | GET | 在线用户统计 |

### 5.4 OAuth2客户端管理

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/admin/oauth2/client/list` | GET | 查询客户端列表 |
| `/api/admin/oauth2/client/create` | POST | 创建客户端 |
| `/api/admin/oauth2/client/update` | PUT | 更新客户端 |

---

## 六、OAuth2 设计

### 6.1 授权码模式（SSO单点登录）

```
1. 第三方请求: /oauth2/authorize?client_id=xxx&redirect_uri=xxx&scope=xxx&state=xxx
2. 用户授权确认
3. 生成授权码code，有效期10分钟
4. 跳转 redirect_uri?code=xxx&state=xxx
5. 第三方用code换Token
6. 返回: {access_token, refresh_token, userId, userInfo}
```

### 6.2 密码模式（自有客户端）

```
POST /oauth2/token
Body: {grant_type=password, username, password, client_id, client_secret, deviceType, deviceId}
```

---

## 七、实施清单

### 7.1 数据库变更

- [ ] 创建 sys_login_strategy 表
- [ ] 创建 sys_online_session 表
- [ ] 扩展 sys_oauth2_access_token 表
- [ ] 扩展 sys_oauth2_client 表

### 7.2 框架适配

- [ ] 扩展 LoginUser DTO
- [ ] 扩展 JwtTokenUtils 调用
- [ ] 调整 TokenCacheService Redis Key 结构
- [ ] 扩展 AuthService 方法签名
- [ ] 扩展 RedisKeyConstants

### 7.3 业务实现

- [ ] 实现 SessionManager 会话管理器
- [ ] 实现 TokenVersionService
- [ ] 实现 LoginStrategyService
- [ ] 开发会话管理接口
- [ ] 开发策略管理接口

### 7.4 OAuth2

- [ ] 实现授权码模式
- [ ] 实现密码模式
- [ ] 开发OAuth2客户端管理

---

*文档版本: 2.0*
*最后更新: 2026-07-07*
*作者: Ryan*
