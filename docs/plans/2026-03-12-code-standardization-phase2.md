# 代码规范修正计划（第二批）

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 修正剩余51处Map参数为DTO，符合AGENTS.md接口规范

**Architecture:** 分模块逐个修正，每个Controller创建对应Request DTO

**Tech Stack:** Java 21, Spring Boot 3.2.2

---

## 待修正清单（51处）

### ps-order (9处)
1. CartController: addToCart, removeFromCart, updateCartQuantity
2. PaymentController: createWechatPayOrder, createAlipayOrder, handleWechatPayCallback, handleAlipayCallback, cancelPayment
3. RefundController: createRefund, approveRefund, rejectRefund, handleRefundCallback
4. EnterpriseQuotaController: createQuota, useQuota, rechargeQuota

### ps-scale (14处)
1. ScaleController: createScale, updateScale
2. QuestionController: createQuestion, updateQuestion, reorderQuestions, createDimension, updateDimension
3. ExamController: startExam, saveAnswer, submitExam
4. ScoringController: createScoringRule, updateScoringRule, createOptionScore, updateOptionScore, calculateScore, interpretScore

### ps-user (6处)
1. UserGroupController: createGroup, updateGroup, addMember, removeMember
2. EnterpriseController: createEnterprise, updateEnterprise

### ps-thirdparty (4处)
1. ThirdPartyConfigController: createConfig, updateConfig
2. ThirdPartyApiController: getQuestions, submitAnswers

### ps-analysis (1处)
1. AnalysisController: exportReportData

### ps-api (5处)
1. UserApi: register, login
2. OrderApi: createOrder, payOrder, refundOrder

---

## 任务列表

### Task 1: ps-order 模块修正

**Step 1: 创建Cart相关DTO**

```bash
mkdir -p ps-order/src/main/java/com/iotsic/ps/order/dto
```

**Step 2: 修正CartController**

- 创建CartUpdateRequest
- 将addToCart, removeFromCart, updateCartQuantity参数改为DTO

**Step 3: 修正PaymentController**

- 创建PaymentNotifyRequest
- 修正参数

**Step 4: 修正RefundController**

- 创建RefundApproveRequest

**Step 5: 修正EnterpriseQuotaController**

- 创建QuotaCreateRequest, QuotaUseRequest

**Step 6: 提交**

```bash
git add ps-order/src/main/java/com/iotsic/ps/order/
git commit -m "refactor(order): 修正Map参数为DTO"
```

---

### Task 2: ps-scale 模块修正

**Step 1: 修正ScaleController**

**Step 2: 修正QuestionController**

**Step 3: 修正ExamController**

**Step 4: 修正ScoringController**

**Step 5: 提交**

```bash
git add ps-scale/src/main/java/com/iotsic/ps/scale/
git commit -m "refactor(scale): 修正Map参数为DTO"
```

---

### Task 3: ps-user 模块修正

**Step 1: 修正UserGroupController**

**Step 2: 修正EnterpriseController**

**Step 3: 提交**

```bash
git add ps-user/src/main/java/com/iotsic/ps/user/
git commit -m "refactor(user): 修正Map参数为DTO"
```

---

### Task 4: ps-thirdparty 模块修正

**Step 1: 修正ThirdPartyConfigController**

**Step 2: 修正ThirdPartyApiController**

**Step 3: 提交**

```bash
git add ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/
git commit -m "refactor(thirdparty): 修正Map参数为DTO"
```

---

### Task 5: ps-analysis + ps-api 修正

**Step 1: 修正AnalysisController**

**Step 2: 修正Feign接口**

**Step 3: 提交**

```bash
git add ps-analysis/ ps-api/
git commit -m "refactor: 修正Map参数为DTO"
```

---

## 验证

完成后验证：

```bash
grep -r "@RequestBody Map" --include="*.java" | wc -l
```

预期结果：0
