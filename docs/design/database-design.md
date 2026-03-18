# 数据库设计文档

## 1. 文档信息

| 属性 | 内容 |
|------|------|
| 文档类型 | 技术设计 |
| 版本 | 1.0 |
| 状态 | 已完成 |
| 创建日期 | 2026-03-09 |
| 最后更新 | 2026-03-17 |
| 作者 | Ryan |

## 2. 设计原则

### 2.1 命名规范

- **表名**: 小写字母 + 下划线（snake_case）
- **字段名**: 小写字母 + 下划线（snake_case）
- **主键**: id（BIGINT AUTO_INCREMENT）
- **索引名**: idx_{表名}_{字段名}

### 2.2 审计字段

所有业务表必须包含以下审计字段：

| 字段名 | 类型 | 说明 |
|--------|------|------|
| create_time | DATETIME | 创建时间 |
| create_by | BIGINT | 创建人（关联用户ID） |
| update_time | DATETIME | 更新时间 |
| update_by | BIGINT | 更新人（关联用户ID） |
| deleted | TINYINT | 逻辑删除（0-正常，1-删除） |

### 2.3 强制约束

> **重要：以下约束为强制要求，所有数据库设计必须遵守**

#### 2.3.1 禁止使用显式外键

- **不允许**使用 `FOREIGN KEY` 约束
- 表间关联通过**应用层逻辑**实现，由MyBatis-Plus管理
- **原因**：
  - 外键会增加数据库维护成本
  - 影响数据库性能（级联删除/更新开销）
  - 跨服务场景不支持外键关联

#### 2.3.2 禁止使用存储过程

- **不允许**创建 `PROCEDURE`
- 所有业务逻辑必须在**应用层**实现
- **原因**：
  - 存储过程难以调试和版本管理
  - 不利于微服务架构解耦
  - 数据库迁移时需要重写

#### 2.3.3 禁止使用数据库事件

- **不允许**创建 `EVENT`
- 定时任务使用**应用层调度**（如Spring @Scheduled、XXL-Job）
- **原因**：
  - 数据库事件难以监控和管理
  - 事件与业务代码分离，不利于维护
  - 应由应用层统一调度定时任务

## 3. 核心业务表设计

### 3.1 用户模块

#### 3.1.1 用户表 (sys_user)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 用户ID |
| username | VARCHAR(100) | UNIQUE, NOT NULL | 用户名 |
| password | VARCHAR(200) | NOT NULL | 密码（BCrypt加密） |
| nickname | VARCHAR(100) | | 昵称 |
| avatar | VARCHAR(500) | | 头像URL |
| phone | VARCHAR(20) | | 手机号 |
| email | VARCHAR(100) | | 邮箱 |
| user_type | TINYINT | NOT NULL DEFAULT 1 | 用户类型：1-个人，2-企业 |
| gender | TINYINT | NOT NULL DEFAULT 0 | 性别：0-未知，1-男，2-女 |
| birthday | DATE | | 生日 |
| enterprise_id | BIGINT | | 企业ID |
| department_id | BIGINT | | 部门ID |
| status | TINYINT | NOT NULL DEFAULT 1 | 状态：0-禁用，1-正常 |
| last_login_ip | VARCHAR(50) | | 最后登录IP |
| last_login_time | DATETIME | | 最后登录时间 |
| login_fail_count | INT | NOT NULL DEFAULT 0 | 登录失败次数 |
| lock_until | DATETIME | | 锁定到期时间 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |
| create_by | BIGINT | | 创建人 |
| update_by | BIGINT | | 更新人 |
| deleted | TINYINT | NOT NULL DEFAULT 0 | 逻辑删除 |
| version | INT | DEFAULT 0 | 版本号 |

**索引**:
- idx_phone (phone)
- idx_enterprise_id (enterprise_id)

#### 3.1.2 企业表 (sys_enterprise)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 企业ID |
| enterprise_name | VARCHAR(200) | NOT NULL | 企业名称 |
| credit_code | VARCHAR(50) | UNIQUE | 统一社会信用代码 |
| contact_name | VARCHAR(100) | | 联系人 |
| contact_phone | VARCHAR(20) | | 联系电话 |
| contact_email | VARCHAR(100) | | 联系邮箱 |
| status | TINYINT | NOT NULL DEFAULT 0 | 状态：0-待审核，1-正常，2-禁用 |
| expire_time | DATETIME | | 到期时间 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |
| deleted | TINYINT | NOT NULL DEFAULT 0 | 逻辑删除 |

#### 3.1.3 角色表 (sys_role)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 角色ID |
| role_name | VARCHAR(100) | NOT NULL | 角色名称 |
| role_code | VARCHAR(50) | UNIQUE, NOT NULL | 角色编码 |
| description | VARCHAR(500) | | 描述 |
| status | TINYINT | NOT NULL DEFAULT 1 | 状态：0-禁用，1-正常 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |

#### 3.1.4 用户角色关联表 (sys_user_role)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| role_id | BIGINT | NOT NULL | 角色ID |
| create_time | DATETIME | NOT NULL | 创建时间 |

**索引**:
- idx_user_id (user_id)
- idx_role_id (role_id)

#### 3.1.5 权限表 (sys_permission)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 权限ID |
| permission_name | VARCHAR(100) | NOT NULL | 权限名称 |
| permission_code | VARCHAR(100) | UNIQUE, NOT NULL | 权限编码 |
| permission_type | TINYINT | NOT NULL | 类型：1-菜单目录,2-菜单,3-功能,4-数据 |
| parent_id | BIGINT | | 父权限ID |
| module | VARCHAR(50) | | 所属模块 |
| create_time | DATETIME | NOT NULL | 创建时间 |

#### 3.1.6 角色权限关联表 (sys_role_permission)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | ID |
| role_id | BIGINT | NOT NULL | 角色ID |
| permission_id | BIGINT | NOT NULL | 权限ID |
| create_time | DATETIME | NOT NULL | 创建时间 |

#### 3.1.7 用户分组表 (sys_user_group)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 分组ID |
| group_name | VARCHAR(100) | NOT NULL | 分组名称 |
| group_type | TINYINT | NOT NULL | 类型：1-学生组，2-员工组，3-自定义 |
| enterprise_id | BIGINT | | 企业ID |
| parent_id | BIGINT | | 父分组ID |
| description | VARCHAR(500) | | 描述 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |

#### 3.1.8 用户分组关联表 (sys_user_group_member)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | ID |
| group_id | BIGINT | NOT NULL | 分组ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| create_time | DATETIME | NOT NULL | 创建时间 |

### 3.2 量表模块

#### 3.2.1 量表分类表 (ps_scale_category)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 分类ID |
| category_name | VARCHAR(100) | NOT NULL | 分类名称 |
| parent_id | BIGINT | NOT NULL DEFAULT 0 | 父分类ID（0=一级分类） |
| sort_order | INT | NOT NULL DEFAULT 0 | 排序 |
| remark | VARCHAR(500) | | 备注 |
| status | TINYINT | NOT NULL DEFAULT 1 | 状态：0-禁用，1-启用 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |
| deleted | TINYINT | NOT NULL DEFAULT 0 | 逻辑删除 |

**索引**:
- idx_parent_id (parent_id)
- idx_status (status)

#### 3.2.2 量表表 (ps_scale)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 量表ID |
| scale_code | VARCHAR(32) | UNIQUE, NOT NULL | 量表编码 |
| scale_name | VARCHAR(200) | NOT NULL | 量表名称 |
| scale_name_en | VARCHAR(200) | | 英文名 |
| category_id | BIGINT | | 分类ID |
| target_audience | VARCHAR(200) | | 适用人群 |
| description | TEXT | | 描述 |
| instruction | TEXT | | 指导语 |
| cover | VARCHAR(500) | | 封面图URL |
| duration | INT | | 预计时长（分钟） |
| question_count | INT | | 题目数量 |
| dimension_count | INT | | 维度数量 |
| source_type | TINYINT | NOT NULL DEFAULT 1 | 来源：1-内置，2-第三方，3-自定义 |
| third_party_id | VARCHAR(100) | | 第三方量表ID |
| platform_id | BIGINT | | 第三方平台ID |
| price | DECIMAL(10,2) | | 价格 |
| age_range_min | INT | | 年龄范围最小值 |
| age_range_max | INT | | 年龄范围最大值 |
| applicable_gender | TINYINT | NOT NULL DEFAULT 0 | 适用性别：1-男，2-女，3-通用 |
| attention | TEXT | | 注意事项 |
| is_free | TINYINT | NOT NULL DEFAULT 0 | 是否免费：0-收费，1-免费 |
| view_count | INT | NOT NULL DEFAULT 0 | 浏览次数 |
| use_count | INT | NOT NULL DEFAULT 0 | 使用次数 |
| publish_time | DATETIME | | 发布时间 |
| status | TINYINT | NOT NULL DEFAULT 0 | 状态：0-草稿，1-已发布，2-已下架 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |
| create_by | BIGINT | | 创建人 |
| update_by | BIGINT | | 更新人 |
| deleted | TINYINT | NOT NULL DEFAULT 0 | 逻辑删除 |
| version | INT | DEFAULT 0 | 版本号 |

**索引**:
- idx_category_id (category_id)
- idx_source_type (source_type)

#### 3.2.3 量表维度表 (ps_scale_dimension)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 维度ID |
| scale_id | BIGINT | NOT NULL | 量表ID |
| dimension_code | VARCHAR(32) | NOT NULL | 维度编码 |
| dimension_name | VARCHAR(100) | NOT NULL | 维度名称 |
| sort_order | INT | NOT NULL DEFAULT 0 | 排序 |
| create_time | DATETIME | NOT NULL | 创建时间 |

**索引**:
- idx_scale_id (scale_id)

#### 3.2.4 量表因子表 (ps_scale_factor)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 因子ID |
| dimension_id | BIGINT | NOT NULL | 维度ID |
| factor_code | VARCHAR(32) | NOT NULL | 因子编码 |
| factor_name | VARCHAR(100) | NOT NULL | 因子名称 |
| formula | VARCHAR(500) | | 计算公式 |
| weight | DECIMAL(5,2) | | 权重 |
| sort_order | INT | NOT NULL DEFAULT 0 | 排序 |
| create_time | DATETIME | NOT NULL | 创建时间 |

#### 3.2.5 题目表 (ps_question)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 题目ID |
| scale_id | BIGINT | NOT NULL | 量表ID |
| question_no | VARCHAR(10) | NOT NULL | 题目编号 |
| content | TEXT | NOT NULL | 题目内容 |
| content_type | TINYINT | NOT NULL DEFAULT 1 | 内容类型：1-文本，2-图片，3-音频 |
| attachment_url | VARCHAR(500) | | 附件URL |
| question_type | TINYINT | NOT NULL | 题目类型：1-单选，2-多选，3-量表题，4-问答 |
| is_reverse | TINYINT | NOT NULL DEFAULT 0 | 是否反向计分：0-否，1-是 |
| dimension_id | BIGINT | | 所属维度ID |
| factor_id | BIGINT | | 所属因子ID |
| sort_order | INT | NOT NULL DEFAULT 0 | 排序 |
| is_required | TINYINT | NOT NULL DEFAULT 1 | 是否必答：0-否，1-是 |
| create_time | DATETIME | NOT NULL | 创建时间 |

**索引**:
- idx_scale_id (scale_id)

#### 3.2.6 选项表 (ps_question_option)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 选项ID |
| question_id | BIGINT | NOT NULL | 题目ID |
| option_no | VARCHAR(10) | NOT NULL | 选项编号 |
| option_text | VARCHAR(500) | NOT NULL | 选项文本 |
| option_value | DECIMAL(10,2) | NOT NULL | 选项分值 |
| sort_order | INT | NOT NULL DEFAULT 0 | 排序 |
| create_time | DATETIME | NOT NULL | 创建时间 |

**索引**:
- idx_question_id (question_id)

#### 3.2.7 测评任务表 (ps_assessment_task)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 任务ID |
| task_no | VARCHAR(32) | UNIQUE, NOT NULL | 任务编号 |
| user_id | BIGINT | NOT NULL | 用户ID |
| scale_id | BIGINT | NOT NULL | 量表ID |
| source_type | TINYINT | NOT NULL | 来源：1-购买，2-企业分配，3-免费 |
| source_id | BIGINT | | 来源ID（订单ID/配额ID） |
| status | TINYINT | NOT NULL DEFAULT 0 | 状态：0-待开始，1-进行中，2-已完成，3-已超时 |
| progress | INT | NOT NULL DEFAULT 0 | 进度 |
| start_time | DATETIME | | 开始时间 |
| finish_time | DATETIME | | 完成时间 |
| expire_time | DATETIME | | 过期时间 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |
| deleted | TINYINT | NOT NULL DEFAULT 0 | 逻辑删除 |

**索引**:
- idx_user_id (user_id)
- idx_scale_id (scale_id)
- idx_status (status)

#### 3.2.8 答题记录表 (ps_answer_record)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 记录ID |
| task_id | BIGINT | NOT NULL | 任务ID |
| question_id | BIGINT | NOT NULL | 题目ID |
| answer_value | VARCHAR(500) | | 答案值 |
| answer_text | TEXT | | 答案文本 |
| score | DECIMAL(10,2) | | 得分 |
| answer_time | INT | | 答题用时（秒） |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |

**索引**:
- idx_task_id (task_id)

#### 3.2.8 测评记录表 (ps_exam_record)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 记录ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| scale_id | BIGINT | NOT NULL | 量表ID |
| record_no | VARCHAR(50) | UNIQUE, NOT NULL | 记录编号 |
| exam_status | TINYINT | NOT NULL DEFAULT 0 | 测评状态：0-待开始，1-进行中，2-已完成，3-已暂停，4-已取消 |
| total_score | INT | | 总分 |
| score | DECIMAL(5,2) | | 得分 |
| correct_count | INT | | 正确数 |
| wrong_count | INT | | 错误数 |
| blank_count | INT | | 空白数 |
| answer_time | INT | | 答题时间(秒) |
| start_time | DATETIME | | 开始时间 |
| submit_time | DATETIME | | 提交时间 |
| ip_address | VARCHAR(50) | | IP地址 |
| device_info | VARCHAR(200) | | 设备信息 |
| source | VARCHAR(50) | | 来源：pc、小程序、h5 |
| enterprise_id | BIGINT | | 企业ID |
| dimension_scores | TEXT | | 维度得分JSON |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |
| create_by | BIGINT | | 创建人 |
| update_by | BIGINT | | 更新人 |
| deleted | TINYINT | NOT NULL DEFAULT 0 | 逻辑删除：0-正常，1-删除 |
| version | INT | DEFAULT 0 | 版本号 |

**索引**:
- idx_user_id (user_id)
- idx_scale_id (scale_id)
- idx_record_no (record_no)
- idx_exam_status (exam_status)
- idx_create_time (create_time)

### 3.3 订单模块

#### 3.3.1 订单表 (ps_order)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 订单ID |
| order_no | VARCHAR(32) | UNIQUE, NOT NULL | 订单编号 |
| user_id | BIGINT | NOT NULL | 用户ID |
| order_type | TINYINT | NOT NULL | 订单类型：1-个人购买，2-企业团购 |
| total_amount | DECIMAL(10,2) | NOT NULL | 订单总金额 |
| discount_amount | DECIMAL(10,2) | NOT NULL DEFAULT 0 | 优惠金额 |
| pay_amount | DECIMAL(10,2) | NOT NULL | 实付金额 |
| pay_channel | TINYINT | | 支付渠道：1-微信，2-支付宝 |
| order_status | TINYINT | NOT NULL DEFAULT 0 | 状态：0-待支付，1-已支付，2-已取消，3-已退款，4-部分退款 |
| enterprise_id | BIGINT | | 企业ID |
| expire_time | DATETIME | | 订单过期时间 |
| pay_time | DATETIME | | 支付时间 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |
| deleted | TINYINT | NOT NULL DEFAULT 0 | 逻辑删除 |

**索引**:
- idx_user_id (user_id)
- idx_order_status (order_status)

#### 3.3.2 订单项表 (ps_order_item)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 订单项ID |
| order_no | VARCHAR(32) | NOT NULL | 订单编号 |
| scale_id | BIGINT | NOT NULL | 量表ID |
| scale_name | VARCHAR(200) | NOT NULL | 量表名称 |
| price | DECIMAL(10,2) | NOT NULL | 购买单价 |
| quantity | INT | NOT NULL DEFAULT 1 | 购买数量 |
| amount | DECIMAL(10,2) | NOT NULL | 小计金额 |
| refund_status | TINYINT | NOT NULL DEFAULT 0 | 退款状态：0-未退款，1-已退款，2-部分退款 |
| refund_amount | DECIMAL(10,2) | NOT NULL DEFAULT 0 | 退款金额 |
| create_time | DATETIME | NOT NULL | 创建时间 |

**索引**:
- idx_order_no (order_no)

#### 3.3.3 退款记录表 (ps_refund)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 退款ID |
| refund_no | VARCHAR(32) | UNIQUE, NOT NULL | 退款编号 |
| order_no | VARCHAR(32) | NOT NULL | 原订单编号 |
| order_item_id | BIGINT | NOT NULL | 订单项ID |
| refund_amount | DECIMAL(10,2) | NOT NULL | 退款金额 |
| refund_reason | VARCHAR(500) | | 退款原因 |
| refund_status | TINYINT | NOT NULL DEFAULT 0 | 状态：0-处理中，1-成功，2-失败 |
| refund_channel | TINYINT | | 退款渠道 |
| refund_time | DATETIME | | 退款时间 |
| create_time | DATETIME | NOT NULL | 申请时间 |

#### 3.3.4 用户配额表 (sys_user_quota)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 配额ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| scale_id | BIGINT | NOT NULL | 量表ID |
| total_quantity | INT | NOT NULL | 总量 |
| used_quantity | INT | NOT NULL DEFAULT 0 | 已使用 |
| expire_time | DATETIME | | 过期时间 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |

**索引**:
- idx_user_id (user_id)
- idx_scale_id (scale_id)
- UNIQUE KEY uk_user_scale (user_id, scale_id)

#### 3.3.5 企业配额表 (sys_enterprise_quota)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 配额ID |
| enterprise_id | BIGINT | NOT NULL | 企业ID |
| scale_id | BIGINT | NOT NULL | 量表ID |
| total_quantity | INT | NOT NULL | 总量 |
| used_quantity | INT | NOT NULL DEFAULT 0 | 已使用 |
| expire_time | DATETIME | | 过期时间 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |

**索引**:
- idx_enterprise_id (enterprise_id)
- idx_scale_id (scale_id)
- UNIQUE KEY uk_enterprise_scale (enterprise_id, scale_id)

### 3.4 报告模块

#### 3.4.1 报告表 (ps_report)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 报告ID |
| report_no | VARCHAR(32) | UNIQUE, NOT NULL | 报告编号 |
| task_id | BIGINT | NOT NULL | 测评任务ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| scale_id | BIGINT | NOT NULL | 量表ID |
| scale_name | VARCHAR(200) | NOT NULL | 量表名称 |
| total_score | DECIMAL(10,2) | | 总分 |
| dimension_scores | TEXT | | 维度得分(JSON) |
| result_level | VARCHAR(50) | | 结果等级 |
| conclusion | TEXT | | 结论 |
| suggestions | TEXT | | 建议(JSON数组) |
| report_content | TEXT | | 完整报告内容(JSON) |
| source_type | TINYINT | NOT NULL | 来源：1-本地生成，2-第三方API |
| third_party_report | TEXT | | 第三方报告原始数据 |
| status | TINYINT | NOT NULL DEFAULT 0 | 状态：0-生成中，1-已生成，2-生成失败 |
| generate_time | DATETIME | | 生成时间 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |

**索引**:
- idx_user_id (user_id)
- idx_task_id (task_id)

#### 3.4.2 报告模板表 (ps_report_template)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 模板ID |
| scale_id | BIGINT | NOT NULL | 量表ID |
| template_name | VARCHAR(100) | NOT NULL | 模板名称 |
| template_type | TINYINT | NOT NULL | 类型：1-简版，2-详版，3-专业版 |
| template_content | TEXT | NOT NULL | 模板内容(HTML) |
| variables | VARCHAR(1000) | | 变量列表(JSON) |
| status | TINYINT | NOT NULL DEFAULT 0 | 状态：0-草稿，1-已发布 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |

### 3.5 第三方对接模块

#### 3.5.1 第三方平台表 (ps_third_party_platform)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 平台ID |
| platform_name | VARCHAR(100) | NOT NULL | 平台名称 |
| api_base_url | VARCHAR(200) | NOT NULL | API基础地址 |
| app_key | VARCHAR(100) | NOT NULL | AppKey |
| app_secret | VARCHAR(500) | NOT NULL | AppSecret（加密） |
| callback_url | VARCHAR(200) | | 回调地址 |
| sync_strategy | TINYINT | NOT NULL DEFAULT 1 | 同步策略：1-实时，2-定时 |
| status | TINYINT | NOT NULL DEFAULT 1 | 状态：0-停用，1-启用 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |

#### 3.5.2 量表映射表 (ps_scale_mapping)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 映射ID |
| local_scale_id | BIGINT | NOT NULL | 本地量表ID |
| third_party_id | VARCHAR(100) | NOT NULL | 第三方量表ID |
| platform_id | BIGINT | NOT NULL | 平台ID |
| create_time | DATETIME | NOT NULL | 创建时间 |

#### 3.5.3 答题记录表(第三方) (ps_third_party_answer)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 记录ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| scale_id | BIGINT | NOT NULL | 量表ID |
| third_party_id | VARCHAR(100) | | 第三方量表ID |
| task_id | VARCHAR(32) | | 第三方任务ID |
| answers | TEXT | | 答题记录(JSON) |
| status | TINYINT | NOT NULL DEFAULT 0 | 状态：0-待提交，1-待评分，2-已完成，3-失败 |
| report_data | TEXT | | 报告数据(JSON) |
| submit_time | DATETIME | | 提交时间 |
| complete_time | DATETIME | | 完成时间 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |

### 3.6 数据分析模块

#### 3.6.1 常模数据表 (ps_norm_data)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 常模ID |
| scale_id | BIGINT | NOT NULL | 量表ID |
| dimension_id | BIGINT | | 维度ID |
| group_type | VARCHAR(20) | NOT NULL | 分组类型 |
| group_value | VARCHAR(50) | NOT NULL | 分组值 |
| mean | DECIMAL(10,2) | NOT NULL | 平均分 |
| std_dev | DECIMAL(10,2) | NOT NULL | 标准差 |
| sample_size | INT | | 样本量 |
| norm_source | VARCHAR(100) | | 常模来源 |
| create_time | DATETIME | NOT NULL | 创建时间 |

**索引**:
- idx_scale_id (scale_id)
- idx_group (scale_id, group_type, group_value)

#### 3.6.2 统计数据表 (ps_statistics)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 统计ID |
| stat_type | VARCHAR(50) | NOT NULL | 统计类型 |
| stat_date | DATE | NOT NULL | 统计日期 |
| dimension | VARCHAR(50) | | 维度 |
| dimension_value | VARCHAR(100) | | 维度值 |
| metric_name | VARCHAR(50) | NOT NULL | 指标名 |
| metric_value | DECIMAL(20,2) | NOT NULL | 指标值 |
| create_time | DATETIME | NOT NULL | 创建时间 |

**索引**:
- idx_stat_type (stat_type)
- idx_stat_date (stat_date)

## 4. ER关系图

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  sys_user │────▶│sys_enterprise│  │  sys_role │
└──────────┘     └──────────┘     └──────────┘
      │                                      │
      ▼                                      ▼
┌──────────┐     ┌──────────┐     ┌──────────┐
│sys_user   │     │sys_user   │     │sys_role   │
│ _role    │     │ _group   │     │_permission│
└──────────┘     └──────────┘     └──────────┘
                        │
                        ▼
                 ┌──────────┐
                 │sys_user   │
                 │_group    │
                 │ _member  │
                 └──────────┘

┌──────────┐     ┌──────────┐     ┌──────────┐
│ ps_scale │────▶│ps_scale  │────▶│ps_question│
│          │     │_dimension│     │          │
└──────────┘     └──────────┘     └──────────┘
                                             │
                                             ▼
                                      ┌──────────┐
                                      │ps_question│
                                      │ _option  │
                                      └──────────┘

┌──────────┐     ┌──────────┐     ┌──────────┐
│ ps_order │────▶│ps_order  │     │ps_refund │
│          │     │ _item    │     │          │
└──────────┘     └──────────┘     └──────────┘
      │
      ▼
┌──────────┐     ┌──────────┐
│sys_user   │     │sys_enterprise│
│ _quota   │     │  _quota   │
└──────────┘     └──────────┘

┌──────────┐     ┌──────────┐
│ps_assess │────▶│ps_answer │
│  ment    │     │ _record  │
│  _task   │     │          │
└──────────┘     └──────────┘
      │
      ▼
┌──────────┐
│ps_report │
└──────────┘
```

---

*文档版本: 1.2*
*最后更新: 2026-03-17*
*作者: Ryan*
