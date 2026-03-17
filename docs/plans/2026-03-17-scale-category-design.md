# 量表分类管理功能设计

## 1. 概述

### 1.1 背景

当前系统使用枚举 `ScaleCategoryEnum` 硬编码量表分类，无法支持管理员动态管理分类。需求变更为创建独立的量表分类表，支持二级分类结构，并通过后台动态管理。

### 1.2 目标

- 创建量表分类表，支持二级分类
- 提供分类的增删改查 API
- 调整量表表关联分类ID
- 前端支持分类管理和展示

---

## 2. 数据库设计

### 2.1 新增表：ps_scale_category

```sql
CREATE TABLE IF NOT EXISTS ps_scale_category (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    category_name VARCHAR(100) NOT NULL COMMENT '分类名称',
    parent_id BIGINT NOT NULL DEFAULT 0 COMMENT '父分类ID（0=一级分类）',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    remark VARCHAR(500) COMMENT '备注',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0-禁用,1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-正常,1-删除',
    INDEX idx_parent_id (parent_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='量表分类表';
```

### 2.2 修改表：ps_scale

| 操作 | 字段变更 |
|------|----------|
| 删除 | category VARCHAR(50) |
| 新增 | category_id BIGINT COMMENT '分类ID' |

---

## 3. 后端设计

### 3.1 模块结构

在 `ps-scale` 服务中新增分类管理功能：

```
ps-scale/
├── controller/
│   └── ScaleCategoryController.java    # 分类管理控制器
├── service/
│   ├── ScaleCategoryService.java       # 分类服务接口
│   └── ScaleCategoryServiceImpl.java   # 分类服务实现
├── mapper/
│   └── ScaleCategoryMapper.java        # 分类Mapper
└── entity/
    └── ScaleCategory.java               # 分类实体
```

### 3.2 实体设计

**ScaleCategory.java**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Long | 分类ID |
| categoryName | String | 分类名称 |
| parentId | Long | 父分类ID |
| sortOrder | Integer | 排序 |
| remark | String | 备注 |
| status | Integer | 状态 |
| createTime | LocalDateTime | 创建时间 |
| updateTime | LocalDateTime | 更新时间 |
| deleted | Integer | 逻辑删除 |

### 3.3 API 设计

| 接口路径 | 方法 | 说明 | 请求体/参数 |
|----------|------|------|-------------|
| /api/scale-category/list | GET | 分类列表（树形） | - |
| /api/scale-category/all | GET | 所有分类（下拉用） | - |
| /api/scale-category/create | POST | 新增分类 | ScaleCategoryRequest |
| /api/scale-category/update/{id} | PUT | 更新分类 | ScaleCategoryRequest |
| /api/scale-category/delete/{id} | DELETE | 删除分类 | - |

**ScaleCategoryRequest.java**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| categoryName | String | 是 | 分类名称 |
| parentId | Long | 否 | 父分类ID（不填或0为一级分类） |
| sortOrder | Integer | 否 | 排序 |
| remark | String | 否 | 备注 |
| status | Integer | 否 | 状态（默认1） |

### 3.4 Scale 实体调整

| 字段 | 变更 |
|------|------|
| category | 删除（Integer） |
| categoryId | 新增（Long），关联 ps_scale_category.id |

---

## 4. 前端设计

### 4.1 页面设计

| 页面 | 路径 | 说明 |
|------|------|------|
| 分类管理 | /scale/category | 树形列表，支持增删改 |

### 4.2 组件设计

**ScaleCategoryList.vue**
- 树形表格展示分类
- 支持新增、编辑、删除
- 状态启用/禁用

### 4.3 API 对接

| 接口 | 方法 | 说明 |
|------|------|------|
| getCategoryTree | GET /api/scale-category/list | 获取分类树 |
| getCategoryAll | GET /api/scale-category/all | 获取全部分类 |
| createCategory | POST /api/scale-category/create | 新增分类 |
| updateCategory | PUT /api/scale-category/update/{id} | 更新分类 |
| deleteCategory | DELETE /api/scale-category/delete/{id} | 删除分类 |

---

## 5. 数据初始化

### 5.1 初始化分类数据

```sql
-- 一级分类
INSERT INTO ps_scale_category (category_name, parent_id, sort_order, status) VALUES
('人格测评', 0, 1, 1),
('心理健康', 0, 2, 1),
('职业测评', 0, 3, 1),
('智力测评', 0, 4, 1),
('家庭测评', 0, 5, 1),
('教育测评', 0, 6, 1),
('临床测评', 0, 7, 1);

-- 二级分类示例
INSERT INTO ps_scale_category (category_name, parent_id, sort_order, status) VALUES
('抑郁', 2, 1, 1),
('焦虑', 2, 2, 1),
('情绪管理', 2, 3, 1);
```

---

## 6. 版本兼容性

- 现有枚举 `ScaleCategoryEnum` 保留，作为预留
- 迁移期间支持 category（枚举值）和 categoryId（分类ID）双字段

---

## 7. 实施计划

1. 更新 init-database.sql 脚本
2. 更新 database-design.md 文档
3. 创建 ScaleCategory 实体
4. 创建 ScaleCategoryMapper
5. 创建 ScaleCategoryService 及实现
6. 创建 ScaleCategoryController
7. 调整 Scale 实体（移除 category，添加 categoryId）
8. 调整 ScaleService 和 ScaleController
9. 前端：创建分类管理页面
10. 前端：调整量表列表展示

---

## 8. 文档版本

| 版本 | 日期 | 作者 | 说明 |
|------|------|------|------|
| 1.0 | 2026-03-17 | Ryan | 初始版本 |

---

*文档创建时间: 2026-03-17*
*作者: Ryan*
