# 近期变更梳理与文档更新执行计划

## 1. 近期变更梳理

### 1.1 服务模块重命名（已完成）

| 原模块 | 新模块 | 原包名 | 新包名 | 状态 |
|--------|--------|--------|--------|------|
| ps-user | smart-system | com.iotsic.ps.user | com.iotsic.smart.system | ✅ 已完成 |
| ps-order | smart-oms | com.iotsic.ps.order | com.iotsic.smart.oms | ✅ 已完成 |
| ps-payment | smart-payment | com.iotsic.ps.payment | com.iotsic.smart.payment | ✅ 已完成 |

### 1.2 表名变更

| 模块 | 原表名 | 新表名 | 状态 |
|------|--------|--------|------|
| smart-system | ps_user | sys_user | ✅ 已完成 |
| smart-oms | ps_order | oms_order | ✅ 已完成 |
| smart-oms | ps_order_item | oms_order_item | ✅ 已完成 |
| smart-oms | ps_refund | oms_refund | ✅ 已完成 |
| smart-payment | ps_payment | pay_order | ✅ 已完成 |
| smart-payment | ps_refund | pay_refund | ✅ 已完成 |

### 1.3 数据库脚本更新

- 新增 `pay_order` 表定义
- 新增 `pay_refund` 表定义
- 移除旧的 `ps_refund` 表定义

---

## 2. 需要更新的文档

| 文档 | 更新内容 | 优先级 |
|------|----------|--------|
| README.md | 项目结构、服务名称更新 | 高 |
| database-design.md | 表名变更、ER图更新 | 高 |
| architecture-design.md | 微服务划分表格、服务名称 | 高 |
| 2026-03-11-service-rename-plan.md | 表名更新、完成状态 | 中 |

---

## 3. 执行计划

### Task 1: 更新 README.md 项目结构

**文件:**
- 修改: `README.md:114-150`

**内容:**
- 将 `ps-user/` → `smart-system/`
- 将 `ps-order/` → `smart-oms/`
- 将 `ps-payment/` → `smart-payment/`
- 将 `ps-report/` → `ps-scale/report` (如涉及)
- 将 `ps-thirdparty/` → `ps-scale/thirdparty` (如涉及)

---

### Task 2: 更新 architecture-design.md 微服务划分

**文件:**
- 修改: `docs/design/architecture-design.md:87-96`

**内容:**
| 服务名称 | 服务ID | 主要职责 | 端口 |
|----------|--------|----------|------|
| 用户服务 | smart-system | 用户认证、角色权限、企业管理 | 8001 |
| 量表服务 | ps-scale | 量表管理、题目配置、测评执行 | 8002 |
| 订单服务 | smart-oms | 订单管理、支付处理、退款 | 8003 |
| 支付服务 | smart-payment | 支付渠道对接、支付回调 | 8004 |
| 报告服务 | ps-scale/report | 报告生成、模板管理、导出 | 8005 |
| 第三方服务 | ps-scale/thirdparty | 第三方API对接、题目同步 | 8006 |
| 分析服务 | ps-analysis | 数据统计、报表分析、常模对比 | 8007 |
| 网关服务 | ps-gateway | 请求路由、限流熔断、认证 | 8080 |

---

### Task 3: 更新 database-design.md 表名和ER图

**文件:**
- 修改: `docs/design/database-design.md:460-479` (ps_refund → pay_refund)
- 修改: `docs/design/database-design.md:668-680` (ER图)

**内容:**
- 更新 3.3.3 退款记录表 表名和字段
- 更新 ER 图中的表名

---

### Task 4: 更新 2026-03-11-service-rename-plan.md

**文件:**
- 修改: `docs/plans/2026-03-11-service-rename-plan.md`

**内容:**
- 更新表名变更部分（ps_payment → pay_order, ps_refund → pay_refund）
- 更新完成状态

---

## 4. 验证步骤

1. 确认所有文档更新完成
2. 确认文档内容一致性
3. 提交代码

---

*计划版本: 1.0*
*创建日期: 2026-07-01*
*作者: Ryan*
