# 系统配置管理模块 - 实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 实现系统配置管理功能，包括后端接口、前端页面、数据库表及初始化数据。

**Architecture:** 采用键值对配置表 + Redis 缓存模式，前端系统设置页面对接后端 API。

**Tech Stack:** Spring Boot + MyBatis-Plus + Redis + Vue 3 + ElementUI

---

## Task 1: 创建后端实体类 SysConfig

**Files:**
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/entity/SysConfig.java`

**Step 1: 创建实体类**

```java
package com.iotsic.smart.system.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.iotsic.smart.framework.mybatis.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 系统配置实体
 *
 * @author Ryan
 * @since 2026-07-08
 */
@Data
@TableName("sys_config")
@EqualsAndHashCode(callSuper = true)
public class SysConfig extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 参数分组：basic/security/notification/email/other
     */
    private String category;

    /**
     * 参数类型：1-文本，2-数字，3-布尔，4-JSON
     */
    private Integer configType;

    /**
     * 参数名称
     */
    private String configName;

    /**
     * 参数键名
     */
    private String configKey;

    /**
     * 参数键值
     */
    private String configValue;

    /**
     * 是否可见
     */
    private Boolean visible;

    /**
     * 是否系统内置
     */
    private Boolean isSystem;

    /**
     * 备注说明
     */
    private String remark;
}
```

**Step 2: 提交代码**

```bash
cd backend && git add smart-system/src/main/java/com/iotsic/smart/system/entity/SysConfig.java && git commit -m "feat(system): 新增SysConfig系统配置实体"
```

---

## Task 2: 创建后端 Mapper

**Files:**
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/mapper/SysConfigMapper.java`

**Step 1: 创建 Mapper 接口**

```java
package com.iotsic.smart.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.iotsic.smart.system.entity.SysConfig;
import org.apache.ibatis.annotations.Mapper;

/**
 * 系统配置 Mapper
 *
 * @author Ryan
 * @since 2026-07-08
 */
@Mapper
public interface SysConfigMapper extends BaseMapper<SysConfig> {
}
```

**Step 2: 提交代码**

```bash
cd backend && git add smart-system/src/main/java/com/iotsic/smart/system/mapper/SysConfigMapper.java && git commit -m "feat(system): 新增SysConfigMapper"
```

---

## Task 3: 创建后端 DTO 类

**Files:**
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/dto/SysConfigVO.java`
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/dto/SysConfigRequest.java`

**Step 1: 创建 SysConfigVO**

```java
package com.iotsic.smart.system.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;

/**
 * 系统配置响应 VO
 *
 * @author Ryan
 * @since 2026-07-08
 */
@Data
@Schema(description = "系统配置响应")
public class SysConfigVO implements Serializable {

    @Schema(description = "配置ID")
    private Long id;

    @Schema(description = "参数分组")
    private String category;

    @Schema(description = "参数类型：1-文本，2-数字，3-布尔，4-JSON")
    private Integer configType;

    @Schema(description = "参数名称")
    private String configName;

    @Schema(description = "参数键名")
    private String configKey;

    @Schema(description = "参数键值")
    private String configValue;

    @Schema(description = "是否可见")
    private Boolean visible;

    @Schema(description = "是否系统内置")
    private Boolean isSystem;

    @Schema(description = "备注说明")
    private String remark;
}
```

**Step 2: 创建 SysConfigRequest**

```java
package com.iotsic.smart.system.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;

/**
 * 系统配置请求
 *
 * @author Ryan
 * @since 2026-07-08
 */
@Data
@Schema(description = "系统配置请求")
public class SysConfigRequest implements Serializable {

    @Schema(description = "参数分组")
    private String category;

    @Schema(description = "参数类型：1-文本，2-数字，3-布尔，4-JSON")
    private Integer configType;

    @Schema(description = "参数名称")
    private String configName;

    @Schema(description = "参数键名")
    private String configKey;

    @Schema(description = "参数键值")
    private String configValue;

    @Schema(description = "是否可见")
    private Boolean visible;

    @Schema(description = "备注说明")
    private String remark;
}
```

**Step 3: 提交代码**

```bash
cd backend && git add smart-system/src/main/java/com/iotsic/smart/system/dto/SysConfigVO.java smart-system/src/main/java/com/iotsic/smart/system/dto/SysConfigRequest.java && git commit -m "feat(system): 新增SysConfigVO和SysConfigRequest DTO"
```

---

## Task 4: 创建后端 Service

**Files:**
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/service/SysConfigService.java`
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/service/impl/SysConfigServiceImpl.java`

**Step 1: 创建 Service 接口**

```java
package com.iotsic.smart.system.service;

import com.iotsic.smart.system.dto.SysConfigRequest;
import com.iotsic.smart.system.dto.SysConfigVO;

import java.util.List;
import java.util.Map;

/**
 * 系统配置服务接口
 *
 * @author Ryan
 * @since 2026-07-08
 */
public interface SysConfigService {

    /**
     * 获取所有配置（按分组）
     *
     * @return 配置 Map
     */
    Map<String, Map<String, SysConfigVO>> getAllConfig();

    /**
     * 获取指定分组的配置
     *
     * @param category 分组
     * @return 配置列表
     */
    List<SysConfigVO> getConfigByCategory(String category);

    /**
     * 更新配置
     *
     * @param id 配置ID
     * @param configValue 新值
     */
    void updateConfig(Long id, String configValue);

    /**
     * 新增配置
     *
     * @param request 配置请求
     */
    void addConfig(SysConfigRequest request);

    /**
     * 删除配置
     *
     * @param id 配置ID
     */
    void deleteConfig(Long id);

    /**
     * 刷新配置缓存
     */
    void refreshCache();
}
```

**Step 2: 创建 Service 实现**

```java
package com.iotsic.smart.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.iotsic.smart.framework.common.exception.BusinessException;
import com.iotsic.smart.framework.common.utils.JsonUtils;
import com.iotsic.smart.framework.common.utils.RedisUtils;
import com.iotsic.smart.system.dto.SysConfigRequest;
import com.iotsic.smart.system.dto.SysConfigVO;
import com.iotsic.smart.system.entity.SysConfig;
import com.iotsic.smart.system.mapper.SysConfigMapper;
import com.iotsic.smart.system.service.SysConfigService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 系统配置服务实现
 *
 * @author Ryan
 * @since 2026-07-08
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SysConfigServiceImpl implements SysConfigService {

    private static final String CACHE_KEY = "system:config:all";

    private final SysConfigMapper sysConfigMapper;

    @Override
    public Map<String, Map<String, SysConfigVO>> getAllConfig() {
        // 先尝试从缓存获取
        String cached = RedisUtils.get(CACHE_KEY);
        if (cached != null) {
            return JsonUtils.parseObject(cached, Map.class);
        }

        // 缓存不存在，加载并缓存
        Map<String, Map<String, SysConfigVO>> result = loadAndCacheConfig();
        return result;
    }

    @Override
    public List<SysConfigVO> getConfigByCategory(String category) {
        LambdaQueryWrapper<SysConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysConfig::getCategory, category)
               .eq(SysConfig::getDeleted, 0)
               .eq(SysConfig::getVisible, 1);
        List<SysConfig> list = sysConfigMapper.selectList(wrapper);
        return list.stream().map(this::convertToVO).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void updateConfig(Long id, String configValue) {
        SysConfig config = sysConfigMapper.selectById(id);
        if (config == null) {
            throw BusinessException.of(1400, "配置不存在");
        }
        config.setConfigValue(configValue);
        sysConfigMapper.updateById(config);
        
        // 删除缓存
        RedisUtils.delete(CACHE_KEY);
        log.info("配置已更新: id={}, key={}", id, config.getConfigKey());
    }

    @Override
    @Transactional
    public void addConfig(SysConfigRequest request) {
        // 检查是否已存在
        LambdaQueryWrapper<SysConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysConfig::getCategory, request.getCategory())
               .eq(SysConfig::getConfigKey, request.getConfigKey())
               .eq(SysConfig::getDeleted, 0);
        if (sysConfigMapper.selectCount(wrapper) > 0) {
            throw BusinessException.of(1402, "配置键已存在");
        }

        SysConfig config = new SysConfig();
        config.setCategory(request.getCategory());
        config.setConfigType(request.getConfigType());
        config.setConfigName(request.getConfigName());
        config.setConfigKey(request.getConfigKey());
        config.setConfigValue(request.getConfigValue());
        config.setVisible(request.getVisible() != null ? request.getVisible() : true);
        config.setIsSystem(false); // 新增配置默认为非内置
        config.setRemark(request.getRemark());
        sysConfigMapper.insert(config);

        // 删除缓存
        RedisUtils.delete(CACHE_KEY);
        log.info("配置已新增: key={}", request.getConfigKey());
    }

    @Override
    @Transactional
    public void deleteConfig(Long id) {
        SysConfig config = sysConfigMapper.selectById(id);
        if (config == null) {
            throw BusinessException.of(1400, "配置不存在");
        }
        if (Boolean.TRUE.equals(config.getIsSystem())) {
            throw BusinessException.of(1403, "系统内置配置不可删除");
        }
        sysConfigMapper.deleteById(id);

        // 删除缓存
        RedisUtils.delete(CACHE_KEY);
        log.info("配置已删除: id={}, key={}", id, config.getConfigKey());
    }

    @Override
    public void refreshCache() {
        loadAndCacheConfig();
        log.info("配置缓存已刷新");
    }

    private Map<String, Map<String, SysConfigVO>> loadAndCacheConfig() {
        LambdaQueryWrapper<SysConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysConfig::getDeleted, 0);
        List<SysConfig> list = sysConfigMapper.selectList(wrapper);

        Map<String, Map<String, SysConfigVO>> result = new HashMap<>();
        for (SysConfig config : list) {
            String category = config.getCategory();
            result.computeIfAbsent(category, k -> new HashMap<>())
                  .put(config.getConfigKey(), convertToVO(config));
        }

        // 缓存
        RedisUtils.set(CACHE_KEY, JsonUtils.toJsonString(result));
        return result;
    }

    private SysConfigVO convertToVO(SysConfig config) {
        SysConfigVO vo = new SysConfigVO();
        vo.setId(config.getId());
        vo.setCategory(config.getCategory());
        vo.setConfigType(config.getConfigType());
        vo.setConfigName(config.getConfigName());
        vo.setConfigKey(config.getConfigKey());
        vo.setConfigValue(config.getConfigValue());
        vo.setVisible(config.getVisible());
        vo.setIsSystem(config.getIsSystem());
        vo.setRemark(config.getRemark());
        return vo;
    }
}
```

**Step 3: 提交代码**

```bash
cd backend && git add smart-system/src/main/java/com/iotsic/smart/system/service/SysConfigService.java smart-system/src/main/java/com/iotsic/smart/system/service/impl/SysConfigServiceImpl.java && git commit -m "feat(system): 新增SysConfigService服务接口及实现"
```

---

## Task 5: 创建后端 Controller

**Files:**
- Create: `backend/smart-system/src/main/java/com/iotsic/smart/system/controller/admin/SysConfigController.java`

**Step 1: 创建 Controller**

```java
package com.iotsic.smart.system.controller.admin;

import com.iotsic.smart.framework.common.result.RestResult;
import com.iotsic.smart.framework.security.annotation.RequirePermission;
import com.iotsic.smart.system.dto.SysConfigRequest;
import com.iotsic.smart.system.dto.SysConfigVO;
import com.iotsic.smart.system.service.SysConfigService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 系统配置管理 Controller
 *
 * @author Ryan
 * @since 2026-07-08
 */
@RestController
@RequestMapping("/api/system/config")
@RequiredArgsConstructor
public class SysConfigController {

    private final SysConfigService sysConfigService;

    /**
     * 获取所有配置
     */
    @GetMapping("/all")
    @RequirePermission
    public RestResult<Map<String, Map<String, SysConfigVO>>> getAllConfig() {
        return RestResult.success(sysConfigService.getAllConfig());
    }

    /**
     * 获取指定分组的配置
     */
    @GetMapping("/{category}")
    @RequirePermission
    public RestResult<List<SysConfigVO>> getConfigByCategory(@PathVariable String category) {
        return RestResult.success(sysConfigService.getConfigByCategory(category));
    }

    /**
     * 更新配置
     */
    @PutMapping("/{id}")
    @RequirePermission
    public RestResult<Void> updateConfig(@PathVariable Long id, @RequestBody ConfigUpdateRequest request) {
        sysConfigService.updateConfig(id, request.getConfigValue());
        return RestResult.success();
    }

    /**
     * 新增配置
     */
    @PostMapping
    @RequirePermission
    public RestResult<Void> addConfig(@RequestBody SysConfigRequest request) {
        sysConfigService.addConfig(request);
        return RestResult.success();
    }

    /**
     * 删除配置
     */
    @DeleteMapping("/{id}")
    @RequirePermission
    public RestResult<Void> deleteConfig(@PathVariable Long id) {
        sysConfigService.deleteConfig(id);
        return RestResult.success();
    }

    /**
     * 刷新配置缓存
     */
    @PostMapping("/cache/refresh")
    @RequirePermission
    public RestResult<Void> refreshCache() {
        sysConfigService.refreshCache();
        return RestResult.success();
    }

    @Data
    public static class ConfigUpdateRequest {
        private String configValue;
    }
}
```

**Step 2: 提交代码**

```bash
cd backend && git add smart-system/src/main/java/com/iotsic/smart/system/controller/admin/SysConfigController.java && git commit -m "feat(system): 新增SysConfigController管理端接口"
```

---

## Task 6: 添加数据库表和初始化数据

**Files:**
- Modify: `docs/scripts/init-database.sql`
- Modify: `docs/scripts/init-data.sql`

**Step 1: 添加 sys_config 表到 init-database.sql**

在 `init-database.sql` 末尾（`-- 脚本执行完成` 之前）添加：

```sql
-- ============================================================
-- 系统配置表
-- ============================================================

CREATE TABLE IF NOT EXISTS `sys_config` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '参数主键',
    `category` VARCHAR(50) NOT NULL COMMENT '参数分组：basic/security/notification/email/other',
    `config_type` TINYINT NOT NULL COMMENT '参数类型：1-文本，2-数字，3-布尔，4-JSON',
    `config_name` VARCHAR(100) NOT NULL DEFAULT '' COMMENT '参数名称',
    `config_key` VARCHAR(100) NOT NULL DEFAULT '' COMMENT '参数键名',
    `config_value` VARCHAR(500) NOT NULL DEFAULT '' COMMENT '参数键值',
    `visible` BIT(1) NOT NULL DEFAULT b'1' COMMENT '是否可见（1-可见，0-隐藏）',
    `is_system` BIT(1) NOT NULL DEFAULT b'0' COMMENT '是否系统内置（1-内置，0-非内置）',
    `remark` VARCHAR(500) NULL DEFAULT NULL COMMENT '备注说明',
    `deleted` BIT(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `create_by` VARCHAR(64) NULL DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) NULL DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_category_key` (`category`, `config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='参数配置表';
```

**Step 2: 添加初始数据到 init-data.sql**

在 `init-data.sql` 末尾添加：

```sql
-- ============================================================
-- 系统配置初始数据
-- ============================================================

-- 基本设置
INSERT INTO sys_config (category, config_type, config_name, config_key, config_value, visible, is_system, remark) VALUES
('basic', 1, '系统名称', 'system_name', '心理测评系统', b'1', b'1', ''),
('basic', 1, '系统Logo', 'system_logo', '', b'1', b'1', ''),
('basic', 1, '系统描述', 'system_description', '', b'1', b'1', ''),
('basic', 1, '版权信息', 'copyright', '© 2024', b'1', b'1', '');

-- 安全设置
INSERT INTO sys_config (category, config_type, config_name, config_key, config_value, visible, is_system, remark) VALUES
('security', 2, '登录超时时间', 'login_timeout', '30', b'1', b'1', '单位：分钟'),
('security', 2, '密码最小长度', 'password_min_length', '8', b'1', b'1', ''),
('security', 3, '密码需要特殊字符', 'password_require_special_char', 'true', b'1', b'1', ''),
('security', 3, '密码需要数字', 'password_require_number', 'true', b'1', b'1', ''),
('security', 3, '密码需要大写字母', 'password_require_uppercase', 'false', b'1', b'1', ''),
('security', 2, '登录失败锁定次数', 'login_fail_lock', '5', b'1', b'1', ''),
('security', 1, 'IP白名单', 'ip_whitelist', '', b'1', b'1', '多个用逗号分隔');

-- 通知设置
INSERT INTO sys_config (category, config_type, config_name, config_key, config_value, visible, is_system, remark) VALUES
('notification', 3, '邮件通知开关', 'email_notification_enabled', 'true', b'1', b'1', ''),
('notification', 1, '邮件模板', 'email_template', '', b'1', b'1', ''),
('notification', 3, '短信通知开关', 'sms_notification_enabled', 'false', b'1', b'1', ''),
('notification', 1, '短信模板', 'sms_template', '', b'1', b'1', ''),
('notification', 3, '站内信通知开关', 'site_message_enabled', 'true', b'1', b'1', '');

-- 邮件配置
INSERT INTO sys_config (category, config_type, config_name, config_key, config_value, visible, is_system, remark) VALUES
('email', 1, '邮箱服务器', 'email_host', '', b'1', b'1', '如 smtp.example.com'),
('email', 1, '邮箱账号', 'email_username', '', b'1', b'1', ''),
('email', 1, '邮箱授权码', 'email_password', '', b'1', b'1', '授权码非密码');
```

**Step 3: 添加配置管理权限到 init-data.sql**

在权限 INSERT 语句中添加：

```sql
-- 系统配置模块（MOD-008）
('配置管理', 'system:config:manage', 1, NULL, 'MOD-008', 7),
('配置查看', 'system:config:list', 2, 25, 'MOD-008', 1),
('配置新增', 'system:config:add', 3, 25, 'MOD-008', 2),
('配置修改', 'system:config:update', 3, 25, 'MOD-008', 3),
('配置删除', 'system:config:delete', 3, 25, 'MOD-008', 4);
```

并在角色权限分配中添加新权限。

**Step 4: 提交代码**

```bash
cd docs && git add scripts/init-database.sql scripts/init-data.sql && git commit -m "docs(database): 添加sys_config表及初始数据"
```

---

## Task 7: 创建前端 API 文件

**Files:**
- Create: `frontend/src/api/systemConfig.ts`

**Step 1: 创建 API 文件**

```typescript
import request from '@/utils/request'

export interface SysConfigVO {
  id: number
  category: string
  configType: number
  configName: string
  configKey: string
  configValue: string
  visible: boolean
  isSystem: boolean
  remark: string
}

export interface SysConfigRequest {
  category: string
  configType: number
  configName: string
  configKey: string
  configValue: string
  visible?: boolean
  remark?: string
}

export interface ConfigUpdateRequest {
  configValue: string
}

export const getAllConfig = () => {
  return request.get<Record<string, Record<string, SysConfigVO>>>('/system/config/all')
}

export const getConfigByCategory = (category: string) => {
  return request.get<SysConfigVO[]>(`/system/config/${category}`)
}

export const updateConfig = (id: number, data: ConfigUpdateRequest) => {
  return request.put<void>(`/system/config/${id}`, data)
}

export const addConfig = (data: SysConfigRequest) => {
  return request.post<void>('/system/config', data)
}

export const deleteConfig = (id: number) => {
  return request.delete<void>(`/system/config/${id}`)
}

export const refreshConfigCache = () => {
  return request.post<void>('/system/config/cache/refresh')
}
```

**Step 2: 提交代码**

```bash
cd frontend && git add src/api/systemConfig.ts && git commit -m "feat(frontend): 新增系统配置API"
```

---

## Task 8: 改造前端 SystemSetting.vue

**Files:**
- Modify: `frontend/src/views/system/SystemSetting.vue`

**Step 1: 改造页面对接后端 API**

需要：
1. 导入 `getAllConfig`、`updateConfig` API
2. `onMounted` 时调用 `getAllConfig()` 加载配置
3. 保存时调用 `updateConfig` 更新对应配置
4. 添加邮件配置 Tab

**Step 2: 提交代码**

```bash
cd frontend && git add src/views/system/SystemSetting.vue && git commit -m "feat(frontend): 改造SystemSetting对接后端配置API"
```

---

## Task 9: 创建前端 ConfigManagement.vue

**Files:**
- Create: `frontend/src/views/system/ConfigManagement.vue`

**Step 1: 创建配置管理页面**

功能：
- 表格展示所有配置（可筛选分组、关键词）
- 新增按钮（仅非内置）
- 编辑按钮
- 删除按钮（仅非内置）
- 刷新缓存按钮

**Step 2: 提交代码**

```bash
cd frontend && git add src/views/system/ConfigManagement.vue && git commit -m "feat(frontend): 新增ConfigManagement配置管理页面"
```

---

## Task 10: 添加前端路由

**Files:**
- Modify: `frontend/src/router/index.ts`

**Step 1: 添加配置管理路由**

```typescript
{
  path: 'system/config',
  name: 'ConfigManagement',
  component: () => import('@/views/system/ConfigManagement.vue'),
  meta: { title: '配置管理' }
}
```

**Step 2: 提交代码**

```bash
cd frontend && git add src/router/index.ts && git commit -m "feat(frontend): 添加配置管理路由"
```

---

## Task 11: 编译验证

**Step 1: 编译后端**

```bash
cd backend && mvn compile -pl smart-system -am -DskipTests -q
```

**Step 2: 编译前端**

```bash
cd frontend && npm run build
```

---

## Task 12: 推送到远程

**Step 1: 推送所有仓库**

```bash
cd backend && git push
cd frontend && git push
cd docs && git push
```

---

**Plan complete and saved to `docs/plans/2026-07-08-system-config-implementation-plan.md`.**

**Two execution options:**

1. **Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

2. **Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?**
