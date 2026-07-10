# 管理后台动态菜单权限实施计划

> **文档版本**: 1.0
> **创建日期**: 2026-07-10
> **作者**: Ryan
> **状态**: 待实施
> **参考设计**: `docs/design/MOD-009-dynamic-menu-permission-design.md`

---

## 一、实施概览

| 项目 | 说明 |
|------|------|
| 目标 | 实现管理后台动态菜单权限功能 |
| 涉及模块 | 后端 smart-system、前端 frontend |
| 数据库变更 | sys_permission 表新增 7 个字段 |
| 新增接口 | GET /api/auth/permissions |

---

## 二、实施阶段

### Phase 1: 数据库变更

| 步骤 | 任务 | 涉及文件 | 状态 |
|------|------|----------|------|
| 1.1 | 更新 init-database.sql，sys_permission 表新增 component、component_name、visible、keep_alive、always_show、is_frame、query_param 7个字段 | `docs/scripts/init-database.sql` | 待执行 |
| 1.2 | 更新 init-data.sql，权限数据初始化（用户管理、量表、订单、报告、数据分析、第三方服务、系统设置等模块），补充完整字段 | `docs/scripts/init-data.sql` | 待执行 |

### Phase 2: 后端实体和DTO

| 步骤 | 任务 | 涉及文件 | 状态 |
|------|------|----------|------|
| 2.1 | 修改 Permission.java，新增 component、componentName、visible、keepAlive、alwaysShow、isFrame、queryParam 7个字段 | `backend/smart-system/smart-system-server/src/main/java/com/iotsic/smart/system/entity/permission/Permission.java` | 待执行 |
| 2.2 | 新建 UserPermissionsResponse.java，包含内部类 UserVO、RoleVO、MenuVO | `backend/smart-system/smart-system-server/src/main/java/com/iotsic/smart/system/dto/UserPermissionsResponse.java` | 待执行 |

### Phase 3: 后端服务层

| 步骤 | 任务 | 涉及文件 | 状态 |
|------|------|----------|------|
| 3.1 | 修改 PermissionService 接口，新增 getUserMenuTree(Long userId) 和 getUserPermissionCodes(Long userId) 方法 | `backend/smart-system/smart-system-server/src/main/java/com/iotsic/smart/system/service/permission/PermissionService.java` | 待执行 |
| 3.2 | 修改 PermissionServiceImpl，实现菜单树查询（过滤 visible=1，按 parentId 构建树形）和权限码查询 | `backend/smart-system/smart-system-server/src/main/java/com/iotsic/smart/system/service/permission/PermissionServiceImpl.java` | 待执行 |
| 3.3 | 修改 RoleService 接口，新增 getUserRole(Long userId) 方法 | `backend/smart-system/smart-system-server/src/main/java/com/iotsic/smart/system/service/permission/RoleService.java` | 待执行 |
| 3.4 | 修改 RoleServiceImpl，实现获取用户角色信息（通过用户ID查询关联角色） | `backend/smart-system/smart-system-server/src/main/java/com/iotsic/smart/system/service/permission/RoleServiceImpl.java` | 待执行 |

### Phase 4: 后端控制器

| 步骤 | 任务 | 涉及文件 | 状态 |
|------|------|----------|------|
| 4.1 | 修改 AuthController，新增 GET /api/auth/permissions 接口，实现：1) 从 SecurityContext 获取当前用户；2) 查询用户信息及部门、企业名称；3) 查询角色信息；4) 查询权限列表；5) 查询菜单树；6) 组装返回 | `backend/smart-system/smart-system-server/src/main/java/com/iotsic/smart/system/controller/AuthController.java` | 待执行 |

### Phase 5: 后端验证

| 步骤 | 任务 | 命令 | 状态 |
|------|------|------|------|
| 5.1 | 后端编译验证 | `cd backend && mvn compile -DskipTests` | 待执行 |
| 5.2 | 提交后端代码 | git commit & push (backend) | 待执行 |

### Phase 6: 前端类型和状态

| 步骤 | 任务 | 涉及文件 | 状态 |
|------|------|----------|------|
| 6.1 | 修改 api/user.ts，新增 UserPermissionsResponse 和 MenuItem 类型定义 | `frontend/src/api/user.ts` | 待执行 |
| 6.2 | 修改 stores/auth.ts，新增 permissions、menuTree 状态；新增 setPermissions、setMenuTree、hasPermission、loadUserPermissions 方法；修改 login 和 initFromStorage 方法调用 loadUserPermissions | `frontend/src/stores/auth.ts` | 待执行 |
| 6.3 | 前端编译验证 | `cd frontend && npm run build` | 待执行 |

### Phase 7: 前端UI

| 步骤 | 任务 | 涉及文件 | 状态 |
|------|------|----------|------|
| 7.1 | 修改 MainLayout.vue，保留硬编码默认菜单（数据驾驶舱），动态渲染 menuTree，过滤 visible=1，处理外链菜单点击（isFrame=1 时新窗口打开，POST 外链用 form 提交） | `frontend/src/layouts/MainLayout.vue` | 待执行 |
| 7.2 | 修改 router/index.ts，路由守卫增加权限检查，无权限时跳转首页并提示 | `frontend/src/router/index.ts` | 待执行 |
| 7.3 | 修改 PermissionList.vue，新增 component_name、visible、keep_alive、always_show、is_frame、query_param、method 7个表单字段的编辑支持 | `frontend/src/views/user/PermissionList.vue` | 待执行 |

### Phase 8: 前端验证和提交

| 步骤 | 任务 | 命令 | 状态 |
|------|------|------|------|
| 8.1 | 前端构建验证 | `cd frontend && npm run build` | 待执行 |
| 8.2 | 提交前端代码 | git commit & push (frontend) | 待执行 |

---

## 三、详细实施步骤

### 3.1 Phase 1 详细步骤

#### 1.1 更新 init-database.sql

在 `sys_permission` 表定义中新增 7 个字段：

```sql
-- 在 path 字段后添加
`component` VARCHAR(255) NULL COMMENT '组件路径',
`component_name` VARCHAR(100) NULL COMMENT '组件名',
-- 在 sort_order 字段后添加（如果是 ALTER TABLE）
ALTER TABLE sys_permission 
ADD COLUMN `component` VARCHAR(255) NULL COMMENT '组件路径' AFTER `path`,
ADD COLUMN `component_name` VARCHAR(100) NULL COMMENT '组件名' AFTER `component`,
ADD COLUMN `visible` TINYINT NOT NULL DEFAULT 1 COMMENT '是否可见: 0-隐藏, 1-显示' AFTER `component_name`,
ADD COLUMN `keep_alive` TINYINT NOT NULL DEFAULT 1 COMMENT '是否缓存: 0-不缓存, 1-缓存' AFTER `visible`,
ADD COLUMN `always_show` TINYINT NOT NULL DEFAULT 1 COMMENT '是否总是显示: 0-否, 1-是' AFTER `keep_alive`,
ADD COLUMN `is_frame` TINYINT NOT NULL DEFAULT 0 COMMENT '是否外链: 0-否, 1-是' AFTER `always_show`,
ADD COLUMN `query_param` VARCHAR(500) NULL COMMENT '路由参数' AFTER `is_frame`;
```

#### 1.2 更新 init-data.sql

更新权限 INSERT 语句，补充完整字段值：

```sql
INSERT INTO sys_permission (permission_name, permission_code, permission_type, parent_id, module, sort_order, component, component_name, icon, visible, keep_alive, always_show, is_frame, query_param) VALUES
-- 用户管理模块
('用户管理', 'user:manage', 1, NULL, 'MOD-001', 1, 'Layout', 'UserLayout', 'User', 1, 1, 1, 0, NULL),
('用户列表', 'user:list', 2, 1, 'MOD-001', 1, '/user/index', 'UserList', 'List', 1, 1, 0, 0, NULL),
-- ... 其他模块
```

### 3.2 Phase 2 详细步骤

#### 2.1 修改 Permission.java

```java
// 新增字段
private String component;      // 组件路径
private String componentName;  // 组件名
private Integer visible;       // 是否可见: 0-隐藏, 1-显示
private Integer keepAlive;      // 是否缓存: 0-不缓存, 1-缓存
private Integer alwaysShow;      // 是否总是显示: 0-否, 1-是
private Integer isFrame;        // 是否外链: 0-否, 1-是
private String queryParam;    // 路由参数
```

#### 2.2 新建 UserPermissionsResponse.java

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

### 3.3 Phase 3 详细步骤

#### 3.1 PermissionService.java 新增方法

```java
/**
 * 获取用户有权限访问的菜单树
 * @param userId 用户ID
 * @return 菜单树列表
 */
List<Permission> getUserMenuTree(Long userId);

/**
 * 获取用户的所有权限编码列表
 * @param userId 用户ID
 * @return 权限编码集合
 */
Set<String> getUserPermissionCodes(Long userId);
```

#### 3.2 PermissionServiceImpl 实现

```java
@Override
public List<Permission> getUserMenuTree(Long userId) {
    // 1. 获取用户角色
    List<Role> roles = roleService.getEnableUserRoleListByUserIdFromCache(userId);
    if (CollUtil.isEmpty(roles)) {
        return Collections.emptyList();
    }
    
    // 2. 获取角色关联的权限列表
    Set<Long> roleIds = CollectionUtils.convertSet(roles, Role::getId);
    List<Permission> permissions = permissionMapper.selectListByRoleIds(roleIds);
    
    // 3. 过滤 visible=1 且 permissionType 为 1(目录) 或 2(菜单) 的权限
    List<Permission> menuPermissions = permissions.stream()
        .filter(p -> p.getVisible() == 1 && (p.getPermissionType() == 1 || p.getPermissionType() == 2))
        .collect(Collectors.toList());
    
    // 4. 按 parentId 构建树形结构
    return buildMenuTree(menuPermissions);
}

@Override
public Set<String> getUserPermissionCodes(Long userId) {
    List<Role> roles = roleService.getEnableUserRoleListByUserIdFromCache(userId);
    if (CollUtil.isEmpty(roles)) {
        return Collections.emptySet();
    }
    
    Set<Long> roleIds = CollectionUtils.convertSet(roles, Role::getId);
    List<Permission> permissions = permissionMapper.selectListByRoleIds(roleIds);
    
    return permissions.stream()
        .map(Permission::getPermissionCode)
        .collect(Collectors.toSet());
}

private List<Permission> buildMenuTree(List<Permission> permissions) {
    // 按 parentId 分组，构建树形
    Map<Long, List<Permission>> groupByParentId = permissions.stream()
        .collect(Collectors.groupingBy(p -> p.getParentId() == null ? 0L : p.getParentId()));
    
    // 递归构建子树
    // ...
}
```

#### 3.3 RoleService.java 新增方法

```java
/**
 * 获取用户角色信息
 * @param userId 用户ID
 * @return 角色信息
 */
Role getUserRole(Long userId);
```

#### 3.4 RoleServiceImpl 实现

```java
@Override
public Role getUserRole(Long userId) {
    List<Role> roles = getEnableUserRoleListByUserIdFromCache(userId);
    return CollUtil.isEmpty(roles) ? null : roles.get(0);
}
```

### 3.4 Phase 4 详细步骤

#### 4.1 AuthController.java 新增接口

```java
@GetMapping("/permissions")
public RestResult<UserPermissionsResponse> getUserPermissions() {
    // 1. 从 SecurityContext 获取当前登录用户
    LoginUser loginUser = SecurityUtils.getLoginUser();
    Long userId = loginUser.getUserId();
    
    // 2. 查询用户信息
    User user = userService.getUserById(userId);
    UserPermissionsResponse.UserVO userVO = new UserPermissionsResponse.UserVO();
    userVO.setUserId(user.getId());
    userVO.setUsername(user.getUsername());
    userVO.setNickname(user.getNickname());
    userVO.setAvatar(user.getAvatar());
    userVO.setDepartmentId(user.getDepartmentId());
    
    // 3. 查询部门名称
    if (user.getDepartmentId() != null) {
        Department dept = departmentService.getDepartmentById(user.getDepartmentId());
        if (dept != null) {
            userVO.setDepartmentName(dept.getDepartmentName());
        }
    }
    
    // 4. 查询企业名称
    if (user.getEnterpriseId() != null) {
        Enterprise enterprise = enterpriseService.getEnterpriseById(user.getEnterpriseId());
        if (enterprise != null) {
            userVO.setEnterpriseName(enterprise.getEnterpriseName());
        }
    }
    
    // 5. 查询角色信息
    Role role = roleService.getUserRole(userId);
    UserPermissionsResponse.RoleVO roleVO = new UserPermissionsResponse.RoleVO();
    if (role != null) {
        roleVO.setRoleId(role.getId());
        roleVO.setRoleName(role.getRoleName());
    }
    
    // 6. 查询权限列表
    Set<String> permissions = permissionService.getUserPermissionCodes(userId);
    
    // 7. 查询菜单树
    List<Permission> menuTree = permissionService.getUserMenuTree(userId);
    List<UserPermissionsResponse.MenuVO> menuVOList = convertToMenuVO(menuTree);
    
    // 8. 组装返回
    UserPermissionsResponse response = new UserPermissionsResponse();
    response.setUser(userVO);
    response.setRole(roleVO);
    response.setPermissions(permissions);
    response.setMenuTree(menuVOList);
    
    return RestResult.success(response);
}
```

### 3.5 Phase 6-7 前端详细步骤

#### 6.1 api/user.ts 新增类型

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

#### 6.2 stores/auth.ts 变更

```typescript
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login as loginApi, getUserPermissions, type LoginResponse, type UserPermissionsResponse } from '@/api/user'
import { ElMessage } from 'element-plus'
import router from '@/router'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string>(localStorage.getItem('admin_token') || '')
  const userInfo = ref<LoginResponse['user'] | null>(null)
  const permissions = ref<string[]>([])
  const menuTree = ref<MenuItem[]>([])

  const isLoggedIn = computed(() => !!token.value)

  const setToken = (newToken: string) => {
    token.value = newToken
    localStorage.setItem('admin_token', newToken)
  }

  const setUserInfo = (info: LoginResponse['user']) => {
    userInfo.value = info
  }

  const setPermissions = (perms: string[]) => {
    permissions.value = perms
  }

  const setMenuTree = (menus: MenuItem[]) => {
    menuTree.value = menus
  }

  const hasPermission = (code: string) => {
    return permissions.value.includes(code)
  }

  const loadUserPermissions = async () => {
    try {
      const data = await getUserPermissions()
      setPermissions(data.permissions)
      setMenuTree(data.menuTree)
    } catch (error) {
      console.error('加载用户权限失败:', error)
    }
  }

  const login = async (username: string, password: string) => {
    try {
      const data = await loginApi({ username, password })
      setToken(data.token)
      setUserInfo(data.user)
      await loadUserPermissions()
      ElMessage.success('登录成功')
      return true
    } catch (error) {
      return false
    }
  }

  const logout = () => {
    token.value = ''
    userInfo.value = null
    permissions.value = []
    menuTree.value = []
    localStorage.removeItem('admin_token')
    router.push('/login')
  }

  const initFromStorage = () => {
    const storedToken = localStorage.getItem('admin_token')
    if (storedToken) {
      token.value = storedToken
      loadUserPermissions()
    }
  }

  return {
    token,
    userInfo,
    permissions,
    menuTree,
    isLoggedIn,
    setToken,
    setUserInfo,
    setPermissions,
    setMenuTree,
    hasPermission,
    loadUserPermissions,
    login,
    logout,
    initFromStorage
  }
})
```

#### 7.1 MainLayout.vue 动态菜单

参考设计文档中的 Vue 模板和 TypeScript 逻辑实现。

#### 7.2 router/index.ts 权限守卫

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

---

## 四、验证清单

| 阶段 | 验证项 | 验证方法 |
|------|--------|----------|
| Phase 5 | 后端编译 | `mvn compile -DskipTests` 无错误 |
| Phase 6 | 前端编译 | `npm run build` 无错误 |
| Phase 8 | 前端构建 | `npm run build` 成功生成 dist |
| 集成测试 | 登录获取权限 | 调用 /api/auth/permissions 返回完整数据 |
| 集成测试 | 菜单显示 | 登录后菜单根据权限过滤显示 |
| 集成测试 | 外链菜单 | isFrame=1 的菜单点击在新窗口打开 |

---

## 五、Git 提交规范

```
# Phase 5 后端提交
feat(permission): 实现动态菜单权限功能
- 新增 GET /api/auth/permissions 接口
- Permission 实体新增菜单相关字段
- PermissionService 新增菜单树和权限码查询
- RoleService 新增获取用户角色方法

# Phase 8 前端提交
feat(frontend): 实现动态菜单和权限控制
- 新增 UserPermissionsResponse 和 MenuItem 类型
- auth store 新增权限状态和加载方法
- MainLayout.vue 动态菜单渲染
- router 权限守卫
- PermissionList.vue 新增菜单字段编辑
```

---

## 六、回滚方案

| 问题 | 回滚方案 |
|------|----------|
| 数据库变更问题 | 执行 ALTER TABLE 语句删除新增字段 |
| 后端编译失败 | git revert 最近提交 |
| 前端构建失败 | git revert 最近提交 |
| 权限显示异常 | 检查 init-data.sql 数据是否正确 |

---

*文档版本: 1.0*
*最后更新: 2026-07-10*
