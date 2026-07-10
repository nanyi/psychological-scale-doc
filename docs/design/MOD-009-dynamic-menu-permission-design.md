# 管理后台动态菜单权限设计方案

> **文档版本**: 1.0
> **创建日期**: 2026-07-10
> **作者**: Ryan
> **状态**: 待实施
> **模块编号**: MOD-009

---

## 一、背景与目标

### 1.1 问题现状

| 问题 | 说明 |
|------|------|
| 左侧菜单没有按权限显示 | 菜单硬编码在 MainLayout.vue 中，所有登录用户看到相同菜单 |
| 没有加载管理后台配置的权限 | 登录后未获取用户权限，`/api/auth/permissions` 接口不存在 |
| 权限表字段不完整 | 缺少菜单渲染所需的 component、visible、keep_alive 等字段 |

### 1.2 整改目标

1. 新增 `GET /api/auth/permissions` 接口，返回用户信息、角色、权限标识、菜单树
2. 前端动态渲染菜单，根据用户权限过滤显示
3. 保留硬编码默认菜单（数据驾驶舱）
4. 支持外链菜单（`is_frame=1` 时新窗口打开）
5. 权限管理页面支持新增字段的编辑

---

## 二、数据结构设计

### 2.1 数据库变更

#### 2.1.1 sys_permission 表新增字段

```sql
ALTER TABLE sys_permission 
ADD COLUMN `component` VARCHAR(255) NULL COMMENT '组件路径' AFTER `path`,
ADD COLUMN `component_name` VARCHAR(100) NULL COMMENT '组件名' AFTER `component`,
ADD COLUMN `visible` TINYINT NOT NULL DEFAULT 1 COMMENT '是否可见: 0-隐藏, 1-显示' AFTER `component_name`,
ADD COLUMN `keep_alive` TINYINT NOT NULL DEFAULT 1 COMMENT '是否缓存: 0-不缓存, 1-缓存' AFTER `visible`,
ADD COLUMN `always_show` TINYINT NOT NULL DEFAULT 1 COMMENT '是否总是显示: 0-否, 1-是' AFTER `keep_alive`,
ADD COLUMN `is_frame` TINYINT NOT NULL DEFAULT 0 COMMENT '是否外链: 0-否, 1-是' AFTER `always_show`,
ADD COLUMN `query_param` VARCHAR(500) NULL COMMENT '路由参数: POST为JSON, GET/WIN为querystring' AFTER `is_frame`;
```

#### 2.1.2 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| component | VARCHAR(255) | 前端组件路径，如 `/user/index` |
| component_name | VARCHAR(100) | 前端组件名称，如 `UserList` |
| visible | TINYINT | 是否可见: 0-隐藏, 1-显示 |
| keep_alive | TINYINT | 是否缓存: 0-不缓存, 1-缓存 |
| always_show | TINYINT | 是否总是显示: 0-否, 1-是 |
| is_frame | TINYINT | 是否外链: 0-否, 1-是 |
| query_param | VARCHAR(500) | 路由参数: POST时为JSON，GET/WIN时为querystring |

### 2.2 权限数据初始化

#### 2.2.1 完整字段顺序

```
permission_name, permission_code, permission_type, parent_id, module, sort_order,
component, component_name, icon, visible, keep_alive, always_show, is_frame, query_param
```

#### 2.2.2 初始化数据模块

| 模块 | 说明 |
|------|------|
| 用户管理 | 用户列表、用户新增、用户编辑、用户删除 |
| 量表管理 | 量表列表、分类管理、测评记录 |
| 订单管理 | 订单列表、企业配额 |
| 报告管理 | 报告列表 |
| 数据分析 | 数据分析 |
| 第三方服务 | API配置、同步日志、服务监控 |
| 系统设置 | 系统配置、登录日志、在线会话、登录策略 |

---

## 三、后端 DTO 设计

### 3.1 UserPermissionsResponse

**文件路径**：`backend/smart-system/smart-system-server/src/main/java/com/iotsic/smart/system/dto/UserPermissionsResponse.java`

```java
package com.iotsic.smart.system.dto;

import lombok.Data;
import java.util.List;
import java.util.Set;

@Data
public class UserPermissionsResponse {

    private UserVO user;
    private RoleVO role;
    private Set<String> permissions;
    private List<MenuVO> menuTree;

    @Data
    public static class UserVO {
        private Long userId;
        private String username;
        private String nickname;
        private String avatar;
        private Long departmentId;
        private String departmentName;
        private Long enterpriseId;
        private String enterpriseName;
    }

    @Data
    public static class RoleVO {
        private Long roleId;
        private String roleName;
    }

    @Data
    public static class MenuVO {
        private Long menuId;
        private String menuCode;
        private Long parentId;
        private String menuName;
        private Integer menuType;
        private String path;
        private String method;
        private String component;
        private String componentName;
        private String icon;
        private Integer visible;
        private Integer keepAlive;
        private Integer alwaysShow;
        private Integer isFrame;
        private String queryParam;
        private List<MenuVO> children;
    }
}
```

---

## 四、接口设计

### 4.1 新增接口

#### GET /api/auth/permissions

**功能**：获取当前登录用户的完整权限信息

**请求头**：需要携带有效 Token

**响应**：
```json
{
  "code": 200,
  "data": {
    "user": {
      "userId": 1,
      "username": "admin",
      "nickname": "系统管理员",
      "avatar": "https://xxx.com/avatar.png",
      "departmentId": 5,
      "departmentName": "研发部",
      "enterpriseId": 1,
      "enterpriseName": "深圳市心理健康科技有限公司"
    },
    "role": {
      "roleId": 1,
      "roleName": "超级管理员"
    },
    "permissions": ["user:list", "user:add", "scale:list"],
    "menuTree": [
      {
        "menuId": 1,
        "menuCode": "user:manage",
        "parentId": null,
        "menuName": "用户管理",
        "menuType": 1,
        "path": "/user",
        "method": "get",
        "component": "Layout",
        "componentName": "UserLayout",
        "icon": "User",
        "visible": 1,
        "keepAlive": 1,
        "alwaysShow": 1,
        "isFrame": 0,
        "queryParam": null,
        "children": [
          {
            "menuId": 2,
            "menuCode": "user:list",
            "parentId": 1,
            "menuName": "用户列表",
            "menuType": 2,
            "path": "/user",
            "method": "get",
            "component": "/user/index",
            "componentName": "UserList",
            "icon": "List",
            "visible": 1,
            "keepAlive": 1,
            "alwaysShow": 0,
            "isFrame": 0,
            "queryParam": null,
            "children": []
          }
        ]
      },
      {
        "menuId": 100,
        "menuCode": "external:doc",
        "parentId": null,
        "menuName": "帮助文档",
        "menuType": 2,
        "path": "https://docs.example.com",
        "method": "win",
        "component": null,
        "componentName": null,
        "icon": "Document",
        "visible": 1,
        "keepAlive": 0,
        "alwaysShow": 0,
        "isFrame": 1,
        "queryParam": null,
        "children": []
      }
    ]
  }
}
```

---

## 五、前端设计

### 5.1 类型定义

#### api/user.ts 新增类型

```typescript
export interface UserPermissionsResponse {
  user: {
    userId: number
    username: string
    nickname: string
    avatar: string
    departmentId: number
    departmentName: string
    enterpriseId: number
    enterpriseName: string
  }
  role: {
    roleId: number
    roleName: string
  }
  permissions: string[]
  menuTree: MenuItem[]
}

export interface MenuItem {
  menuId: number
  menuCode: string
  parentId: number | null
  menuName: string
  menuType: 1 | 2
  path: string
  method: 'get' | 'post' | 'win'
  component: string
  componentName: string
  icon: string
  visible: 0 | 1
  keepAlive: 0 | 1
  alwaysShow: 0 | 1
  isFrame: 0 | 1
  queryParam: string | null
  children: MenuItem[]
}
```

### 5.2 状态管理

#### stores/auth.ts 变更

```typescript
// 新增状态
const permissions = ref<string[]>([])
const menuTree = ref<MenuItem[]>([])

// 新增方法
const setPermissions = (perms: string[]) => { ... }
const setMenuTree = (menus: MenuItem[]) => { ... }
const hasPermission = (code: string) => permissions.value.includes(code)
const loadUserPermissions = async () => {
  const data = await getUserPermissions()
  setPermissions(data.permissions)
  setMenuTree(data.menuTree)
}
```

### 5.3 动态菜单渲染

#### MainLayout.vue 逻辑

```vue
<template>
  <el-menu ...>
    <!-- 硬编码默认菜单 -->
    <el-menu-item index="/dashboard">
      <span>数据驾驶舱</span>
    </el-menu-item>
    
    <!-- 动态菜单 -->
    <template v-for="menu in dynamicMenus" :key="menu.menuId">
      <!-- 目录类型（有子菜单） -->
      <el-sub-menu v-if="menu.children?.length && menu.alwaysShow === 1" :index="String(menu.menuId)">
        <template #title>
          <el-icon><component :is="menu.icon" /></el-icon>
          <span>{{ menu.menuName }}</span>
        </template>
        <el-menu-item 
          v-for="child in menu.children" 
          :key="child.menuId" 
          :index="child.path"
          @click="handleMenuClick(child)"
        >
          <span>{{ child.menuName }}</span>
        </el-menu-item>
      </el-sub-menu>
      
      <!-- 普通菜单（非外链） -->
      <el-menu-item 
        v-else-if="menu.visible === 1 && menu.isFrame === 0"
        :index="menu.path"
        @click="handleMenuClick(menu)"
      >
        <span>{{ menu.menuName }}</span>
      </el-menu-item>
      
      <!-- 外链菜单 -->
      <el-menu-item 
        v-else-if="menu.visible === 1 && menu.isFrame === 1"
        @click="handleMenuClick(menu)"
      >
        <span>{{ menu.menuName }}</span>
        <el-icon class="el-icon--right"><Link /></el-icon>
      </el-menu-item>
    </template>
  </el-menu>
</template>

<script setup lang="ts">
const dynamicMenus = computed(() => authStore.menuTree.filter(m => m.visible === 1))

const handleMenuClick = (menu: MenuItem) => {
  if (menu.isFrame === 1) {
    if (menu.method === 'win' || menu.method === 'get') {
      window.open(menu.path, '_blank')
    } else if (menu.method === 'post') {
      submitFormPost(menu.path, menu.queryParam)
    }
  } else {
    router.push(menu.path)
  }
}

const submitFormPost = (url: string, params: string) => {
  const form = document.createElement('form')
  form.method = 'POST'
  form.action = url
  form.target = '_blank'
  const data = JSON.parse(params || '{}')
  for (const key in data) {
    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = key
    input.value = data[key]
    form.appendChild(input)
  }
  document.body.appendChild(form)
  form.submit()
  document.body.removeChild(form)
}
</script>
```

### 5.4 路由守卫

#### router/index.ts

```typescript
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  authStore.initFromStorage()

  if (to.meta.requiresAuth && !authStore.isLoggedIn) {
    next('/login')
  } else if (to.meta.permission && !authStore.hasPermission(to.meta.permission)) {
    ElMessage.error('您没有访问该页面的权限')
    next('/dashboard')
  } else {
    next()
  }
})
```

### 5.5 权限管理页面

#### PermissionList.vue 新增字段

| 字段名 | 表单类型 | 说明 |
|--------|----------|------|
| component_name | el-input | 组件名称 |
| visible | el-switch | 是否可见 |
| keep_alive | el-switch | 是否缓存 |
| always_show | el-switch | 是否总是显示 |
| is_frame | el-switch | 是否外链 |
| query_param | el-input | 路由参数 |
| method | el-select | get/post/win |

---

## 六、字段说明

### 6.1 菜单字段

| 字段 | 说明 | 取值 |
|------|------|------|
| menuType | 菜单类型 | 1-目录, 2-菜单 |
| path | 路由地址 | 内部路径或外链URL |
| method | 请求方式 | get/post/win |
| component | 组件路径 | 前端 .vue 文件路径 |
| componentName | 组件名 | 前端组件 name |
| icon | 菜单图标 | Element Plus 图标名 |
| visible | 是否可见 | 0-隐藏, 1-显示 |
| keepAlive | 是否缓存 | 0-不缓存, 1-缓存 |
| alwaysShow | 是否总是显示 | 0-否, 1-是 |
| isFrame | 是否外链 | 0-否, 1-是 |
| queryParam | 路由参数 | POST时为JSON，GET/WIN时为querystring |

### 6.2 外链打开规则

| method | isFrame | 打开方式 |
|--------|---------|---------|
| get | 1 | `window.open(path, '_blank')` |
| post | 1 | form POST 提交，新窗口打开 |
| win | 1 | `window.open(path, '_blank')` |
| get/post | 0 | Vue Router 内嵌跳转 |

---

## 七、文件变更清单

### 7.1 后端文件

| 序号 | 文件路径 | 变更类型 | 变更说明 |
|------|----------|----------|----------|
| 1 | `docs/scripts/init-database.sql` | 修改 | sys_permission 表新增7个字段 |
| 2 | `docs/scripts/init-data.sql` | 修改 | 权限数据补充完整字段 |
| 3 | `backend/.../entity/permission/Permission.java` | 修改 | 新增7个字段属性 |
| 4 | `backend/.../dto/UserPermissionsResponse.java` | 新建 | 用户权限响应DTO |
| 5 | `backend/.../service/permission/PermissionService.java` | 修改 | 新增 getUserMenuTree、getUserPermissionCodes |
| 6 | `backend/.../service/permission/PermissionServiceImpl.java` | 修改 | 实现菜单树和权限码查询 |
| 7 | `backend/.../service/permission/RoleService.java` | 修改 | 新增 getUserRole |
| 8 | `backend/.../service/permission/RoleServiceImpl.java` | 修改 | 实现获取用户角色 |
| 9 | `backend/.../controller/AuthController.java` | 修改 | 新增 GET /api/auth/permissions |

### 7.2 前端文件

| 序号 | 文件路径 | 变更类型 | 变更说明 |
|------|----------|----------|----------|
| 1 | `frontend/src/api/user.ts` | 修改 | 新增 UserPermissionsResponse、MenuItem 类型 |
| 2 | `frontend/src/stores/auth.ts` | 修改 | 新增状态和方法 |
| 3 | `frontend/src/layouts/MainLayout.vue` | 修改 | 动态菜单渲染、外链处理 |
| 4 | `frontend/src/router/index.ts` | 修改 | 权限守卫检查 |
| 5 | `frontend/src/views/user/PermissionList.vue` | 修改 | 新增7个表单字段 |

---

## 八、注意事项

1. **数据库 ALTER TABLE**：需在测试环境先执行，确认无误后在生产执行
2. **外链 POST**：需前端动态创建 form 提交，如用户浏览器阻止弹出窗口需提示
3. **硬编码菜单**：数据驾驶舱始终显示，不需要权限验证
4. **向后兼容**：已登录用户需刷新页面或重新登录才能加载新权限接口
5. **部门/企业名称**：通过 DepartmentService.getDepartmentById 和 EnterpriseService.getEnterpriseById 关联查询
