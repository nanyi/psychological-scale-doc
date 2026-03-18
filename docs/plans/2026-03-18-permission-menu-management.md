# 权限菜单管理与角色分配实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** 在管理后台项目中实现权限菜单管理和角色权限分配功能

**Architecture:** 
- 菜单管理：复用权限表(Permission)存储菜单数据，提供树形CRUD管理界面
- 角色分配：在用户列表中添加角色分配功能，支持多角色选择

**Tech Stack:** Vue 3.4 + Element Plus + TypeScript

---

## 待实现功能

### 1. 菜单管理页面
- 使用权限表存储菜单（type=1为菜单）
- 树形表格展示菜单结构
- 支持菜单的增删改查、排序、启用禁用

### 2. 角色权限分配
- 在用户列表中添加"分配角色"操作
- 弹窗展示角色列表，支持多选
- 保存用户角色关联

---

## Task 1: 菜单管理页面

**Files:**
- Modify: `frontend/src/api/role.ts` - 扩展权限API
- Create: `frontend/src/views/user/MenuList.vue` - 菜单管理页面
- Modify: `frontend/src/router/index.ts` - 添加路由
- Modify: `frontend/src/layouts/MainLayout.vue` - 添加菜单

**实现内容：**

### 1.1 扩展API模块
在 `role.ts` 中添加菜单相关接口：
- 获取菜单列表（树形）
- 获取菜单详情
- 创建菜单
- 更新菜单
- 删除菜单
- 菜单排序

### 1.2 创建菜单管理页面
- 树形表格展示菜单
- 工具栏：新增根菜单、新增子菜单
- 列：菜单名称、图标、路由路径、组件、排序、状态、操作
- 操作：编辑、删除、上移、下移

### 1.3 路由和菜单
- 路由：`/user/menu`
- 菜单：在用户管理子菜单添加"菜单管理"

---

## Task 2: 角色权限分配

**Files:**
- Modify: `frontend/src/api/user.ts` - 添加角色分配API
- Modify: `frontend/src/views/user/UserList.vue` - 添加分配角色功能

**实现内容：**

### 2.1 扩展用户API
添加接口：
- 获取用户角色列表
- 分配角色

### 2.2 用户列表改造
- 在操作栏添加"分配角色"按钮
- 弹窗展示所有角色，支持多选
- 保存用户角色关联

---

## 实施顺序

1. Task 1: 菜单管理页面
2. Task 2: 角色权限分配
3. 构建验证并提交
