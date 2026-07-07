# 登录与会话管理系统 - 实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 实现登录与会话管理系统，支持多终端登录、Token版本管理、灵活登录/注销策略

**Architecture:** 在现有 Spring Boot + JWT + Redis 框架基础上扩展，新增会话管理模块和策略配置

**Tech Stack:** Spring Boot 3.5.9, JWT, Redis, MyBatis-Plus, Spring Cloud Gateway

---

## 阶段一：数据库与实体扩展

### Task 1: 创建 sys_login_strategy 表

**Files:**
- Modify: `docs/scripts/init-database.sql`

**Step 1: 添加建表语句**

在 `docs/scripts/init-database.sql` 末尾添加：

```sql
-- 登录策略表
CREATE TABLE IF NOT EXISTS sys_login_strategy (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID，0表示全局策略',
    login_policy TINYINT NOT NULL DEFAULT 3 COMMENT '登录策略: 1-单端, 2-多端, 3-同端互斥',
    logout_policy TINYINT NOT NULL DEFAULT 3 COMMENT '注销策略: 1-单端, 2-全端, 3-同端',
    allow_remember_me TINYINT NOT NULL DEFAULT 1 COMMENT '是否允许记住我: 0-否, 1-是',
    remember_me_expire_seconds INT DEFAULT 2592000 COMMENT '记住我有效期: 30天(秒)',
    offline_timeout_seconds INT DEFAULT 1800 COMMENT '离线超时时间(秒)',
    access_token_expire_seconds INT DEFAULT 7200 COMMENT 'AccessToken有效期(秒)',
    refresh_token_expire_seconds INT DEFAULT 604800 COMMENT 'RefreshToken有效期(秒)',
    is_active TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME,
    UNIQUE KEY uk_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='登录策略表';

-- 默认全局策略
INSERT INTO sys_login_strategy (tenant_id, login_policy, logout_policy, allow_remember_me, remember_me_expire_seconds, offline_timeout_seconds, access_token_expire_seconds, refresh_token_expire_seconds)
VALUES (0, 3, 3, 1, 2592000, 1800, 7200, 604800);
```

**Step 2: 验证SQL语法**
```bash
# 登录MySQL执行
mysql -u root -p psychological_scale < docs/scripts/init-database.sql
```

---

### Task 2: 创建 sys_online_session 表

**Files:**
- Modify: `docs/scripts/init-database.sql`

**Step 1: 添加建表语句**

```sql
-- 在线会话表
CREATE TABLE IF NOT EXISTS sys_online_session (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    username VARCHAR(64) NOT NULL COMMENT '用户名',
    tenant_id BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    enterprise_id BIGINT COMMENT '企业ID',
    department_id BIGINT COMMENT '部门ID',
    device_type VARCHAR(32) NOT NULL COMMENT '设备类型: web,app,miniprogram,pc',
    device_id VARCHAR(128) NOT NULL COMMENT '设备唯一标识',
    device_name VARCHAR(128) COMMENT '设备名称(可选)',
    token_version INT NOT NULL DEFAULT 1 COMMENT 'Token版本号',
    access_token VARCHAR(512) COMMENT '访问令牌(加密存储)',
    refresh_token VARCHAR(512) COMMENT '刷新令牌(加密存储)',
    client_id VARCHAR(64) COMMENT 'OAuth2客户端ID',
    login_method VARCHAR(32) COMMENT '登录方式: password,oauth2_authorization_code,oauth2_password',
    login_time DATETIME NOT NULL COMMENT '登录时间',
    last_access_time DATETIME COMMENT '最后访问时间',
    expire_time DATETIME NOT NULL COMMENT '会话过期时间',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 1-在线, 2-离线, 3-已下线, 4-被踢出',
    ip_address VARCHAR(64) COMMENT 'IP地址',
    user_agent VARCHAR(512) COMMENT 'User-Agent/客户端信息',
    remember_me TINYINT DEFAULT 0 COMMENT '是否记住我',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME,
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除',
    UNIQUE KEY uk_user_device (user_id, device_type, device_id),
    INDEX idx_user_id (user_id),
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_device_type (device_type),
    INDEX idx_status (status),
    INDEX idx_last_access_time (last_access_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='在线会话表';
```

---

### Task 3: 扩展 OAuth2AccessToken 实体

**Files:**
- Modify: `ps-core/src/main/java/com/iotsic/ps/core/entity/OAuth2AccessToken.java`

**Step 1: 添加字段**

在 `OAuth2AccessToken.java` 中添加以下字段：

```java
/**
 * 设备类型
 */
private String deviceType;

/**
 * 设备唯一标识
 */
private String deviceId;

/**
 * Token版本号
 */
private Integer tokenVersion;

/**
 * 登录时间
 */
private LocalDateTime loginTime;

/**
 * 最后访问时间
 */
private LocalDateTime lastAccessTime;

/**
 * 状态: 1-正常, 2-离线, 3-已注销, 4-被踢出
 */
private Integer status;
```

---

### Task 4: 扩展 OAuth2RefreshToken 实体

**Files:**
- Modify: `ps-core/src/main/java/com/iotsic/ps/core/entity/OAuth2RefreshToken.java`

**Step 1: 添加字段**

```java
/**
 * 设备类型
 */
private String deviceType;

/**
 * 设备唯一标识
 */
private String deviceId;

/**
 * Token版本号
 */
private Integer tokenVersion;

/**
 * 是否记住我
 */
private Boolean rememberMe;
```

---

## 阶段二：框架适配

### Task 5: 扩展 LoginUser DTO

**Files:**
- Modify: `smart-framework/smart-framework-security/src/main/java/com/iotsic/smart/framework/security/dto/LoginUser.java`

**Step 1: 添加字段**

```java
/**
 * 设备类型: web,app,miniprogram,pc
 */
private String deviceType;

/**
 * Token版本号
 */
private Integer tokenVersion;

/**
 * 是否记住我
 */
private Boolean rememberMe;
```

---

### Task 6: 扩展 RedisKeyConstants

**Files:**
- Modify: `ps-common/src/main/java/com/iotsic/ps/common/constant/RedisKeyConstants.java`

**Step 1: 添加常量**

```java
/**
 * 会话缓存 Key: userId:deviceType:deviceId
 */
String SESSION = "session:%s:%s:%s";

/**
 * 用户所有会话 Hash
 */
String USER_SESSIONS = "user:sessions:%s";

/**
 * 设备类型下所有会话 Hash
 */
String DEVICE_SESSIONS = "device:sessions:%s";
```

---

### Task 7: 调整 TokenCacheService Redis Key 结构

**Files:**
- Modify: `smart-framework/smart-framework-security/src/main/java/com/iotsic/smart/framework/security/service/TokenCacheService.java`

**Step 1: 重构缓存方法**

修改 `setCurrentUser` 方法：
```java
public void setCurrentUser(String token, LoginUser user) {
    String sessionKey = String.format("security:session:%s:%s:%s",
        user.getUserId(), user.getDeviceType(), user.getDeviceId());
    String userSessionsKey = "security:user:sessions:" + user.getUserId();
    String deviceSessionsKey = "security:device:sessions:" + user.getDeviceType();

    // 1. 缓存会话
    RedisUtils.set(sessionKey, user, Duration.ofHours(2));

    // 2. 用户会话列表
    RedisUtils.setCacheMapValue(userSessionsKey,
        user.getDeviceType() + ":" + user.getDeviceId(), user, Duration.ofHours(2));

    // 3. 设备类型会话列表
    RedisUtils.setCacheMapValue(deviceSessionsKey,
        user.getUserId() + ":" + user.getDeviceId(), user, Duration.ofHours(2));

    // 4. 预热用户权限
    warmUpUserPermissions(user.getUserId());
}
```

修改 `removeLoginUser` 方法，删除所有相关缓存。

---

### Task 8: 扩展 AuthService 登录方法

**Files:**
- Modify: `smart-system/src/main/java/com/iotsic/smart/system/service/AuthService.java`

**Step 1: 扩展 login 方法签名**

```java
@Transactional
public AuthResultDTO login(String tenantId, String username, String password,
    String loginIp, String deviceType, String deviceId, Boolean rememberMe) {
    // 1. 认证
    User user = authenticate(tenantId, username, password);

    // 2. 获取登录策略
    LoginStrategy strategy = loginStrategyService.getStrategy(tenantId);

    // 3. 根据策略处理旧会话
    sessionManager.handleExistingSessions(user.getId(), deviceType, deviceId, strategy);

    // 4. 更新登录信息
    updateUserLoginInfo(user, loginIp);

    // 5. 生成认证结果
    return generateAuthResult(user, deviceType, deviceId, rememberMe, strategy);
}
```

---

## 阶段三：业务实现

### Task 9: 创建会话管理器 SessionManager

**Files:**
- Create: `smart-system/src/main/java/com/iotsic/smart/system/manager/SessionManager.java`

**Step 1: 创建会话管理器**

```java
@Service
@RequiredArgsConstructor
public class SessionManager {

    private final OnlineSessionMapper onlineSessionMapper;
    private final TokenCacheService tokenCacheService;
    private final RedisUtils redisUtils;

    /**
     * 根据登录策略处理现有会话
     */
    public void handleExistingSessions(Long userId, String deviceType, String deviceId,
                                      LoginStrategy strategy) {
        if (strategy.getLoginPolicy() == LoginPolicy.SINGLE) {
            // 踢出用户所有会话
            kickAllSessions(userId);
        } else if (strategy.getLoginPolicy() == LoginPolicy.DEVICE_EXCLUSIVE) {
            // 踢出同deviceType的会话
            kickDeviceTypeSessions(userId, deviceType);
        }
        // MULTI 策略不处理
    }

    /**
     * 踢出指定会话
     */
    public void kickSession(Long userId, String deviceType, String deviceId) {
        // 1. 更新数据库状态
        onlineSessionMapper.kickSession(userId, deviceType, deviceId);

        // 2. 删除Redis缓存
        String sessionKey = String.format("security:session:%s:%s:%s", userId, deviceType, deviceId);
        redisUtils.delete(sessionKey);
    }

    /**
     * 踢出用户所有会话
     */
    public void kickAllSessions(Long userId) {
        // ... 实现
    }

    /**
     * 踢出同设备类型的所有会话
     */
    public void kickDeviceTypeSessions(Long userId, String deviceType) {
        // ... 实现
    }
}
```

---

### Task 10: 创建 OnlineSessionMapper

**Files:**
- Create: `smart-system/src/main/java/com/iotsic/smart/system/mapper/OnlineSessionMapper.java`

**Step 1: 创建 Mapper**

```java
@Mapper
public interface OnlineSessionMapper extends BaseMapperPlus<OnlineSessionMapper, OnlineSession> {

    @Update("UPDATE sys_online_session SET status = 4, update_time = NOW() " +
            "WHERE user_id = #{userId} AND device_type = #{deviceType} AND device_id = #{deviceId} AND deleted = 0")
    int kickSession(@Param("userId") Long userId, @Param("deviceType") String deviceType,
                    @Param("deviceId") String deviceId);
}
```

---

### Task 11: 创建会话管理 Controller

**Files:**
- Create: `smart-system/src/main/java/com/iotsic/smart/system/controller/admin/SessionAdminController.java`

**Step 1: 创建 Controller**

```java
@RestController
@RequestMapping("/api/admin/session")
@RequiredArgsConstructor
public class SessionAdminController {

    private final SessionService sessionService;

    @GetMapping("/list")
    public RestResult<PageResult<OnlineSessionVO>> list(SessionQuery query) {
        return RestResult.success(sessionService.list(query));
    }

    @PostMapping("/{id}/kick")
    public RestResult<Void> kick(@PathVariable Long id) {
        sessionService.kickSession(id);
        return RestResult.success();
    }

    @PostMapping("/user/{userId}/kick-all")
    public RestResult<Integer> kickUserAll(@PathVariable Long userId) {
        int count = sessionService.kickUserAllSessions(userId);
        return RestResult.success(count);
    }

    @PostMapping("/device-type/{deviceType}/kick-all")
    public RestResult<Integer> kickDeviceTypeAll(@PathVariable String deviceType) {
        int count = sessionService.kickDeviceTypeAllSessions(deviceType);
        return RestResult.success(count);
    }
}
```

---

### Task 12: 创建登录策略管理

**Files:**
- Create: `smart-system/src/main/java/com/iotsic/smart/system/entity/LoginStrategy.java`
- Create: `smart-system/src/main/java/com/iotsic/smart/system/mapper/LoginStrategyMapper.java`
- Create: `smart-system/src/main/java/com/iotsic/smart/system/service/LoginStrategyService.java`
- Create: `smart-system/src/main/java/com/iotsic/smart/system/controller/admin/LoginStrategyController.java`

**Step 1: 创建策略实体和服务**

```java
@Data
@TableName("sys_login_strategy")
public class LoginStrategy extends BaseEntity {
    private Long tenantId;
    private Integer loginPolicy;  // 1-单端, 2-多端, 3-同端互斥
    private Integer logoutPolicy; // 1-单端, 2-全端, 3-同端
    private Integer allowRememberMe;
    private Integer rememberMeExpireSeconds;
    private Integer offlineTimeoutSeconds;
    private Integer accessTokenExpireSeconds;
    private Integer refreshTokenExpireSeconds;
    private Integer isActive;
}
```

---

### Task 13: 创建会话在线统计接口

**Files:**
- Modify: `smart-system/src/main/java/com/iotsic/smart/system/controller/admin/SessionAdminController.java`

**Step 1: 添加统计方法**

```java
@GetMapping("/statistics")
public RestResult<SessionStatisticsVO> statistics() {
    return RestResult.success(sessionService.getStatistics());
}
```

---

## 阶段四：OAuth2 实现

### Task 14: 实现授权码模式

**Files:**
- Create: `smart-system/src/main/java/com/iotsic/smart/system/controller/OAuth2Controller.java`

**Step 1: 创建授权端点**

```java
@RestController
@RequestMapping("/oauth2")
@RequiredArgsConstructor
public class OAuth2Controller {

    @GetMapping("/authorize")
    public void authorize(@RequestParam String clientId,
                          @RequestParam String redirectUri,
                          @RequestParam String scope,
                          @RequestParam String state,
                          HttpServletResponse response) throws IOException {
        // 1. 验证clientId和redirectUri
        // 2. 生成授权码
        // 3. 跳转到redirectUri
    }

    @PostMapping("/token")
    public RestResult<OAuth2TokenVO> token(@RequestBody OAuth2TokenRequest request) {
        // 处理authorization_code和password模式
    }
}
```

---

### Task 15: 扩展 OAuth2AccessTokenRedisDAO

**Files:**
- Modify: `ps-core/src/main/java/com/iotsic/ps/core/dal/redis/oauth2/OAuth2AccessTokenRedisDAO.java`

**Step 1: 添加deviceType索引**

```java
public OAuth2AccessToken getByDevice(String deviceType, String deviceId) {
    // 根据deviceType和deviceId查询
}
```

---

## 实施顺序

| 阶段 | Task | 说明 |
|------|------|------|
| 阶段一 | 1-4 | 数据库与实体扩展 |
| 阶段二 | 5-8 | 框架适配 |
| 阶段三 | 9-13 | 业务实现 |
| 阶段四 | 14-15 | OAuth2实现 |

---

## 验证步骤

1. `mvn compile -pl smart-system -am` - 编译通过
2. 执行 SQL 脚本建表
3. 启动服务测试登录
4. 测试多端登录互踢
5. 测试管理后台会话踢出

---

*计划版本: 1.0*
*创建日期: 2026-07-07*
*作者: Ryan*
