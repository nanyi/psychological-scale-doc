# 服务模块重命名变更计划

## 1. 变更概述

### 1.1 变更目标

将后端服务模块进行重命名，统一到 `smart-` 命名规范：

| 原模块 | 新模块 | 包名变更 | 表前缀变更 |
|--------|--------|----------|------------|
| ps-user | smart-system | com.iotsic.ps.user → com.iotsic.smart.system | ps_user → sys_user |
| ps-order | smart-oms | com.iotsic.ps.order → com.iotsic.smart.oms | ps_order → oms_order, ps_order_item → oms_order_item |
| ps-payment | smart-payment | com.iotsic.ps.payment → com.iotsic.smart.payment | ps_refund → order_refund_record |

## 2. 变更范围

### 2.1 目录结构变更

```
backend/
├── smart-system/          # 原 ps-user
├── smart-oms/            # 原 ps-order
├── smart-payment/        # 原 ps-payment
├── ps-common/            # 保持不变
├── ps-core/              # 保持不变
├── ps-api/               # 保持不变
├── ps-gateway/           # 保持不变
├── ps-scale/             # 保持不变
├── ps-analysis/          # 保持不变
└── smart-framework/      # 保持不变
```

### 2.2 包名变更

| 模块 | 原包名 | 新包名 |
|------|--------|--------|
| smart-system | com.iotsic.ps.user | com.iotsic.smart.system |
| smart-system | com.iotsic.ps.user.controller | com.iotsic.smart.system.controller |
| smart-system | com.iotsic.ps.user.service | com.iotsic.smart.system.service |
| smart-system | com.iotsic.ps.user.mapper | com.iotsic.smart.system.mapper |
| smart-oms | com.iotsic.ps.order | com.iotsic.smart.oms |
| smart-oms | com.iotsic.ps.order.controller | com.iotsic.smart.oms.controller |
| smart-oms | com.iotsic.ps.order.service | com.iotsic.smart.oms.service |
| smart-oms | com.iotsic.ps.order.mapper | com.iotsic.smart.oms.mapper |
| smart-payment | com.iotsic.ps.payment | com.iotsic.smart.payment |
| smart-payment | com.iotsic.ps.payment.controller | com.iotsic.smart.payment.controller |
| smart-payment | com.iotsic.ps.payment.service | com.iotsic.smart.payment.service |
| smart-payment | com.iotsic.ps.payment.mapper | com.iotsic.smart.payment.mapper |

### 2.3 表名变更

#### smart-system (原ps-user)
| 原表名 | 新表名 |
|--------|--------|
| ps_user | sys_user |
| ps_order_item | sys_order_item |

#### smart-oms (原ps-order)
| 原表名 | 新表名 |
|--------|--------|
| ps_order | oms_order |
| ps_order_item | oms_order_item |
| ps_refund | oms_refund |
| ps_cart | oms_cart |
| ps_enterprise_quota | oms_enterprise_quota |

#### smart-payment (原ps-payment)
| 原表名 | 新表名 |
|--------|--------|
| ps_payment | pay_order |
| ps_refund | pay_refund |

## 3. 执行计划

### 阶段1: smart-system (原ps-user)

**Step 1.1**: 重命名目录 `ps-user` → `smart-system`

**Step 1.2**: 修改 `smart-system/pom.xml`
- artifactId: ps-user → smart-system
- artifactId: smart-system

**Step 1.3**: 替换所有Java文件包名
```bash
find smart-system -name "*.java" -exec sed -i 's/com.iotsic.ps.user/com.iotsic.smart.system/g' {}
```

**Step 1.4**: 修改 application.yml
- spring.application.name: ps-user → smart-system
- 数据库表前缀配置

**Step 1.5**: 数据库表重命名
```sql
ALTER TABLE ps_user RENAME TO sys_user;
ALTER TABLE ps_order_item RENAME TO sys_order_item;
```

---

### 阶段2: smart-oms (原ps-order)

**Step 2.1**: 重命名目录 `ps-order` → `smart-oms`

**Step 2.2**: 修改 `smart-oms/pom.xml`
- artifactId: ps-order → smart-oms

**Step 2.3**: 替换所有Java文件包名
```bash
find smart-oms -name "*.java" -exec sed -i 's/com.iotsic.ps.order/com.iotsic.smart.oms/g' {}
```

**Step 2.4**: 修改 application.yml
- spring.application.name: ps-order → smart-oms

**Step 2.5**: 数据库表重命名
```sql
ALTER TABLE ps_order RENAME TO oms_order;
ALTER TABLE ps_order_item RENAME TO oms_order_item;
ALTER TABLE ps_refund RENAME TO oms_refund;
ALTER TABLE ps_cart RENAME TO oms_cart;
ALTER TABLE ps_enterprise_quota RENAME TO oms_enterprise_quota;
```

---

### 阶段3: smart-payment (原ps-payment)

**Step 3.1**: 重命名目录 `ps-payment` → `smart-payment`

**Step 3.2**: 修改 `smart-payment/pom.xml`
- artifactId: ps-payment → smart-payment

**Step 3.3**: 替换所有Java文件包名
```bash
find smart-payment -name "*.java" -exec sed -i 's/com.iotsic.ps.payment/com.iotsic.smart.payment/g' {}
```

**Step 3.4**: 修改 application.yml
- spring.application.name: ps-payment → smart-payment

**Step 3.5**: 数据库表重命名
```sql
ALTER TABLE ps_payment RENAME TO smart_payment;
ALTER TABLE ps_refund_record RENAME TO order_refund_record;
```

---

## 4. 风险与回滚

### 4.1 风险识别

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| 包名替换不完整 | 编译失败 | 使用IDE全局替换功能 |
| 表名变更后数据丢失 | 业务中断 | 提前备份数据 |
| 配置文件遗漏 | 服务启动失败 | 逐个检查application.yml |

### 4.2 回滚方案

如遇问题，可通过以下步骤回滚：
```bash
# 目录回滚
mv smart-system ps-user
mv smart-oms ps-order
mv smart-payment ps-payment

# 数据库回滚
ALTER TABLE sys_user RENAME TO ps_user;
ALTER TABLE oms_order RENAME TO ps_order;
-- 等等
```

## 5. 验证清单

- [x] 编译通过 (mvn compile)
- [x] 服务启动成功
- [x] 数据库连接正常
- [x] API接口可访问
- [x] 数据库表数据完整

## 6. 实际执行情况

### 阶段1: smart-system ✅ 已完成
- 目录重命名: ps-user → smart-system
- pom.xml: artifactId 已修改
- 包名替换: com.iotsic.ps.user → com.iotsic.smart.system
- application.yml: 服务名已修改
- 主类重命名: PsUserApplication → SmartSystemApplication

### 阶段2: smart-oms ✅ 已完成
- 目录重命名: ps-order → smart-oms
- pom.xml: artifactId 已修改
- 包名替换: com.iotsic.ps.order → com.iotsic.smart.oms
- application.yml: 服务名已修改
- 主类重命名: PsOrderApplication → SmartOmsApplication

### 阶段3: smart-payment ✅ 已完成
- 目录重命名: ps-payment → smart-payment
- pom.xml: artifactId 已修改
- 包名替换: com.iotsic.ps.payment → com.iotsic.smart.payment
- application.yml: 服务名已修改
- 主类重命名: PsPaymentApplication → SmartPaymentApplication
- 表名变更: ps_payment → pay_order, ps_refund → pay_refund

---

*计划版本: 1.1*
*创建日期: 2026-03-11*
*最后更新: 2026-07-01*
