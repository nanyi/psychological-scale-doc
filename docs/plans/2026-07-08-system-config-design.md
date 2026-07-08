# 系统配置管理模块 - 设计文档

> **文档版本**: 1.0
> **创建日期**: 2026-07-08
> **作者**: Ryan
> **状态**: 待实现

---

## 1. 模块概述

### 1.1 模块编号

**MOD-008** - 系统配置管理模块

### 1.2 模块说明

本模块提供系统配置的统一管理功能，支持配置的增删改查、缓存管理、分类展示。系统内置配置不可删除，非内置配置可动态管理。

### 1.3 功能清单

| 功能 | 说明 | 状态 |
|------|------|------|
| 配置查询 | 按分组/全部查询系统配置 | 新增 |
| 配置更新 | 更新配置项值 | 新增 |
| 配置新增 | 新增非内置配置项 | 新增 |
| 配置删除 | 删除非内置配置项 | 新增 |
| 缓存刷新 | 手动刷新配置缓存 | 新增 |
| 前端集成 | 系统设置页面对接 | 新增 |

---

## 2. 数据库设计

### 2.1 表结构

```sql
CREATE TABLE `sys_config` (
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

### 2.2 字段说明

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT | 主键，自增 |
| category | VARCHAR(50) | 参数分组 |
| config_type | TINYINT | 参数类型：1-文本，2-数字，3-布尔，4-JSON |
| config_name | VARCHAR(100) | 参数名称（显示用） |
| config_key | VARCHAR(100) | 参数键名（唯一标识） |
| config_value | VARCHAR(500) | 参数键值 |
| visible | BIT(1) | 是否可见 |
| is_system | BIT(1) | 是否系统内置 |
| remark | VARCHAR(500) | 备注说明 |
| deleted | BIT(1) | 逻辑删除 |
| create_by | VARCHAR(64) | 创建者 |
| create_time | DATETIME | 创建时间 |
| update_by | VARCHAR(64) | 更新者 |
| update_time | DATETIME | 更新时间 |

---

## 3. 配置分组

### 3.1 分组清单

| category | 分组名称 | 说明 |
|----------|---------|------|
| basic | 基本设置 | 系统名称/Logo/版权等 |
| security | 安全设置 | 登录超时/密码规则/IP白名单等 |
| notification | 通知设置 | 邮件/短信/站内信开关及模板 |
| email | 邮件配置 | 邮箱服务器/账号/授权码 |
| other | 其他配置 | 非系统内置的动态配置项 |

### 3.2 内置配置项

#### basic（基本设置）

| config_key | config_name | config_type | 默认值 | remark |
|------------|-------------|-------------|--------|--------|
| system_name | 系统名称 | 1 | 心理测评系统 | |
| system_logo | 系统Logo | 1 | | |
| system_description | 系统描述 | 1 | | |
| copyright | 版权信息 | 1 | © 2024 | |

#### security（安全设置）

| config_key | config_name | config_type | 默认值 | remark |
|------------|-------------|-------------|--------|--------|
| login_timeout | 登录超时时间 | 2 | 30 | 单位：分钟 |
| password_min_length | 密码最小长度 | 2 | 8 | |
| password_require_special_char | 密码需要特殊字符 | 3 | true | |
| password_require_number | 密码需要数字 | 3 | true | |
| password_require_uppercase | 密码需要大写字母 | 3 | false | |
| login_fail_lock | 登录失败锁定次数 | 2 | 5 | |
| ip_whitelist | IP白名单 | 1 | | 多个用逗号分隔 |

#### notification（通知设置）

| config_key | config_name | config_type | 默认值 | remark |
|------------|-------------|-------------|--------|--------|
| email_notification_enabled | 邮件通知开关 | 3 | true | |
| email_template | 邮件模板 | 1 | | |
| sms_notification_enabled | 短信通知开关 | 3 | false | |
| sms_template | 短信模板 | 1 | | |
| site_message_enabled | 站内信通知开关 | 3 | true | |

#### email（邮件配置）

| config_key | config_name | config_type | remark |
|------------|-------------|-------------|--------|
| email_host | 邮箱服务器 | 1 | 如 smtp.example.com |
| email_username | 邮箱账号 | 1 | |
| email_password | 邮箱授权码 | 1 | 授权码非密码 |

---

## 4. API 设计

### 4.1 接口清单

| 接口路径 | 方法 | 说明 | 权限 |
|---------|------|------|------|
| `/api/system/config/all` | GET | 获取所有配置 | system:config:list |
| `/api/system/config/{category}` | GET | 获取指定分组的配置 | system:config:list |
| `/api/system/config/{id}` | PUT | 更新配置 | system:config:update |
| `/api/system/config` | POST | 新增配置 | system:config:add |
| `/api/system/config/{id}` | DELETE | 删除配置 | system:config:delete |
| `/api/system/config/cache/refresh` | POST | 刷新配置缓存 | system:config:update |

### 4.2 请求响应格式

#### GET /api/system/config/all

响应：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "basic": {
      "system_name": { "id": 1, "configName": "系统名称", "configValue": "心理测评系统", "configType": 1, "isSystem": true },
      "system_logo": { "id": 2, "configName": "系统Logo", "configValue": "", "configType": 1, "isSystem": true }
    },
    "security": { ... },
    "notification": { ... },
    "email": { ... },
    "other": { ... }
  }
}
```

#### PUT /api/system/config/{id}

请求：
```json
{
  "configValue": "新值"
}
```

### 4.3 错误码

| 错误码 | 说明 |
|--------|------|
| 1400 | 配置不存在 |
| 1401 | 配置更新失败 |
| 1402 | 配置新增失败 |
| 1403 | 配置删除失败（系统内置不可删除） |
| 1404 | 缓存刷新失败 |

---

## 5. 缓存策略

### 5.1 缓存设计

- **缓存 Key**：`system:config:all`
- **缓存方式**：Redis String（JSON 序列化）
- **过期时间**：不过期，依靠变更时主动刷新

### 5.2 加载时机

1. 应用启动时
2. Redis 缓存不存在时（首次访问）
3. 手动刷新缓存后

### 5.3 刷新机制

- 配置变更（新增/更新/删除）时删除缓存
- 提供手动刷新接口 `POST /api/system/config/cache/refresh`
- 下次访问时自动重新加载

---

## 6. 后端设计

### 6.1 类清单

| 包路径 | 类名 | 说明 |
|--------|------|------|
| com.iotsic.smart.system.entity | SysConfig | 配置实体 |
| com.iotsic.smart.system.mapper | SysConfigMapper | 配置 Mapper |
| com.iotsic.smart.system.service | SysConfigService | 配置服务接口 |
| com.iotsic.smart.system.service.impl | SysConfigServiceImpl | 配置服务实现 |
| com.iotsic.smart.system.controller.admin | SysConfigController | 管理端接口 |

### 6.2 DTO 设计

**SysConfigVO** - 配置响应
```java
@Data
public class SysConfigVO {
    private Long id;
    private String category;
    private Integer configType;
    private String configName;
    private String configKey;
    private String configValue;
    private Boolean visible;
    private Boolean isSystem;
    private String remark;
}
```

**SysConfigRequest** - 配置请求
```java
@Data
public class SysConfigRequest {
    private String category;
    private Integer configType;
    private String configName;
    private String configKey;
    private String configValue;
    private Boolean visible;
    private String remark;
}
```

---

## 7. 前端设计

### 7.1 页面清单

| 页面文件 | 路由 | 功能 |
|----------|------|------|
| `SystemSetting.vue` | `/system/setting` | 系统设置（含新增邮件配置 Tab） |
| `ConfigManagement.vue` | `/system/config` | 配置管理（增删改 + 刷新缓存） |

### 7.2 SystemSetting.vue 改造

**Tab 结构**：
1. 基本设置 - 文本输入框
2. 安全设置 - 文本/数字/开关输入
3. 通知设置 - 开关 + 文本模板
4. 邮件配置 - 文本框 + 备注说明（参考图示）

### 7.3 ConfigManagement.vue 功能

**功能**：
- 列表展示所有配置（按分组）
- 筛选：按分组、是否内置、关键词搜索
- 新增配置（仅非内置）
- 编辑配置
- 删除配置（仅非内置）
- 刷新缓存按钮

---

## 8. 安全设计

### 8.1 权限控制

| 功能 | 权限编码 |
|------|----------|
| 查看配置 | system:config:list |
| 新增配置 | system:config:add |
| 更新配置 | system:config:update |
| 删除配置 | system:config:delete |

### 8.2 内置配置保护

- `is_system = true` 的配置不可删除
- `is_system = true` 的配置不可修改 `config_key`
- 仅超级管理员可管理内置配置

---

## 9. 性能设计

### 9.1 索引

- `uk_category_key` - 唯一索引，保证 category + config_key 唯一性
- 查询基于内存缓存，不直接查询数据库

### 9.2 缓存优化

- 全量配置缓存在 Redis，减少数据库访问
- 配置变更时只删除缓存，不立即更新，懒加载

---

## 10. 初始化数据

见 `docs/scripts/init-data.sql`，需添加 `sys_config` 表的初始数据。

---

*文档版本: 1.0*
*最后更新: 2026-07-08*
*维护团队: iotsic*
