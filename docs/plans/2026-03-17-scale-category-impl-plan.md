# 量表分类管理功能实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 创建量表分类管理功能，包括数据库表、实体、Mapper、Service、Controller，以及前端页面

**Architecture:** 采用分层架构，Controller -> Service -> Mapper -> Entity，在 ps-scale 模块中新增分类管理功能

**Tech Stack:** Spring Boot 3.2.2, MyBatis-Plus, Vue 3, Element Plus

---

## 实施步骤

### Task 1: 更新数据库脚本和文档

**Files:**
- Modify: `docs/scripts/init-database.sql`
- Modify: `docs/design/database-design.md`

**Step 1: 在 init-database.sql 中添加量表分类表**

在 `-- 2. 量表模块表` 区域，在 ps_scale 表之前添加：

```sql
-- 量表分类表
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

**Step 2: 在 init-database.sql 中修改 ps_scale 表**

将 ps_scale 表中的 `category VARCHAR(50)` 改为 `category_id BIGINT`：

```sql
-- 量表表
CREATE TABLE IF NOT EXISTS ps_scale (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '量表ID',
    scale_code VARCHAR(32) NOT NULL UNIQUE COMMENT '量表编码',
    scale_name VARCHAR(200) NOT NULL COMMENT '量表名称',
    scale_name_en VARCHAR(200) COMMENT '英文名',
    category_id BIGINT COMMENT '分类ID',
    ...
```

**Step 3: 在 init-database.sql 末尾添加分类初始化数据**

在 `-- 7. 初始化数据` 区域末尾添加：

```sql
-- 初始化量表分类数据
INSERT INTO ps_scale_category (category_name, parent_id, sort_order, status) VALUES
('人格测评', 0, 1, 1),
('心理健康', 0, 2, 1),
('职业测评', 0, 3, 1),
('智力测评', 0, 4, 1),
('家庭测评', 0, 5, 1),
('教育测评', 0, 6, 1),
('临床测评', 0, 7, 1);

-- 初始化二级分类
INSERT INTO ps_scale_category (category_name, parent_id, sort_order, status) VALUES
('抑郁', 2, 1, 1),
('焦虑', 2, 2, 1),
('情绪管理', 2, 3, 1);
```

**Step 4: 更新 database-design.md**

添加 3.2.0 量表分类表章节，修改 ps_scale 表的 category 字段为 category_id

---

### Task 2: 创建 ScaleCategory 实体

**Files:**
- Create: `backend/ps-scale/src/main/java/com/iotsic/ps/scale/entity/ScaleCategory.java`

**Step 1: 创建 ScaleCategory 实体类**

```java
package com.iotsic.ps.scale.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 量表分类实体
 * 
 * @author Ryan
 * @since 2026-03-17
 */
@Data
@TableName("ps_scale_category")
public class ScaleCategory {

    /**
     * 分类ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 分类名称
     */
    private String categoryName;

    /**
     * 父分类ID（0=一级分类）
     */
    private Long parentId;

    /**
     * 排序
     */
    private Integer sortOrder;

    /**
     * 备注
     */
    private String remark;

    /**
     * 状态：0-禁用，1-启用
     */
    private Integer status;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /**
     * 逻辑删除：0-正常，1-删除
     */
    @TableLogic
    private Integer deleted;
}
```

---

### Task 3: 创建 ScaleCategoryMapper

**Files:**
- Create: `backend/ps-scale/src/main/java/com/iotsic/ps/scale/mapper/ScaleCategoryMapper.java`

**Step 1: 创建 ScaleCategoryMapper 接口**

```java
package com.iotsic.ps.scale.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.iotsic.ps.scale.entity.ScaleCategory;
import org.apache.ibatis.annotations.Mapper;

/**
 * 量表分类Mapper
 * 
 * @author Ryan
 * @since 2026-03-17
 */
@Mapper
public interface ScaleCategoryMapper extends BaseMapper<ScaleCategory> {
}
```

---

### Task 4: 创建 ScaleCategoryService

**Files:**
- Create: `backend/ps-scale/src/main/java/com/iotsic/ps/scale/service/ScaleCategoryService.java`
- Create: `backend/ps-scale/src/main/java/com/iotsic/ps/scale/service/ScaleCategoryServiceImpl.java`

**Step 1: 创建 ScaleCategoryService 接口**

```java
package com.iotsic.ps.scale.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.iotsic.ps.scale.entity.ScaleCategory;

import java.util.List;

/**
 * 量表分类服务接口
 * 
 * @author Ryan
 * @since 2026-03-17
 */
public interface ScaleCategoryService extends IService<ScaleCategory> {

    /**
     * 获取分类树形列表
     * 
     * @return 分类树
     */
    List<ScaleCategory> getCategoryTree();

    /**
     * 获取所有启用的分类（下拉选择用）
     * 
     * @return 分类列表
     */
    List<ScaleCategory> getAllEnabled();
}
```

**Step 2: 创建 ScaleCategoryServiceImpl 实现类**

```java
package com.iotsic.ps.scale.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.iotsic.ps.scale.entity.ScaleCategory;
import com.iotsic.ps.scale.mapper.ScaleCategoryMapper;
import com.iotsic.ps.scale.service.ScaleCategoryService;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 量表分类服务实现
 * 
 * @author Ryan
 * @since 2026-03-17
 */
@Service
public class ScaleCategoryServiceImpl extends ServiceImpl<ScaleCategoryMapper, ScaleCategory> 
    implements ScaleCategoryService {

    @Override
    public List<ScaleCategory> getCategoryTree() {
        List<ScaleCategory> allCategories = list(
            new LambdaQueryWrapper<ScaleCategory>()
                .eq(ScaleCategory::getStatus, 1)
                .orderByAsc(ScaleCategory::getSortOrder)
        );
        
        if (CollectionUtils.isEmpty(allCategories)) {
            return new ArrayList<>();
        }
        
        // 获取一级分类
        List<ScaleCategory> rootCategories = allCategories.stream()
            .filter(c -> c.getParentId() == null || c.getParentId() == 0)
            .collect(Collectors.toList());
        
        // 递归构建树形结构
        for (ScaleCategory root : rootCategories) {
            buildTree(root, allCategories);
        }
        
        return rootCategories;
    }

    private void buildTree(ScaleCategory parent, List<ScaleCategory> allCategories) {
        List<ScaleCategory> children = allCategories.stream()
            .filter(c -> parent.getId().equals(c.getParentId()))
            .collect(Collectors.toList());
        
        for (ScaleCategory child : children) {
            buildTree(child, allCategories);
        }
    }

    @Override
    public List<ScaleCategory> getAllEnabled() {
        return list(
            new LambdaQueryWrapper<ScaleCategory>()
                .eq(ScaleCategory::getStatus, 1)
                .orderByAsc(ScaleCategory::getSortOrder)
        );
    }
}
```

---

### Task 5: 创建 ScaleCategoryController

**Files:**
- Create: `backend/ps-scale/src/main/java/com/iotsic/ps/scale/controller/ScaleCategoryController.java`
- Create: `backend/ps-scale/src/main/java/com/iotsic/ps/scale/dto/ScaleCategoryRequest.java`

**Step 1: 创建 ScaleCategoryRequest 请求DTO**

```java
package com.iotsic.ps.scale.dto;

import lombok.Data;

/**
 * 量表分类请求DTO
 * 
 * @author Ryan
 * @since 2026-03-17
 */
@Data
public class ScaleCategoryRequest {

    /**
     * 分类名称
     */
    private String categoryName;

    /**
     * 父分类ID（0或不填为一级分类）
     */
    private Long parentId;

    /**
     * 排序
     */
    private Integer sortOrder;

    /**
     * 备注
     */
    private String remark;

    /**
     * 状态：0-禁用，1-启用
     */
    private Integer status;
}
```

**Step 2: 创建 ScaleCategoryController 控制器**

```java
package com.iotsic.ps.scale.controller;

import com.iotsic.ps.core.vo.RestResult;
import com.iotsic.ps.scale.dto.ScaleCategoryRequest;
import com.iotsic.ps.scale.entity.ScaleCategory;
import com.iotsic.ps.scale.service.ScaleCategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 量表分类控制器
 * 
 * @author Ryan
 * @since 2026-03-17
 */
@RestController
@RequestMapping("/api/scale-category")
@RequiredArgsConstructor
@Tag(name = "量表分类管理")
public class ScaleCategoryController {

    private final ScaleCategoryService scaleCategoryService;

    @GetMapping("/list")
    @Operation(summary = "获取分类树形列表")
    public RestResult<List<ScaleCategory>> getCategoryTree() {
        return RestResult.success(scaleCategoryService.getCategoryTree());
    }

    @GetMapping("/all")
    @Operation(summary = "获取所有分类（下拉选择用）")
    public RestResult<List<ScaleCategory>> getAllCategories() {
        return RestResult.success(scaleCategoryService.getAllEnabled());
    }

    @PostMapping("/create")
    @Operation(summary = "新增分类")
    public RestResult<Void> createCategory(@RequestBody ScaleCategoryRequest request) {
        ScaleCategory category = new ScaleCategory();
        category.setCategoryName(request.getCategoryName());
        category.setParentId(request.getParentId() == null ? 0L : request.getParentId());
        category.setSortOrder(request.getSortOrder() == null ? 0 : request.getSortOrder());
        category.setRemark(request.getRemark());
        category.setStatus(request.getStatus() == null ? 1 : request.getStatus());
        scaleCategoryService.save(category);
        return RestResult.success();
    }

    @PutMapping("/update/{id}")
    @Operation(summary = "更新分类")
    public RestResult<Void> updateCategory(@PathVariable Long id, @RequestBody ScaleCategoryRequest request) {
        ScaleCategory category = scaleCategoryService.getById(id);
        if (category == null) {
            return RestResult.fail("分类不存在");
        }
        category.setCategoryName(request.getCategoryName());
        if (request.getParentId() != null) {
            category.setParentId(request.getParentId());
        }
        if (request.getSortOrder() != null) {
            category.setSortOrder(request.getSortOrder());
        }
        category.setRemark(request.getRemark());
        if (request.getStatus() != null) {
            category.setStatus(request.getStatus());
        }
        scaleCategoryService.updateById(category);
        return RestResult.success();
    }

    @DeleteMapping("/delete/{id}")
    @Operation(summary = "删除分类")
    public RestResult<Void> deleteCategory(@PathVariable Long id) {
        // 检查是否有子分类
        long childCount = scaleCategoryService.count(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ScaleCategory>()
                .eq(ScaleCategory::getParentId, id)
        );
        if (childCount > 0) {
            return RestResult.fail("该分类下有子分类，无法删除");
        }
        // 检查是否有量表关联
        // TODO: 检查 ps_scale 表是否有数据关联此分类
        scaleCategoryService.removeById(id);
        return RestResult.success();
    }
}
```

---

### Task 6: 调整 Scale 实体

**Files:**
- Modify: `backend/ps-core/src/main/java/com/iotsic/ps/core/entity/Scale.java`

**Step 1: 修改 Scale 实体**

将 `category` Integer 改为 `categoryId` Long：

```java
/**
 * 分类ID
 */
private Long categoryId;
```

---

### Task 7: 调整 ScaleService 和相关DTO

**Files:**
- Modify: `backend/ps-scale/src/main/java/com/iotsic/ps/scale/service/ScaleService.java`
- Modify: `backend/ps-scale/src/main/java/com/iotsic/ps/scale/service/ScaleServiceImpl.java`
- Modify: `backend/ps-scale/src/main/java/com/iotsic/ps/scale/dto/ScaleCreateRequest.java`
- Modify: `backend/ps-scale/src/main/java/com/iotsic/ps/scale/dto/ScaleUpdateRequest.java`

**Step 1: 修改 ScaleCreateRequest**

将 `category` Integer 改为 `categoryId` Long

**Step 2: 修改 ScaleUpdateRequest**

将 `category` Integer 改为 `categoryId` Long

**Step 3: 修改 ScaleService 接口**

将方法参数中的 `Integer category` 改为 `Long categoryId`

**Step 4: 修改 ScaleServiceImpl 实现**

调整对应方法

---

### Task 8: 前端 - 创建分类管理页面

**Files:**
- Create: `frontend/src/views/scale/ScaleCategoryList.vue`
- Create: `frontend/src/api/scaleCategory.ts`

**Step 1: 创建 scaleCategory.ts API**

```typescript
import request from './index'

export interface ScaleCategory {
  id: number
  categoryName: string
  parentId: number
  sortOrder: number
  remark: string
  status: number
  createTime: string
  children?: ScaleCategory[]
}

export const getCategoryTree = () => {
  return request.get<ScaleCategory[]>('/scale-category/list')
}

export const getCategoryAll = () => {
  return request.get<ScaleCategory[]>('/scale-category/all')
}

export const createCategory = (data: Partial<ScaleCategory>) => {
  return request.post('/scale-category/create', data)
}

export const updateCategory = (id: number, data: Partial<ScaleCategory>) => {
  return request.put(`/scale-category/update/${id}`, data)
}

export const deleteCategory = (id: number) => {
  return request.delete(`/scale-category/delete/${id}`)
}
```

**Step 2: 创建 ScaleCategoryList.vue**

创建树形分类管理页面，支持：
- 树形表格展示
- 新增分类（可选择父分类）
- 编辑分类
- 删除分类
- 启用/禁用

---

### Task 9: 前端 - 调整量表列表

**Files:**
- Modify: `frontend/src/views/scale/ScaleList.vue`
- Modify: `frontend/src/api/scale.ts`

**Step 1: 修改 scale.ts**

调整 ScaleItem 接口，将 category 改为 categoryId 和 categoryName

**Step 2: 修改 ScaleList.vue**

调整搜索和展示逻辑

---

### Task 10: 编译验证

**Step 1: 后端编译**

```bash
cd backend && mvn compile
```

**Step 2: 前端构建**

```bash
cd frontend && npx vite build
```

---

## 实施完成

完成所有任务后，量表分类管理功能即可正常使用。
