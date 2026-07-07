# 登录与会话管理系统 - 实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 实现登录日志管理功能，包括后端实体/服务/接口、前端页面和API，以及与现有AuthService的集成。

**Architecture:** 在现有Spring Boot + MyBatis-Plus + Vue3架构基础上，新增登录日志表、实体、Mapper、Service、Controller，以及前端三个页面（登录日志/在线会话/登录策略）。

**Tech Stack:** Spring Boot 3.2.2, MyBatis-Plus 3.5.5, Vue 3.4, ElementUI 2.5, TypeScript

---

## 阶段一：后端 - 数据库与枚举

### Task 1: 添加 SQL 建表脚本

**Files:**
- Modify: `docs/scripts/init-database.sql`

**Step 1: 添加 sys_login_log 建表语句**

在 `docs/scripts/init-database.sql` 末尾添加：

```sql
-- 系统登录日志表
CREATE TABLE IF NOT EXISTS `sys_login_log` (
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

**Step 2: 提交**

```bash
git add docs/scripts/init-database.sql
git commit -m "feat(db): 添加sys_login_log登录日志表"
```

---

### Task 2: 创建枚举类

**Files:**
- Create: `backend/ps-common/src/main/java/com/iotsic/ps/common/enums/LoginLogTypeEnum.java`
- Create: `backend/ps-common/src/main/java/com/iotsic/ps/common/enums/LoginResultEnum.java`

**Step 1: 创建 LoginLogTypeEnum**

```java
package com.iotsic.ps.common.enums;

/**
 * 登录日志类型枚举
 *
 * @author Ryan
 * @since 2026-07-07
 */
public enum LoginLogTypeEnum {

    LOGIN(1, "登录"),
    LOGOUT(2, "注销"),
    REFRESH_TOKEN(3, "刷新Token"),
    KICK(4, "踢出");

    private final int code;
    private final String description;

    LoginLogTypeEnum(int code, String description) {
        this.code = code;
        this.description = description;
    }

    public int getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }
}
```

**Step 2: 创建 LoginResultEnum**

```java
package com.iotsic.ps.common.enums;

/**
 * 登录结果枚举
 *
 * @author Ryan
 * @since 2026-07-07
 */
public enum LoginResultEnum {

    SUCCESS(1, "成功"),
    FAILURE(2, "失败");

    private final int code;
    private final String description;

    LoginResultEnum(int code, String description) {
        this.code = code;
        this.description = description;
    }

    public int getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }
}
```

**Step 3: 编译验证**

```bash
cd backend && mvn compile -DskipTests -pl ps-common -am
```

**Step 4: 提交**

```bash
git add ps-common/src/main/java/com/iotsic/ps/common/enums/LoginLogTypeEnum.java ps-common/src/main/java/com/iotsic/ps/common/enums/LoginResultEnum.java
git commit -m "feat(common): 新增LoginLogTypeEnum和LoginResultEnum枚举"
```

---

## 阶段二：后端 - 登录日志实体与Mapper

### Task 3: 创建登录日志实体

**Files:**
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/entity/LoginLog.java`

**Step 1: 创建 LoginLog 实体**

```java
package com.iotsic.smart.system.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.iotsic.smart.framework.mybatis.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 登录日志实体
 *
 * @author Ryan
 * @since 2026-07-07
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_login_log")
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

**Step 2: 编译验证**

```bash
cd backend && mvn compile -DskipTests -pl smart-system -am
```

**Step 3: 提交**

```bash
git add smart-system/src/main/java/com/iotsic/smart/system/entity/LoginLog.java
git commit -m "feat(system): 新增LoginLog登录日志实体"
```

---

### Task 4: 创建登录日志 Mapper

**Files:**
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/mapper/LoginLogMapper.java`

**Step 1: 创建 LoginLogMapper**

```java
package com.iotsic.smart.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.iotsic.smart.system.entity.LoginLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 登录日志Mapper
 *
 * @author Ryan
 * @since 2026-07-07
 */
@Mapper
public interface LoginLogMapper extends BaseMapper<LoginLog> {
}
```

**Step 2: 编译验证**

```bash
cd backend && mvn compile -DskipTests -pl smart-system -am
```

**Step 3: 提交**

```bash
git add smart-system/src/main/java/com/iotsic/smart/system/mapper/LoginLogMapper.java
git commit -m "feat(system): 新增LoginLogMapper"
```

---

## 阶段三：后端 - DTO与Service

### Task 5: 创建 DTO 类

**Files:**
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/dto/LoginLogVO.java`
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/dto/LoginLogCreateRequest.java`
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/dto/LoginLogRequest.java`

**Step 1: 创建 LoginLogVO**

```java
package com.iotsic.smart.system.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 登录日志响应VO
 *
 * @author Ryan
 * @since 2026-07-07
 */
@Data
public class LoginLogVO {

    private Long id;

    private Integer logType;

    private String logTypeDesc;

    private Long userId;

    private Integer userType;

    private String username;

    private Integer result;

    private String resultDesc;

    private String failReason;

    private String userIp;

    private String deviceType;

    private String deviceId;

    private LocalDateTime loginTime;

    private Long tenantId;
}
```

**Step 2: 创建 LoginLogCreateRequest**

```java
package com.iotsic.smart.system.dto;

import lombok.Data;

/**
 * 登录日志创建请求
 *
 * @author Ryan
 * @since 2026-07-07
 */
@Data
public class LoginLogCreateRequest {

    private Integer logType;

    private Long userId;

    private Integer userType;

    private String username;

    private Integer result;

    private String failReason;

    private String userIp;

    private String userAgent;

    private String deviceType;

    private String deviceId;

    private Long tenantId;
}
```

**Step 3: 创建 LoginLogRequest**

```java
package com.iotsic.smart.system.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 登录日志查询请求
 *
 * @author Ryan
 * @since 2026-07-07
 */
@Data
public class LoginLogRequest {

    private String username;

    private Integer logType;

    private LocalDateTime startTime;

    private LocalDateTime endTime;
}
```

**Step 4: 编译验证**

```bash
cd backend && mvn compile -DskipTests -pl smart-system -am
```

**Step 5: 提交**

```bash
git add smart-system/src/main/java/com/iotsic/smart/system/dto/LoginLogVO.java
git add smart-system/src/main/java/com/iotsic/smart/system/dto/LoginLogCreateRequest.java
git add smart-system/src/main/java/com/iotsic/smart/system/dto/LoginLogRequest.java
git commit -m "feat(system): 新增LoginLog相关DTO类"
```

---

### Task 6: 创建登录日志服务

**Files:**
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/service/LoginLogService.java`
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/service/impl/LoginLogServiceImpl.java`

**Step 1: 创建 LoginLogService 接口**

```java
package com.iotsic.smart.system.service;

import com.iotsic.smart.framework.common.dto.request.PageRequest;
import com.iotsic.smart.framework.common.dto.response.PageResult;
import com.iotsic.smart.system.dto.LoginLogCreateRequest;
import com.iotsic.smart.system.dto.LoginLogRequest;
import com.iotsic.smart.system.dto.LoginLogVO;

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
     * @param request 登录日志创建请求
     */
    void logLogin(LoginLogCreateRequest request);

    /**
     * 分页查询登录日志
     *
     * @param pageRequest 分页请求
     * @param request 查询条件
     * @return 分页结果
     */
    PageResult<LoginLogVO> pageList(PageRequest pageRequest, LoginLogRequest request);

    /**
     * 获取登录日志详情
     *
     * @param id 日志ID
     * @return 登录日志详情
     */
    LoginLogVO getDetail(Long id);
}
```

**Step 2: 创建 LoginLogServiceImpl 实现**

```java
package com.iotsic.smart.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.iotsic.ps.common.enums.LoginLogTypeEnum;
import com.iotsic.ps.common.enums.LoginResultEnum;
import com.iotsic.smart.framework.common.dto.request.PageRequest;
import com.iotsic.smart.framework.common.dto.response.PageResult;
import com.iotsic.smart.framework.common.exception.BusinessException;
import com.iotsic.smart.framework.common.utils.BeanUtils;
import com.iotsic.smart.system.dto.LoginLogCreateRequest;
import com.iotsic.smart.system.dto.LoginLogRequest;
import com.iotsic.smart.system.dto.LoginLogVO;
import com.iotsic.smart.system.entity.LoginLog;
import com.iotsic.smart.system.mapper.LoginLogMapper;
import com.iotsic.smart.system.service.LoginLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 登录日志服务实现
 *
 * @author Ryan
 * @since 2026-07-07
 */
@Service
@RequiredArgsConstructor
public class LoginLogServiceImpl implements LoginLogService {

    private final LoginLogMapper loginLogMapper;

    @Override
    public void logLogin(LoginLogCreateRequest request) {
        LoginLog loginLog = new LoginLog();
        loginLog.setLogType(request.getLogType());
        loginLog.setUserId(request.getUserId());
        loginLog.setUserType(request.getUserType());
        loginLog.setUsername(request.getUsername());
        loginLog.setResult(request.getResult());
        loginLog.setFailReason(request.getFailReason());
        loginLog.setUserIp(request.getUserIp());
        loginLog.setUserAgent(request.getUserAgent());
        loginLog.setDeviceType(request.getDeviceType());
        loginLog.setDeviceId(request.getDeviceId());
        loginLog.setLoginTime(LocalDateTime.now());
        loginLog.setTenantId(request.getTenantId());
        loginLogMapper.insert(loginLog);
    }

    @Override
    public PageResult<LoginLogVO> pageList(PageRequest pageRequest, LoginLogRequest request) {
        Page<LoginLog> page = new Page<>(pageRequest.getPage(), pageRequest.getPageSize());

        LambdaQueryWrapper<LoginLog> wrapper = new LambdaQueryWrapper<>();
        if (request != null) {
            if (request.getUsername() != null && !request.getUsername().isEmpty()) {
                wrapper.like(LoginLog::getUsername, request.getUsername());
            }
            if (request.getLogType() != null) {
                wrapper.eq(LoginLog::getLogType, request.getLogType());
            }
            if (request.getStartTime() != null) {
                wrapper.ge(LoginLog::getLoginTime, request.getStartTime());
            }
            if (request.getEndTime() != null) {
                wrapper.le(LoginLog::getLoginTime, request.getEndTime());
            }
        }
        wrapper.orderByDesc(LoginLog::getLoginTime);

        IPage<LoginLog> iPage = loginLogMapper.selectPage(page, wrapper);

        return PageResult.of(
                iPage.getRecords().stream().map(this::convertToVO).toList(),
                iPage.getTotal(),
                pageRequest
        );
    }

    @Override
    public LoginLogVO getDetail(Long id) {
        LoginLog loginLog = loginLogMapper.selectById(id);
        if (loginLog == null) {
            throw BusinessException.of(1300, "登录日志不存在");
        }
        return convertToVO(loginLog);
    }

    private LoginLogVO convertToVO(LoginLog loginLog) {
        LoginLogVO vo = BeanUtils.toBean(loginLog, LoginLogVO.class);

        LoginLogTypeEnum logTypeEnum = LoginLogTypeEnum.values().stream()
                .filter(e -> e.getCode().equals(loginLog.getLogType()))
                .findFirst().orElse(null);
        vo.setLogTypeDesc(logTypeEnum != null ? logTypeEnum.getDescription() : "未知");

        LoginResultEnum resultEnum = LoginResultEnum.values().stream()
                .filter(e -> e.getCode().equals(loginLog.getResult()))
                .FindFirst().orElse(null);
        vo.setResultDesc(resultEnum != null ? resultEnum.getDescription() : "未知");

        return vo;
    }
}
```

**Step 3: 修复编译错误**

如果 `LoginResultEnum.values()` 报错，修改为 `LoginResultEnum.values()`（标准写法）。

**Step 4: 编译验证**

```bash
cd backend && mvn compile -DskipTests -pl smart-system -am
```

**Step 5: 提交**

```bash
git add smart-system/src/main/java/com/iotsic/smart/system/service/LoginLogService.java
git add smart-system/src/main/java/com/iotsic/smart/system/service/impl/LoginLogServiceImpl.java
git commit -m "feat(system): 新增LoginLogService服务"
```

---

## 阶段四：后端 - Controller与集成

### Task 7: 创建登录日志 Controller

**Files:**
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/controller/admin/LoginLogController.java`

**Step 1: 创建 LoginLogController**

```java
package com.iotsic.smart.system.controller.admin;

import com.iotsic.smart.framework.common.dto.request.PageRequest;
import com.iotsic.smart.framework.common.dto.response.PageResult;
import com.iotsic.smart.framework.common.result.RestResult;
import com.iotsic.smart.system.dto.LoginLogRequest;
import com.iotsic.smart.system.dto.LoginLogVO;
import com.iotsic.smart.system.service.LoginLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 登录日志管理端接口
 *
 * @author Ryan
 * @since 2026-07-07
 */
@RestController
@RequestMapping("/api/login-log")
@RequiredArgsConstructor
public class LoginLogController {

    private final LoginLogService loginLogService;

    @GetMapping("/page")
    public RestResult<PageResult<LoginLogVO>> page(PageRequest pageRequest, LoginLogRequest request) {
        return RestResult.success(loginLogService.pageList(pageRequest, request));
    }

    @GetMapping("/detail/{id}")
    public RestResult<LoginLogVO> detail(@PathVariable Long id) {
        return RestResult.success(loginLogService.getDetail(id));
    }
}
```

**Step 2: 编译验证**

```bash
cd backend && mvn compile -DskipTests -pl smart-system -am
```

**Step 3: 提交**

```bash
git add smart-system/src/main/java/com/iotsic/smart/system/controller/admin/LoginLogController.java
git commit -m "feat(system): 新增LoginLogController管理端接口"
```

---

### Task 8: 集成登录日志到 AuthService

**Files:**
- Modify: `backend/smart-system/src/main/java/com/iotsic/smart/system/service/AuthService.java`
- Modify: `backend/smart-system/src/main/java/com/iotsic/smart/system/controller/AuthController.java`

**Step 1: 修改 AuthService 添加登录日志记录**

在 AuthService 中注入 LoginLogService，并在登录成功后调用 `loginLogService.logLogin()`。

参考代码（在 authenticate 方法成功后添加）：

```java
private final LoginLogService loginLogService;

private void recordLoginLog(Long userId, Integer userType, String username, Integer result, String failReason, String userIp, String userAgent) {
    LoginLogCreateRequest request = new LoginLogCreateRequest();
    request.setLogType(1); // 登录
    request.setUserId(userId);
    request.setUserType(userType);
    request.setUsername(username);
    request.setResult(result);
    request.setFailReason(failReason);
    request.setUserIp(userIp);
    request.setUserAgent(userAgent);
    request.setTenantId(0L);
    loginLogService.logLogin(request);
}
```

**Step 2: 修改 AuthController 传递 userAgent**

在 login 方法中获取 HttpServletRequest 的 User-Agent 头，传递给 AuthService。

**Step 3: 编译验证**

```bash
cd backend && mvn compile -DskipTests -pl smart-system -am
```

**Step 4: 提交**

```bash
git add smart-system/src/main/java/com/iotsic/smart/system/service/AuthService.java
git add smart-system/src/main/java/com/iotsic/smart/system/controller/AuthController.java
git commit -m "feat(system): 集成登录日志到AuthService"
```

---

## 阶段五：前端 - API与路由

### Task 9: 创建前端 API 文件

**Files:**
- Create: `frontend/src/api/loginLog.ts`
- Create: `frontend/src/api/onlineSession.ts`
- Create: `frontend/src/api/loginStrategy.ts`

**Step 1: 创建 loginLog.ts**

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

**Step 2: 创建 onlineSession.ts**

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

**Step 3: 创建 loginStrategy.ts**

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

**Step 4: 编译验证**

```bash
cd frontend && npm run build 2>&1 | head -50
```

**Step 5: 提交**

```bash
cd frontend && git add src/api/loginLog.ts src/api/onlineSession.ts src/api/loginStrategy.ts
git commit -m "feat(frontend): 新增会话管理相关API文件"
```

---

### Task 10: 配置前端路由

**Files:**
- Modify: `frontend/src/router/index.ts`

**Step 1: 添加路由配置**

在 system 子路由下添加：

```typescript
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

**Step 2: 编译验证**

```bash
cd frontend && npm run build 2>&1 | head -50
```

**Step 3: 提交**

```bash
git add src/router/index.ts
git commit -m "feat(frontend): 添加会话管理路由配置"
```

---

## 阶段六：前端 - 页面组件

### Task 11: 创建登录日志页面

**Files:**
- Create: `frontend/src/views/system/LoginLogList.vue`

**Step 1: 创建 LoginLogList.vue**

参考 `UserList.vue` 的风格创建登录日志列表页面，包含：
- 搜索条件：用户名、日志类型（下拉）、时间范围
- 表格展示：ID、用户名、日志类型、结果、IP、设备类型、登录时间
- 分页
- 详情弹窗（点击查看详情按钮）

```vue
<template>
  <div class="login-log-list">
    <h2 class="page-title">登录日志</h2>

    <el-card shadow="never" :body-style="{ padding: 'var(--spacing-lg)' }">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="用户名">
          <el-input v-model="searchForm.username" placeholder="请输入用户名" clearable />
        </el-form-item>
        <el-form-item label="日志类型">
          <el-select v-model="searchForm.logType" placeholder="请选择" clearable>
            <el-option label="登录" :value="1" />
            <el-option label="注销" :value="2" />
            <el-option label="刷新Token" :value="3" />
            <el-option label="踢出" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="dateRange"
            type="datetimerange"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            value-format="YYYY-MM-DD HH:mm:ss"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never" :body-style="{ padding: 'var(--spacing-lg)' }" class="mt-md">
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="logTypeDesc" label="日志类型" width="100" />
        <el-table-column prop="resultDesc" label="结果" width="80">
          <template #default="{ row }">
            <span :class="['tag', row.result === 1 ? 'tag-success' : 'tag-error']">
              {{ row.resultDesc }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="userIp" label="IP地址" width="140" />
        <el-table-column prop="deviceType" label="设备类型" width="100" />
        <el-table-column prop="loginTime" label="登录时间" width="180" />
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleViewDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        class="mt-md"
        v-model:current-page="pagination.current"
        :page-size="pagination.size"
        :total="pagination.total"
        layout="total, prev, pager, next"
        background
        @current-change="handlePageChange"
      />
    </el-card>

    <!-- 详情弹窗 -->
    <el-dialog v-model="detailVisible" title="登录详情" width="600px" destroy-on-close>
      <el-descriptions :column="2" border v-if="currentLog">
        <el-descriptions-item label="用户账号">{{ currentLog.username }}</el-descriptions-item>
        <el-descriptions-item label="日志类型">{{ currentLog.logTypeDesc }}</el-descriptions-item>
        <el-descriptions-item label="登录结果">{{ currentLog.resultDesc }}</el-descriptions-item>
        <el-descriptions-item label="用户IP">{{ currentLog.userIp }}</el-descriptions-item>
        <el-descriptions-item label="设备类型">{{ currentLog.deviceType }}</el-descriptions-item>
        <el-descriptions-item label="设备ID">{{ currentLog.deviceId }}</el-descriptions-item>
        <el-descriptions-item label="失败原因" :span="2">{{ currentLog.failReason || '-' }}</el-descriptions-item>
        <el-descriptions-item label="登录时间" :span="2">{{ currentLog.loginTime }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getLoginLogPage, getLoginLogDetail, type LoginLogItem, type LoginLogRequest } from '@/api/loginLog'

const searchForm = reactive<LoginLogRequest>({
  username: '',
  logType: undefined,
  startTime: undefined,
  endTime: undefined
})

const dateRange = ref<[string, string] | null>(null)

const pagination = reactive({
  current: 1,
  size: 10,
  total: 0
})

const tableData = ref<LoginLogItem[]>([])
const loading = ref(false)

const detailVisible = ref(false)
const currentLog = ref<LoginLogItem | null>(null)

const loadData = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.current,
      pageSize: pagination.size,
      username: searchForm.username || undefined,
      logType: searchForm.logType,
      startTime: dateRange.value?.[0],
      endTime: dateRange.value?.[1]
    }
    const data = await getLoginLogPage(params)
    tableData.value = data.list
    pagination.total = data.total
  } catch (error) {
    console.error('加载登录日志失败:', error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.current = 1
  loadData()
}

const handleReset = () => {
  searchForm.username = ''
  searchForm.logType = undefined
  dateRange.value = null
  handleSearch()
}

const handlePageChange = (page: number) => {
  pagination.current = page
  loadData()
}

const handleViewDetail = async (row: LoginLogItem) => {
  try {
    currentLog.value = await getLoginLogDetail(row.id)
    detailVisible.value = true
  } catch (error) {
    ElMessage.error('获取详情失败')
  }
}

loadData()
</script>

<style scoped>
.login-log-list {
  padding: 0;
}
.mt-md {
  margin-top: var(--spacing-md);
}
.tag-success {
  color: var(--color-success);
}
.tag-error {
  color: var(--color-danger);
}
</style>
```

**Step 2: 编译验证**

```bash
cd frontend && npm run build 2>&1 | head -50
```

**Step 3: 提交**

```bash
git add src/views/system/LoginLogList.vue
git commit -m "feat(frontend): 新增登录日志页面"
```

---

### Task 12: 创建在线会话页面

**Files:**
- Create: `frontend/src/views/system/OnlineSessionList.vue`

**Step 1: 创建 OnlineSessionList.vue**

参考设计文档中的页面布局，包含：
- 设备类型统计卡片（web/app/小程序/pc在线人数）
- 会话列表表格
- 踢出会话功能

```vue
<template>
  <div class="online-session-list">
    <h2 class="page-title">在线会话</h2>

    <!-- 设备类型统计 -->
    <el-row :gutter="16" class="statistics-row">
      <el-col :span="6">
        <el-card shadow="never">
          <div class="stat-card">
            <div class="stat-label">Web</div>
            <div class="stat-value">{{ statistics.web || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never">
          <div class="stat-card">
            <div class="stat-label">App</div>
            <div class="stat-value">{{ statistics.app || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never">
          <div class="stat-card">
            <div class="stat-label">小程序</div>
            <div class="stat-value">{{ statistics.miniprogram || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="never">
          <div class="stat-card">
            <div class="stat-label">PC端</div>
            <div class="stat-value">{{ statistics.pc || 0 }}</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" :body-style="{ padding: 'var(--spacing-lg)' }" class="mt-md">
      <div class="table-toolbar">
        <el-button type="primary" @click="handleRefresh">刷新</el-button>
      </div>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="deviceType" label="设备类型" width="100" />
        <el-table-column prop="deviceId" label="设备ID" width="180" show-overflow-tooltip />
        <el-table-column prop="loginTime" label="登录时间" width="180" />
        <el-table-column prop="lastAccessTime" label="最后访问" width="180" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <span :class="['tag', row.status === 1 ? 'tag-success' : 'tag-warning']">
              {{ row.status === 1 ? '在线' : '离线' }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="danger" link @click="handleKick(row)">踢出</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        class="mt-md"
        v-model:current-page="pagination.current"
        :page-size="pagination.size"
        :total="pagination.total"
        layout="total, prev, pager, next"
        background
        @current-change="handlePageChange"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getOnlineSessionPage, getSessionStatistics, kickSession, type OnlineSessionItem } from '@/api/onlineSession'

const pagination = reactive({
  current: 1,
  size: 10,
  total: 0
})

const tableData = ref<OnlineSessionItem[]>([])
const loading = ref(false)
const statistics = ref<Record<string, number>>({})

const loadData = async () => {
  loading.value = true
  try {
    const data = await getOnlineSessionPage({
      page: pagination.current,
      pageSize: pagination.size
    })
    tableData.value = data.list
    pagination.total = data.total
  } catch (error) {
    console.error('加载会话数据失败:', error)
  } finally {
    loading.value = false
  }
}

const loadStatistics = async () => {
  try {
    const stats = await getSessionStatistics()
    statistics.value = stats.byDeviceType || {}
  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

const handleRefresh = () => {
  loadData()
  loadStatistics()
}

const handlePageChange = (page: number) => {
  pagination.current = page
  loadData()
}

const handleKick = async (row: OnlineSessionItem) => {
  try {
    await ElMessageBox.confirm(`确定要踢出用户「${row.username}」的会话吗？`, '提示', {
      type: 'warning'
    })
    await kickSession(row.id)
    ElMessage.success('踢出成功')
    loadData()
  } catch {
    // 用户取消
  }
}

onMounted(() => {
  loadData()
  loadStatistics()
})
</script>

<style scoped>
.online-session-list {
  padding: 0;
}
.statistics-row {
  margin-bottom: var(--spacing-md);
}
.stat-card {
  text-align: center;
}
.stat-label {
  font-size: 14px;
  color: var(--text-secondary);
  margin-bottom: 8px;
}
.stat-value {
  font-size: 28px;
  font-weight: 600;
  color: var(--color-primary);
}
.mt-md {
  margin-top: var(--spacing-md);
}
.tag-success {
  color: var(--color-success);
}
.tag-warning {
  color: var(--color-warning);
}
</style>
```

**Step 2: 编译验证**

```bash
cd frontend && npm run build 2>&1 | head -50
```

**Step 3: 提交**

```bash
git add src/views/system/OnlineSessionList.vue
git commit -m "feat(frontend): 新增在线会话页面"
```

---

### Task 13: 创建登录策略页面

**Files:**
- Create: `frontend/src/views/system/LoginStrategy.vue`

**Step 1: 创建 LoginStrategy.vue**

参考设计文档中的页面布局，包含：
- 登录策略单选（单端/多端/同端互斥）
- 注销策略单选
- 记住我开关
- Token有效期配置

```vue
<template>
  <div class="login-strategy">
    <h2 class="page-title">登录策略</h2>

    <el-card shadow="never" :body-style="{ padding: 'var(--spacing-lg)' }">
      <el-form :model="form" label-width="140px">
        <el-form-item label="登录策略">
          <el-radio-group v-model="form.loginPolicy">
            <el-radio :value="1">单端登录</el-radio>
            <el-radio :value="2">多端登录</el-radio>
            <el-radio :value="3">同端互斥</el-radio>
          </el-radio-group>
          <div class="form-help">
            <span v-if="form.loginPolicy === 1">单端: 只能在一个设备登录</span>
            <span v-else-if="form.loginPolicy === 2">多端: 可在多个设备同时登录</span>
            <span v-else>同端互斥: 同类型设备只能有一个会话</span>
          </div>
        </el-form-item>

        <el-form-item label="注销策略">
          <el-radio-group v-model="form.logoutPolicy">
            <el-radio :value="1">单端注销</el-radio>
            <el-radio :value="2">全端注销</el-radio>
            <el-radio :value="3">同端注销</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="允许记住我">
          <el-switch v-model="form.allowRememberMe" :active-value="1" :inactive-value="0" />
        </el-form-item>

        <el-form-item v-if="form.allowRememberMe" label="记住我有效期">
          <el-input-number v-model="form.rememberMeDays" :min="1" :max="365" />
          <span class="ml-sm">天</span>
        </el-form-item>

        <el-form-item label="离线超时时间">
          <el-input-number v-model="form.offlineTimeoutMinutes" :min="1" :max="1440" />
          <span class="ml-sm">分钟</span>
        </el-form-item>

        <el-form-item label="AccessToken有效期">
          <el-input-number v-model="form.accessTokenHours" :min="1" :max="72" />
          <span class="ml-sm">小时</span>
        </el-form-item>

        <el-form-item label="RefreshToken有效期">
          <el-input-number v-model="form.refreshTokenDays" :min="1" :max="30" />
          <span class="ml-sm">天</span>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSave" :loading="saveLoading">保存配置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getLoginStrategy, updateLoginStrategy, type LoginStrategyItem } from '@/api/loginStrategy'

const form = reactive({
  loginPolicy: 3,
  logoutPolicy: 3,
  allowRememberMe: 1,
  rememberMeDays: 30,
  offlineTimeoutMinutes: 30,
  accessTokenHours: 2,
  refreshTokenDays: 7
})

const saveLoading = ref(false)

const loadData = async () => {
  try {
    const data = await getLoginStrategy()
    form.loginPolicy = data.loginPolicy
    form.logoutPolicy = data.logoutPolicy
    form.allowRememberMe = data.allowRememberMe
    form.rememberMeDays = Math.round((data.rememberMeExpireSeconds || 2592000) / 86400)
    form.offlineTimeoutMinutes = Math.round((data.offlineTimeoutSeconds || 1800) / 60)
    form.accessTokenHours = Math.round((data.accessTokenExpireSeconds || 7200) / 3600)
    form.refreshTokenDays = Math.round((data.refreshTokenExpireSeconds || 604800) / 86400)
  } catch (error) {
    ElMessage.error('加载登录策略失败')
  }
}

const handleSave = async () => {
  saveLoading.value = true
  try {
    await updateLoginStrategy({
      loginPolicy: form.loginPolicy,
      logoutPolicy: form.logoutPolicy,
      allowRememberMe: form.allowRememberMe,
      rememberMeExpireSeconds: form.rememberMeDays * 86400,
      offlineTimeoutSeconds: form.offlineTimeoutMinutes * 60,
      accessTokenExpireSeconds: form.accessTokenHours * 3600,
      refreshTokenExpireSeconds: form.refreshTokenDays * 86400
    })
    ElMessage.success('保存成功')
  } catch (error) {
    ElMessage.error('保存失败')
  } finally {
    saveLoading.value = false
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.login-strategy {
  padding: 0;
}
.form-help {
  font-size: 12px;
  color: var(--text-secondary);
  margin-top: 4px;
}
.ml-sm {
  margin-left: 8px;
}
</style>
```

**Step 2: 编译验证**

```bash
cd frontend && npm run build 2>&1 | head -50
```

**Step 3: 提交**

```bash
git add src/views/system/LoginStrategy.vue
git commit -m "feat(frontend): 新增登录策略页面"
```

---

## 实施顺序

| 阶段 | Task | 说明 |
|------|------|------|
| 阶段一 | 1-2 | 数据库与枚举 |
| 阶段二 | 3-4 | 实体与Mapper |
| 阶段三 | 5-6 | DTO与Service |
| 阶段四 | 7-8 | Controller与集成 |
| 阶段五 | 9-10 | 前端API与路由 |
| 阶段六 | 11-13 | 前端页面组件 |

---

## 验证步骤

1. 后端编译: `cd backend && mvn compile -DskipTests`
2. 前端编译: `cd frontend && npm run build`
3. 执行 SQL 脚本创建 `sys_login_log` 表
4. 启动后端服务测试登录日志接口
5. 启动前端服务测试页面功能

---

*计划版本: 1.0*
*创建日期: 2026-07-07*
*作者: Ryan*
