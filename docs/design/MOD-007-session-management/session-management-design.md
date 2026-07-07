# 登录与会话管理系统 - 详细设计文档

> **文档版本**: 1.1
> **创建日期**: 2026-07-07
> **更新日期**: 2026-07-07
> **作者**: Ryan
> **状态**: 已完成

---

## 1. 模块概述

### 1.1 模块编号

**MOD-007** - 登录与会话管理模块

### 1.2 模块说明

本模块提供登录认证、会话管理、登录日志记录等功能，支持多终端登录、Token版本管理、灵活的登录/注销策略。

### 1.3 功能清单

| 功能 | 说明 | 状态 |
|------|------|------|
| 用户登录 | 用户名密码登录，支持多终端 | 已完成 |
| 用户注销 | 单端/全端注销 | 已完成 |
| Token刷新 | 支持刷新令牌 | 已完成 |
| 在线会话管理 | 查看/踢出在线会话 | 已完成 |
| 登录策略配置 | 登录/注销策略管理 | 已完成 |
| 登录日志 | 记录登录/注销/刷新Token等操作 | 新增 |

---

## 2. 菜单结构

### 2.1 菜单位置

```
系统（/system）
├── 系统设置（/system/setting）
├── 登录日志（/system/login-log）      ← 新增
├── 在线会话（/system/online-session）← 新增
└── 登录策略（/system/login-strategy）← 新增
```

### 2.2 路由配置

```typescript
// router/index.ts
{
  path: 'system/login-log',
  name: 'LoginLog',
  component: () => import('@/views/system/LoginLogList.vue'),
  meta: { title: '登录日志' }
},
{
  path: 'system/online-session',
  name: 'OnlineSession',
  component: () => import('@/views/system/OnlineSessionList.vue'),
  meta: { title: '在线会话' }
},
{
  path: 'system/login-strategy',
  name: 'LoginStrategy',
  component: () => import('@/views/system/LoginStrategy.vue'),
  meta: { title: '登录策略' }
}
```

---

## 3. 数据库设计

### 3.1 表清单

| 表名 | 说明 | 操作 |
|------|------|------|
| `sys_login_strategy` | 登录策略表 | 已存在 |
| `sys_online_session` | 在线会话表 | 已存在 |
| `sys_login_log` | 登录日志表 | 新增 |
| `sys_oauth2_access_token` | 访问令牌表 | 已存在（已扩展） |
| `sys_oauth2_refresh_token` | 刷新令牌表 | 已存在（已扩展） |

### 3.2 新增表：`sys_login_log`

```sql
CREATE TABLE `sys_login_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `log_type` tinyint NOT NULL COMMENT '日志类型：1-登录，2-注销，3-刷新Token，4-踢出',
  `trace_id` varchar(64) NOT NULL DEFAULT '' COMMENT '链路追踪编号',
  `user_id` bigint NOT NULL DEFAULT 0 COMMENT '用户编号',
  `user_type` tinyint NOT NULL DEFAULT 0 COMMENT '用户类型',
  `username` varchar(50) NOT NULL DEFAULT '' COMMENT '用户账号',
  `result` tinyint NOT NULL COMMENT '登录结果：1-成功，2-失败',
  `fail_reason` varchar(255) DEFAULT NULL COMMENT '失败原因',
  `user_ip` varchar(50) NOT NULL COMMENT '用户IP',
  `user_agent` varchar(512) NOT NULL COMMENT '浏览器UA',
  `device_type` varchar(32) DEFAULT NULL COMMENT '设备类型',
  `device_id` varchar(128) DEFAULT NULL COMMENT '设备唯一标识',
  `login_time` datetime NOT NULL COMMENT '登录时间',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_username`(`username`),
  INDEX `idx_login_time`(`login_time`),
  INDEX `idx_tenant_id`(`tenant_id`),
  INDEX `idx_log_type`(`log_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统登录日志';
```

### 3.3 字段说明

| 字段名 | 类型 | 说明 |
|--------|------|------|
| `id` | BIGINT | 主键，自增 |
| `log_type` | TINYINT | 日志类型：1-登录，2-注销，3-刷新Token，4-踢出 |
| `trace_id` | VARCHAR(64) | 链路追踪编号，用于关联请求 |
| `user_id` | BIGINT | 用户编号 |
| `user_type` | TINYINT | 用户类型 |
| `username` | VARCHAR(50) | 用户账号 |
| `result` | TINYINT | 登录结果：1-成功，2-失败 |
| `fail_reason` | VARCHAR(255) | 失败原因 |
| `user_ip` | VARCHAR(50) | 用户IP地址 |
| `user_agent` | VARCHAR(512) | 浏览器User-Agent |
| `device_type` | VARCHAR(32) | 设备类型：web, app, miniprogram, pc |
| `device_id` | VARCHAR(128) | 设备唯一标识 |
| `login_time` | DATETIME | 登录时间 |
| `tenant_id` | BIGINT | 租户编号 |
| `create_time` | DATETIME | 创建时间 |
| `update_time` | DATETIME | 更新时间 |
| `deleted` | TINYINT | 逻辑删除：0-正常，1-删除 |

### 3.4 枚举值定义

#### LogTypeEnum（登录日志类型）

```java
public enum LogTypeEnum {
    LOGIN(1, "登录"),
    LOGOUT(2, "注销"),
    REFRESH_TOKEN(3, "刷新Token"),
    KICK(4, "踢出");

    private final int code;
    private final String description;
}
```

#### LoginResultEnum（登录结果）

```java
public enum LoginResultEnum {
    SUCCESS(1, "成功"),
    FAILURE(2, "失败");

    private final int code;
    private final String description;
}
```

---

## 4. 后端设计

### 4.1 类清单

| 包路径 | 类名 | 说明 |
|--------|------|------|
| `com.iotsic.smart.system.entity` | `LoginLog.java` | 登录日志实体 |
| `com.iotsic.smart.system.entity` | `LoginStrategy.java` | 登录策略实体（已存在） |
| `com.iotsic.smart.system.entity` | `OnlineSession.java` | 在线会话实体（已存在） |
| `com.iotsic.smart.system.mapper` | `LoginLogMapper.java` | 登录日志Mapper |
| `com.iotsic.smart.system.service` | `LoginLogService.java` | 登录日志服务接口 |
| `com.iotsic.smart.system.service.impl` | `LoginLogServiceImpl.java` | 登录日志服务实现 |
| `com.iotsic.smart.system.controller.admin` | `LoginLogController.java` | 管理端接口 |

### 4.2 实体类设计

#### LoginLog.java

```java
/**
 * 登录日志实体
 *
 * @author Ryan
 * @since 2026-07-07
 */
@Data
@TableName("sys_login_log")
@EqualsAndHashCode(callSuper = true)
public class LoginLog extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 日志类型：1-登录，2-注销，3-刷新Token，4-踢出
     */
    private Integer logType;

    /**
     * 链路追踪编号
     */
    private String traceId;

    /**
     * 用户编号
     */
    private Long userId;

    /**
     * 用户类型
     */
    private Integer userType;

    /**
     * 用户账号
     */
    private String username;

    /**
     * 登录结果：1-成功，2-失败
     */
    private Integer result;

    /**
     * 失败原因
     */
    private String failReason;

    /**
     * 用户IP
     */
    private String userIp;

    /**
     * 浏览器UA
     */
    private String userAgent;

    /**
     * 设备类型
     */
    private String deviceType;

    /**
     * 设备唯一标识
     */
    private String deviceId;

    /**
     * 登录时间
     */
    private LocalDateTime loginTime;

    /**
     * 租户编号
     */
    private Long tenantId;
}
```

### 4.3 服务接口设计

#### LoginLogService.java

```java
/**
 * 登录日志服务接口
 *
 * @author Ryan
 * @since 2026-07-07
 */
public interface LoginLogService {

    /**
     * 记录登录日志
     *
     * @param logType 日志类型
     * @param userId 用户编号
     * @param userType 用户类型
     * @param username 用户账号
     * @param result 登录结果
     * @param failReason 失败原因
     * @param userIp 用户IP
     * @param userAgent 用户UA
     * @param deviceType 设备类型
     * @param deviceId 设备ID
     */
    void logLogin(Integer logType, Long userId, Integer userType, String username,
                  Integer result, String failReason, String userIp, String userAgent,
                  String deviceType, String deviceId);

    /**
     * 分页查询登录日志
     *
     * @param pageRequest 分页请求
     * @param username 用户名（模糊查询）
     * @param logType 日志类型
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 分页结果
     */
    PageResult<LoginLogVO> pageList(PageRequest pageRequest, String username,
                                     Integer logType, LocalDateTime startTime,
                                     LocalDateTime endTime);

    /**
     * 获取登录日志详情
     *
     * @param id 日志ID
     * @return 登录日志详情
     */
    LoginLogVO getDetail(Long id);
}
```

### 4.4 接口设计

#### LoginLogController.java

| 接口路径 | 方法 | 说明 | 请求参数 |
|----------|------|------|----------|
| `/api/login-log/page` | GET | 分页查询登录日志 | `page`, `pageSize`, `username`, `logType`, `startTime`, `endTime` |
| `/api/login-log/detail/{id}` | GET | 获取登录日志详情 | `id`（路径参数） |

#### SessionAdminController.java（已存在）

| 接口路径 | 方法 | 说明 | 请求参数 |
|----------|------|------|----------|
| `/api/admin/session/list` | GET | 分页查询在线会话 | `page`, `pageSize`, `userId`, `deviceType`, `status` |
| `/api/admin/session/statistics` | GET | 获取会话统计 | 无 |
| `/api/admin/session/{id}/kick` | POST | 踢出会话 | `id`（路径参数） |
| `/api/admin/session/user/{userId}/kick-all` | POST | 踢出用户全部会话 | `userId`（路径参数） |
| `/api/admin/session/device-type/{deviceType}/kick-all` | POST | 踢出设备类型全部会话 | `deviceType`（路径参数） |

#### LoginStrategyController.java

| 接口路径 | 方法 | 说明 | 请求参数 |
|----------|------|------|----------|
| `/api/admin/login-strategy/get` | GET | 获取登录策略 | 无 |
| `/api/admin/login-strategy/update` | POST | 更新登录策略 | `LoginStrategyRequest` |

### 4.5 DTO 设计

#### LoginLogVO

```java
/**
 * 登录日志响应VO
 *
 * @author Ryan
 * @since 2026-07-07
 */
@Data
public class LoginLogVO {

    /**
     * 主键ID
     */
    private Long id;

    /**
     * 日志类型：1-登录，2-注销，3-刷新Token，4-踢出
     */
    private Integer logType;

    /**
     * 日志类型描述
     */
    private String logTypeDesc;

    /**
     * 用户编号
     */
    private Long userId;

    /**
     * 用户类型
     */
    private Integer userType;

    /**
     * 用户账号
     */
    private String username;

    /**
     * 登录结果：1-成功，2-失败
     */
    private Integer result;

    /**
     * 登录结果描述
     */
    private String resultDesc;

    /**
     * 失败原因
     */
    private String failReason;

    /**
     * 用户IP
     */
    private String userIp;

    /**
     * 设备类型
     */
    private String deviceType;

    /**
     * 设备ID
     */
    private String deviceId;

    /**
     * 登录时间
     */
    private LocalDateTime loginTime;

    /**
     * 租户编号
     */
    private Long tenantId;
}
```

#### LoginLogRequest

```java
/**
 * 登录日志查询请求
 *
 * @author Ryan
 * @since 2026-07-07
 */
@Data
public class LoginLogRequest {

    /**
     * 用户名（模糊查询）
     */
    private String username;

    /**
     * 日志类型
     */
    private Integer logType;

    /**
     * 开始时间
     */
    private LocalDateTime startTime;

    /**
     * 结束时间
     */
    private LocalDateTime endTime;
}
```

---

## 5. 前端设计

### 5.1 页面清单

| 页面文件 | 路由 | 功能 |
|----------|------|------|
| `LoginLogList.vue` | `/system/login-log` | 登录日志列表 |
| `OnlineSessionList.vue` | `/system/online-session` | 在线会话列表 |
| `LoginStrategy.vue` | `/system/login-strategy` | 登录策略配置 |

### 5.2 API 接口定义

#### loginLog.ts

```typescript
import request from '@/utils/request'
import type { PageRequest, PageResult } from './user'

export interface LoginLogItem {
  id: number
  logType: number
  logTypeDesc: string
  userId: number
  userType: number
  username: string
  result: number
  resultDesc: string
  failReason: string
  userIp: string
  deviceType: string
  deviceId: string
  loginTime: string
  tenantId: number
}

export interface LoginLogRequest {
  username?: string
  logType?: number
  startTime?: string
  endTime?: string
}

export const getLoginLogPage = (params: PageRequest & LoginLogRequest) => {
  return request.get<PageResult<LoginLogItem>>('/login-log/page', { params })
}

export const getLoginLogDetail = (id: number) => {
  return request.get<LoginLogItem>(`/login-log/detail/${id}`)
}
```

#### onlineSession.ts

```typescript
import request from '@/utils/request'
import type { PageRequest, PageResult } from './user'

export interface OnlineSessionItem {
  id: number
  userId: number
  username: string
  tenantId: number
  enterpriseId: number
  departmentId: number
  deviceType: string
  deviceId: string
  deviceName: string
  loginMethod: string
  loginTime: string
  lastAccessTime: string
  expireTime: string
  status: number
  ipAddress: string
  userAgent: string
  rememberMe: number
}

export interface OnlineSessionRequest {
  userId?: number
  deviceType?: string
  status?: number
}

export const getOnlineSessionPage = (params: PageRequest & OnlineSessionRequest) => {
  return request.get<PageResult<OnlineSessionItem>>('/admin/session/list', { params })
}

export const getSessionStatistics = () => {
  return request.get<any>('/admin/session/statistics')
}

export const kickSession = (id: number) => {
  return request.post<void>(`/admin/session/${id}/kick`)
}

export const kickUserAllSessions = (userId: number) => {
  return request.post<number>(`/admin/session/user/${userId}/kick-all`)
}

export const kickDeviceTypeSessions = (deviceType: string) => {
  return request.post<number>(`/admin/session/device-type/${deviceType}/kick-all`)
}
```

#### loginStrategy.ts

```typescript
import request from '@/utils/request'

export interface LoginStrategyItem {
  id: number
  tenantId: number
  loginPolicy: number
  logoutPolicy: number
  allowRememberMe: number
  rememberMeExpireSeconds: number
  offlineTimeoutSeconds: number
  accessTokenExpireSeconds: number
  refreshTokenExpireSeconds: number
  isActive: number
}

export const getLoginStrategy = () => {
  return request.get<LoginStrategyItem>('/admin/login-strategy/get')
}

export const updateLoginStrategy = (data: Partial<LoginStrategyItem>) => {
  return request.post<void>('/admin/login-strategy/update', data)
}
```

### 5.3 页面设计

#### 5.3.1 登录日志页面（LoginLogList.vue）

**功能**：
- 分页列表展示登录日志
- 支持按用户名、日志类型、时间范围筛选
- 查看登录详情（弹窗展示）
- 支持导出功能（预留）

**页面布局**：

```
┌─────────────────────────────────────────────────────────────────┐
│  登录日志                                                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  用户名: [___________]  日志类型: [▼请选择    ]  时间: [日期] ││
│  │                                       [搜索] [重置]          ││
│  └─────────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ ID │ 用户名 │ 日志类型 │ 结果 │ IP地址 │ 设备类型 │ 登录时间 ││
│  ├─────────────────────────────────────────────────────────────┤│
│  │ 1  │ admin  │ 登录     │ 成功 │ 127... │ web      │ 2026... ││
│  │ 2  │ user   │ 注销     │ 成功 │ 192... │ app      │ 2026... ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                   总数: 100     │
│                                                   [< 1 2 3 >]   │
└─────────────────────────────────────────────────────────────────┘
```

**详情弹窗**：

```
┌─────────────────────────────────────────────────────────────────┐
│  登录详情                                           [×]          │
├─────────────────────────────────────────────────────────────────┤
│  用户账号: admin              │  用户类型: 管理员                 │
│  日志类型: 登录              │  登录结果: 成功                   │
│  用户IP: 127.0.0.1           │  登录时间: 2026-07-07 12:00:00   │
│  设备类型: web               │  设备ID: xxxxxxx                  │
│  失败原因: -                 │  User-Agent: Mozilla/5.0...       │
└─────────────────────────────────────────────────────────────────┘
```

#### 5.3.2 在线会话页面（OnlineSessionList.vue）

**功能**：
- 分页列表展示在线会话
- 显示各设备类型的在线人数统计
- 支持踢出单个会话、踢出用户全部会话、踢出设备类型全部会话
- 实时刷新（定时拉取）

**页面布局**：

```
┌─────────────────────────────────────────────────────────────────┐
│  在线会话                                    [🔄 刷新]           │
├─────────────────────────────────────────────────────────────────┤
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐                    │
│  │  web   │ │  app   │ │ 小程序 │ │  PC端  │                    │
│  │  12人  │ │  5人   │ │  8人   │ │  3人   │                    │
│  └────────┘ └────────┘ └────────┘ └────────┘                    │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ 用户名 │ 设备类型 │ 设备ID │ 登录时间 │ 最后访问 │ 状态 │ 操作│
│  ├─────────────────────────────────────────────────────────────┤│
│  │ admin  │ web     │ xxx    │ 2026... │ 2026... │ 在线 │[踢出]│
│  └─────────────────────────────────────────────────────────────┘│
│                                                   总数: 28      │
└─────────────────────────────────────────────────────────────────┘
```

#### 5.3.3 登录策略页面（LoginStrategy.vue）

**功能**：
- 查看当前登录策略配置
- 编辑登录策略（仅超级管理员）
- 预览配置变更

**页面布局**：

```
┌─────────────────────────────────────────────────────────────────┐
│  登录策略                                                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  登录策略配置                                                 ││
│  │                                                              ││
│  │  登录策略:  [○ 单端  ● 多端  ○ 同端互斥]                      ││
│  │            (单端: 只能在一个设备登录)                          ││
│  │            (多端: 可在多个设备同时登录)                        ││
│  │            (同端互斥: 同类型设备互斥)                          ││
│  │                                                              ││
│  │  注销策略:  [○ 单端  ● 全端  ○ 同端]                          ││
│  │                                                              ││
│  │  ☐ 允许记住我                                                ││
│  │    记住我有效期: [30] 天                                      ││
│  │                                                              ││
│  │  离线超时时间: [30] 分钟                                      ││
│  │  AccessToken有效期: [2] 小时                                  ││
│  │  RefreshToken有效期: [7] 天                                   ││
│  │                                                              ││
│  │                                        [保存配置]             ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## 6. 安全设计

### 6.1 权限控制

| 功能 | 所需权限 |
|------|----------|
| 查看登录日志 | `system:login-log:list` |
| 查看会话列表 | `system:session:list` |
| 踢出会话 | `system:session:kick` |
| 查看登录策略 | `system:login-strategy:list` |
| 修改登录策略 | `system:login-strategy:update` |

### 6.2 敏感信息处理

- 密码不在任何日志中记录
- `fail_reason` 字段仅记录业务失败原因，不记录系统内部错误详情
- User-Agent 字段长度限制为 512 字符

---

## 7. 性能设计

### 7.1 索引优化

`sys_login_log` 表索引：
- `idx_user_id` - 按用户ID查询
- `idx_username` - 按用户名查询（支持模糊查询）
- `idx_login_time` - 按时间范围查询
- `idx_tenant_id` - 按租户隔离查询

### 7.2 日志清理策略

- 登录日志保留 90 天（可配置）
- 超过保留期限的日志自动归档或删除
- 使用定时任务每日执行清理

---

## 8. 审计字段

所有数据库表必须包含以下审计字段：

| 字段名 | 类型 | 说明 |
|--------|------|------|
| `create_time` | DATETIME | 创建时间 |
| `create_by` | BIGINT | 创建人 |
| `update_time` | DATETIME | 更新时间 |
| `update_by` | BIGINT | 更新人 |
| `deleted` | TINYINT | 逻辑删除（0-正常，1-删除） |

---

## 9. 错误码

| 错误码 | 说明 |
|--------|------|
| `AUTH_001` | 登录失败-用户名不存在 |
| `AUTH_002` | 登录失败-密码错误 |
| `AUTH_003` | 登录失败-账户已禁用 |
| `AUTH_004` | Token无效 |
| `AUTH_005` | Token已过期 |
| `AUTH_006` | RefreshToken无效 |
| `AUTH_007` | 刷新Token失败 |
| `SESSION_001` | 会话不存在 |
| `SESSION_002` | 踢出会话失败 |
| `SESSION_003` | 无权踢出其他用户会话 |
| `STRATEGY_001` | 登录策略不存在 |
| `STRATEGY_002` | 更新登录策略失败 |
| `STRATEGY_003` | 无权修改登录策略 |

---

## 10. 配置项

### 10.1 登录策略默认值

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `login.policy` | 3 | 默认同端互斥 |
| `logout.policy` | 3 | 默认同端注销 |
| `allow.remember.me` | true | 允许记住我 |
| `remember.me.expire.seconds` | 2592000 | 30天 |
| `offline.timeout.seconds` | 1800 | 30分钟 |
| `access.token.expire.seconds` | 7200 | 2小时 |
| `refresh.token.expire.seconds` | 604800 | 7天 |

---

## 11. 测试用例

### 11.1 登录日志测试

| 用例编号 | 用例描述 | 预期结果 |
|----------|----------|----------|
| LOG_001 | 用户成功登录 | 生成登录日志，日志类型=1，结果=成功 |
| LOG_002 | 用户密码错误登录失败 | 生成登录日志，日志类型=1，结果=失败，记录失败原因 |
| LOG_003 | 用户注销 | 生成注销日志，日志类型=2 |
| LOG_004 | Token刷新 | 生成刷新日志，日志类型=3 |
| LOG_005 | 管理员踢出会话 | 生成踢出日志，日志类型=4 |
| LOG_006 | 分页查询日志 | 返回正确分页数据 |
| LOG_007 | 按时间范围查询 | 返回时间范围内的日志 |

### 11.2 在线会话测试

| 用例编号 | 用例描述 | 预期结果 |
|----------|----------|----------|
| SES_001 | 查看在线会话列表 | 显示所有在线会话 |
| SES_002 | 按设备类型筛选 | 显示指定设备类型的会话 |
| SES_003 | 踢出单个会话 | 会话状态变为已踢出 |
| SES_004 | 踢出用户全部会话 | 用户所有设备会话均被踢出 |
| SES_005 | 踢出设备类型全部会话 | 该设备类型所有会话均被踢出 |

### 11.3 登录策略测试

| 用例编号 | 用例描述 | 预期结果 |
|----------|----------|----------|
| STR_001 | 获取当前登录策略 | 返回当前配置的策略 |
| STR_002 | 修改登录策略为多端 | 保存成功，后续登录允许多端 |
| STR_003 | 修改登录策略为单端 | 保存成功，后续登录单端覆盖 |
| STR_004 | 禁用记住我功能 | 保存成功，登录页面不显示记住我选项 |

---

## 12. 附录

### 12.1 术语表

| 术语 | 说明 |
|------|------|
| Token Version | Token版本号，用于实现Token强制失效 |
| Device Type | 设备类型：web(浏览器), app(手机APP), miniprogram(小程序), pc(PC客户端) |
| Remember Me | 记住我功能，允许延长Token有效期 |
| 单端登录 | 同一用户只能在一个设备登录 |
| 多端登录 | 同一用户可以在多个设备同时登录 |
| 同端互斥 | 同一用户在同一个设备类型只能有一个会话 |

### 12.2 参考文档

- [架构设计文档](./architecture-design.md)
- [数据库设计文档](./database-design.md)
- [安全设计文档](./security-design.md)

---

*文档版本: 1.1*
*最后更新: 2026-07-07*
*维护团队: iotsic*
