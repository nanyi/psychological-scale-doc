# 数据库设计文档

## 1. 文档信息

| 属性 | 内容 |
|------|------|
| 文档类型 | 技术设计 |
| 版本 | 1.0 |
| 状态 | 已完成 |
| 创建日期 | 2026-03-09 |
| 最后更新 | 2026-03-09 |
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

## 3. 核心业务表设计

### 3.1 用户模块

#### 3.1.1 用户表 (ps_user)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 用户ID |
| username | VARCHAR(100) | UNIQUE, NOT NULL | 用户名 |
| password | VARCHAR(200) | NOT NULL | 密码（BCrypt加密） |
| nickname | VARCHAR(100) | | 昵称 |
| avatar | VARCHAR(500) | | 头像URL |
| phone | VARCHAR(20) | | 手机号 |
| email | VARCHAR(100) | | 邮箱 |
| user_type | TINYINT | NOT NULL | 用户类型：1-个人，2-企业 |
| enterprise_id | BIGINT | | 企业ID |
| status | TINYINT | NOT NULL DEFAULT 1 | 状态：0-禁用，1-正常 |
| last_login_time | DATETIME | | 最后登录时间 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |
| create_by | BIGINT | | 创建人 |
| update_by | BIGINT | | 更新人 |
| deleted | TINYINT | NOT NULL DEFAULT 0 | 逻辑删除 |

**索引**:
- idx_phone (phone)
- idx_enterprise_id (enterprise_id)

#### 3.1.2 企业表 (ps_enterprise)

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

#### 3.1.3 角色表 (ps_role)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 角色ID |
| role_name | VARCHAR(100) | NOT NULL | 角色名称 |
| role_code | VARCHAR(50) | UNIQUE, NOT NULL | 角色编码 |
| description | VARCHAR(500) | | 描述 |
| status | TINYINT | NOT NULL DEFAULT 1 | 状态：0-禁用，1-正常 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |

#### 3.1.4 用户角色关联表 (ps_user_role)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| role_id | BIGINT | NOT NULL | 角色ID |
| create_time | DATETIME | NOT NULL | 创建时间 |

**索引**:
- idx_user_id (user_id)
- idx_role_id (role_id)

#### 3.1.5 权限表 (ps_permission)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 权限ID |
| permission_name | VARCHAR(100) | NOT NULL | 权限名称 |
| permission_code | VARCHAR(100) | UNIQUE, NOT NULL | 权限编码 |
| permission_type | TINYINT | NOT NULL | 类型：1-功能，2-数据 |
| parent_id | BIGINT | | 父权限ID |
| module | VARCHAR(50) | | 所属模块 |
| create_time | DATETIME | NOT NULL | 创建时间 |

#### 3.1.6 角色权限关联表 (ps_role_permission)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | ID |
| role_id | BIGINT | NOT NULL | 角色ID |
| permission_id | BIGINT | NOT NULL | 权限ID |
| create_time | DATETIME | NOT NULL | 创建时间 |

#### 3.1.7 用户分组表 (ps_user_group)

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

#### 3.1.8 用户分组关联表 (ps_user_group_member)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | ID |
| group_id | BIGINT | NOT NULL | 分组ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| create_time | DATETIME | NOT NULL | 创建时间 |

### 3.2 量表模块

#### 3.2.1 量表表 (ps_scale)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK | 量表ID |
| scale_code | VARCHAR(32) | UNIQUE, NOT NULL | 量表编码 |
| scale_name | VARCHAR(200) | NOT NULL | 量表名称 |
| scale_name_en | VARCHAR(200) | | 英文名 |
| category | VARCHAR(50) | | 分类 |
| target_audience | VARCHAR(200) | | 适用人群 |
| description | TEXT | | 描述 |
| instruction | TEXT | | 指导语 |
| duration | INT | | 预计时长（分钟） |
| question_count | INT | | 题目数量 |
| dimension_count | INT | | 维度数量 |
| source_type | TINYINT | NOT NULL | 来源：1-内置，2-第三方，3-自定义 |
| third_party_id | VARCHAR(100) | | 第三方量表ID |
| platform_id | BIGINT | | 第三方平台ID |
| price | DECIMAL(10,2) | | 价格 |
| status | TINYINT | NOT NULL DEFAULT 0 | 状态：0-草稿，1-已发布，2-已下架 |
| create_time | DATETIME | NOT NULL | 创建时间 |
| update_time | DATETIME | | 更新时间 |
| create_by | BIGINT | | 创建人 |
| update_by | BIGINT | | 更新人 |
| deleted | TINYINT | NOT NULL DEFAULT 0 | 逻辑删除 |

**索引**:
- idx_category (category)
- idx_source_type (source_type)

#### 3.2.2 量表维度表 (ps_scale_dimension)

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

#### 3.2.3 量表因子表 (ps_scale_factor)

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

#### 3.2.4 题目表 (ps_question)

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

#### 3.2.5 选项表 (ps_question_option)

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

#### 3.2.6 测评任务表 (ps_assessment_task)

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

#### 3.2.7 答题记录表 (ps_answer_record)

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

#### 3.3.3 退款记录表 (ps_refund_record)

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

#### 3.3.4 用户配额表 (ps_user_quota)

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

#### 3.3.5 企业配额表 (ps_enterprise_quota)

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
│  ps_user │────▶│ps_enterprise│  │  ps_role │
└──────────┘     └──────────┘     └──────────┘
      │                                      │
      ▼                                      ▼
┌──────────┐     ┌──────────┐     ┌──────────┐
│ps_user   │     │ps_user   │     │ps_role   │
│ _role    │     │ _group   │     │_permission│
└──────────┘     └──────────┘     └──────────┘
                        │
                        ▼
                 ┌──────────┐
                 │ps_user   │
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
│          │     │ _item    │     │ _record  │
└──────────┘     └──────────┘     └──────────┘
      │
      ▼
┌──────────┐     ┌──────────┐
│ps_user   │     │ps_enterprise│
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

*文档版本: 1.1*
*最后更新: 2026-03-11*
*作者: Ryan*
