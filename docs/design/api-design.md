# API接口设计文档

## 1. 文档信息

| 属性 | 内容 |
|------|------|
| 文档类型 | 技术设计 |
| 版本 | 1.0 |
| 状态 | 已完成 |
| 创建日期 | 2026-03-09 |
| 最后更新 | 2026-03-09 |
| 作者 | Ryan |

## 2. API设计规范

### 2.1 接口规范

- **协议**: HTTPS
- **风格**: RESTful
- **认证**: JWT Bearer Token
- **请求格式**: JSON
- **响应格式**: JSON

### 2.2 响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1234567890
}
```

### 2.3 错误码定义

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

## 3. 用户服务API (ps-user)

### 3.1 用户认证

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/user/register | POST | 用户注册 |
| /api/user/login | POST | 用户登录 |
| /api/user/logout | POST | 用户登出 |
| /api/user/refresh-token | POST | 刷新Token |
| /api/user/send-code | POST | 发送验证码 |

**用户登录**
```
POST /api/user/login
Request:
{
  "username": "string",
  "password": "string",
  "deviceInfo": "string"
}
Response:
{
  "code": 200,
  "data": {
    "token": "string",
    "userId": 123,
    "username": "string",
    "nickname": "string",
    "userType": 1,
    "roles": ["string"],
    "expireTime": "2026-03-09 10:00:00"
  }
}
```

### 3.2 用户管理

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/user/info | GET | 获取用户信息 |
| /api/user/update | PUT | 更新用户信息 |
| /api/user/password | PUT | 修改密码 |
| /api/user/list | GET | 用户列表 |
| /api/user/{id} | GET | 用户详情 |
| /api/user/{id}/disable | PUT | 禁用用户 |

### 3.3 企业管理

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/enterprise/register | POST | 企业注册 |
| /api/enterprise/info | GET | 企业信息 |
| /api/enterprise/update | PUT | 更新企业信息 |
| /api/enterprise/member/list | GET | 企业成员列表 |
| /api/enterprise/member/add | POST | 添加成员 |
| /api/enterprise/member/remove | DELETE | 移除成员 |

### 3.4 角色权限

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/role/create | POST | 创建角色 |
| /api/role/update | PUT | 更新角色 |
| /api/role/delete | DELETE | 删除角色 |
| /api/role/list | GET | 角色列表 |
| /api/role/{id} | GET | 角色详情 |
| /api/role/permissions | GET | 角色权限列表 |
| /api/permission/list | GET | 权限列表 |

### 3.5 分组管理

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/group/create | POST | 创建分组 |
| /api/group/update | PUT | 更新分组 |
| /api/group/delete | DELETE | 删除分组 |
| /api/group/list | GET | 分组列表 |
| /api/group/member/add | POST | 添加成员 |
| /api/group/member/remove | POST | 移除成员 |
| /api/group/member/list | GET | 分组成员列表 |

## 4. 量表服务API (ps-scale)

### 4.1 量表管理

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/scale/create | POST | 创建量表 |
| /api/scale/update | PUT | 更新量表 |
| /api/scale/delete | DELETE | 删除量表 |
| /api/scale/list | GET | 量表列表 |
| /api/scale/{id} | GET | 量表详情 |
| /api/scale/publish | POST | 发布量表 |
| /api/scale/offline | POST | 下架量表 |

### 4.2 维度管理

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/scale/dimension/add | POST | 添加维度 |
| /api/scale/dimension/update | PUT | 更新维度 |
| /api/scale/dimension/delete | DELETE | 删除维度 |
| /api/scale/{scaleId}/dimensions | GET | 维度列表 |

### 4.3 题目管理

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/scale/question/add | POST | 添加题目 |
| /api/scale/question/update | PUT | 更新题目 |
| /api/scale/question/delete | DELETE | 删除题目 |
| /api/scale/question/list | GET | 题目列表 |
| /api/scale/question/option/add | POST | 添加选项 |
| /api/scale/question/option/update | PUT | 更新选项 |
| /api/scale/question/option/delete | DELETE | 删除选项 |

### 4.4 测评执行

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/assessment/start | POST | 开始测评 |
| /api/assessment/answer | POST | 提交答案 |
| /api/assessment/submit | POST | 提交测评 |
| /api/assessment/progress | GET | 查询进度 |
| /api/assessment/result | GET | 获取结果 |
| /api/assessment/list | GET | 测评记录列表 |
| /api/assessment/{id} | GET | 测评详情 |

## 5. 订单服务API (ps-order)

### 5.1 订单管理

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/order/create | POST | 创建订单 |
| /api/order/detail | GET | 订单详情 |
| /api/order/list | GET | 订单列表 |
| /api/order/cancel | POST | 取消订单 |
| /api/order/refund | POST | 申请退款 |
| /api/order/refund/list | GET | 退款列表 |
| /api/order/refund/{id} | GET | 退款详情 |

### 5.2 购物车

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/cart/add | POST | 加入购物车 |
| /api/cart/remove | POST | 移除购物车 |
| /api/cart/list | GET | 购物车列表 |
| /api/cart/clear | DELETE | 清空购物车 |

### 5.3 配额管理

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/quota/list | GET | 配额列表 |
| /api/quota/usage | GET | 配额使用情况 |
| /api/enterprise/quota/list | GET | 企业配额列表 |
| /api/enterprise/quota/assign | POST | 分配配额 |

## 6. 支付服务API (ps-payment)

### 6.1 支付接口

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/payment/wechat/pay | POST | 微信支付 |
| /api/payment/wechat/callback | POST | 微信支付回调 |
| /api/payment/wechat/query | GET | 微信支付查询 |
| /api/payment/alipay/pay | POST | 支付宝支付 |
| /api/payment/alipay/callback | POST | 支付宝回调 |
| /api/payment/alipay/query | GET | 支付宝查询 |

### 6.2 退款接口

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/payment/refund | POST | 申请退款 |
| /api/payment/refund/query | GET | 退款查询 |

## 7. 报告服务API (ps-report)

### 7.1 报告管理

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/report/generate | POST | 生成报告 |
| /api/report/detail | GET | 报告详情 |
| /api/report/list | GET | 报告列表 |
| /api/report/{id} | GET | 报告内容 |

### 7.2 模板管理

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/report/template/create | POST | 创建模板 |
| /api/report/template/update | PUT | 更新模板 |
| /api/report/template/delete | DELETE | 删除模板 |
| /api/report/template/list | GET | 模板列表 |
| /api/report/template/{id} | GET | 模板详情 |

### 7.3 导出

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/report/export/word | POST | 导出Word |
| /api/report/export/pdf | POST | 导出PDF |
| /api/report/download | GET | 下载报告 |
| /api/report/share | POST | 分享报告 |

## 8. 第三方服务API (ps-thirdparty)

### 8.1 平台管理

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/thirdparty/platform/add | POST | 添加平台 |
| /api/thirdparty/platform/update | PUT | 更新平台 |
| /api/thirdparty/platform/delete | DELETE | 删除平台 |
| /api/thirdparty/platform/list | GET | 平台列表 |
| /api/thirdparty/platform/test | POST | 测试连接 |

### 8.2 量表同步

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/thirdparty/scale/sync | POST | 同步量表 |
| /api/thirdparty/scale/list | GET | 第三方量表列表 |
| /api/thirdparty/scale/questions | GET | 获取题目 |

### 8.3 回调处理

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/thirdparty/callback/report | POST | 报告回调 |
| /api/thirdparty/callback/sync | POST | 同步回调 |

## 9. 分析服务API (ps-analysis)

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/analysis/dashboard | GET | 驾驶舱数据 |
| /api/analysis/report | GET | 统计报表 |
| /api/analysis/trend | GET | 趋势数据 |
| /api/analysis/norm/compare | POST | 常模对比 |
| /api/analysis/norm/list | GET | 常模列表 |
| /api/analysis/norm/create | POST | 创建常模 |
| /api/analysis/monitor | GET | 实时监控 |
| /api/analysis/export | POST | 导出数据 |

## 10. 公共接口

| 接口路径 | 方法 | 说明 |
|----------|------|------|
| /api/common/captcha | GET | 图形验证码 |
| /api/common/upload | POST | 文件上传 |
| /api/common/config | GET | 系统配置 |
| /api/common/dict/{type} | GET | 字典数据 |

---

*文档版本: 1.1*
*最后更新: 2026-03-11*
*作者: Ryan*
