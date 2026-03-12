# 前后端接口对接设计文档

> 创建日期: 2026-03-12
> 作者: Ryan

## 1. 目标

实现管理后台前后端接口对接，使页面能够调用后端API获取真实数据展示。

## 2. 技术架构

```
frontend/src/
├── api/                    # API请求模块
│   ├── index.ts           # axios实例封装
│   ├── user.ts            # 用户相关API
│   ├── scale.ts           # 量表相关API
│   ├── order.ts           # 订单相关API
│   ├── report.ts          # 报告相关API
│   └── analysis.ts        # 分析相关API
├── stores/                 # Pinia状态管理
│   ├── auth.ts            # 认证状态(登录/登出/Token)
│   ├── user.ts            # 用户状态
│   ├── scale.ts           # 量表状态
│   └── common.ts          # 通用状态
├── router/
│   └── index.ts           # 添加路由守卫
└── views/                 # 页面对接真实数据
```

## 3. API封装设计

### 3.1 基础配置

```typescript
// 基础URL: /api (预留网关地址，后续通过配置切换)
// 开发环境可通过环境变量配置
const baseURL = import.meta.env.VITE_API_BASE_URL || '/api'
```

### 3.2 请求拦截器

- 自动从localStorage获取JWT Token
- Token放入Authorization请求头: `Bearer {token}`
- Content-Type: application/json

### 3.3 响应拦截器

- 200: 返回data
- 401: 跳转登录页
- 403: 提示无权限
- 其他: 统一错误提示

## 4. 认证流程设计

### 4.1 登录流程

```
1. 用户输入账号密码
2. 调用 POST /api/user/login
3. 成功后保存Token到localStorage
4. 跳转首页
```

### 4.2 路由守卫

- 检查Token是否存在
- 不存在则跳转登录页
- 存在则放行

### 4.3 Token存储

- 键名: `admin_token`
- 格式: JWT字符串

## 5. 接口清单

| 模块 | 接口路径 | 方法 | 说明 |
|------|----------|------|------|
| 认证 | /api/user/login | POST | 登录 |
| 用户 | /api/user/list | GET | 用户列表 |
| 用户 | /api/user/page | POST | 用户分页 |
| 量表 | /api/scale/list | GET | 量表列表 |
| 量表 | /api/scale/page | POST | 量表分页 |
| 订单 | /api/order/list | GET | 订单列表 |
| 订单 | /api/order/page | POST | 订单分页 |
| 报告 | /api/report/list | GET | 报告列表 |
| 报告 | /api/report/page | POST | 报告分页 |
| 分析 | /api/analysis/dashboard | GET | 仪表盘数据 |

## 6. 页面数据对接

| 页面 | 数据来源 | 对接方式 |
|------|----------|----------|
| Login | 调用登录API | 提交表单 |
| Dashboard | /api/analysis/dashboard | onMounted获取 |
| ScaleList | /api/scale/page | 搜索+分页 |
| UserList | /api/user/page | 搜索+分页 |
| OrderList | /api/order/page | 搜索+分页 |
| ReportList | /api/report/page | 搜索+分页 |
| Analysis | 多API组合 | onMounted获取 |

## 7. Header用户信息

- 登录后显示用户名
- 退出按钮调用登出清除Token

## 8. 实施步骤

1. 创建API模块 - axios封装和基础配置
2. 创建认证Store - 登录/登出/Token管理
3. 实现登录页面
4. 添加路由守卫
5. 对接各页面API数据
6. 更新Header登录状态显示
7. 编译验证并提交

---

*文档版本: 1.0*
