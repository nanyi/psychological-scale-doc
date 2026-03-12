# 后端代码规范修正计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 按AGENTS.md规范修正后端代码，包括接口DTO化、添加注释和作者信息

**Architecture:** 分模块逐个修正，每个Controller创建对应Request/Response DTO，添加类注释和方法Javadoc

**Tech Stack:** Java 21, Spring Boot 3.2.2, MyBatis-Plus

---

## 问题汇总

| 问题类型 | 数量 | 说明 |
|----------|------|------|
| @RequestBody Map参数 | 55处 | 违反DTO封装规范 |
| 缺少类注释 | 22个Controller | 违反注释规范 |
| 缺少方法Javadoc | 大量 | 违反注释规范 |

---

## 修正范围

### 模块优先级

1. **ps-user** - 用户模块 (6个Controller)
2. **ps-order** - 订单模块 (6个Controller)
3. **ps-scale** - 量表模块 (6个Controller)
4. **ps-thirdparty** - 第三方模块 (3个Controller)
5. **ps-api** - 接口定义 (2个Api)

---

## 任务列表

### Task 1: ps-user 模块修正

**Files:**
- Modify: `ps-user/src/main/java/com/iotsic/ps/user/controller/UserController.java`
- Modify: `ps-user/src/main/java/com/iotsic/ps/user/controller/UserGroupController.java`
- Modify: `ps-user/src/main/java/com/iotsic/ps/user/controller/RoleController.java`
- Modify: `ps-user/src/main/java/com/iotsic/ps/user/controller/PermissionController.java`
- Modify: `ps-user/src/main/java/com/iotsic/ps/user/controller/EnterpriseController.java`

**Step 1: 创建User模块DTO**

```bash
# 创建DTO目录
mkdir -p ps-user/src/main/java/com/iotsic/ps/user/dto
```

**Step 2: 为UserController创建DTO**

- `UserRegisterRequest.java` - 注册请求
- `UserLoginRequest.java` - 登录请求
- `UserRegisterResponse.java` - 注册响应
- `UserLoginResponse.java` - 登录响应

**Step 3: 修改UserController**

- 添加类注释 `@author Ryan`
- 添加方法Javadoc
- 将Map参数替换为DTO

**Step 4: 提交**

```bash
git add ps-user/src/main/java/com/iotsic/ps/user/
git commit -m "refactor(user): 添加DTO和注释符合规范"
```

---

### Task 2: ps-order 模块修正

**Files:**
- Modify: `ps-order/src/main/java/com/iotsic/ps/order/controller/OrderController.java`
- Modify: `ps-order/src/main/java/com/iotsic/ps/order/controller/CartController.java`
- Modify: `ps-order/src/main/java/com/iotsic/ps/order/controller/PaymentController.java`
- Modify: `ps-order/src/main/java/com/iotsic/ps/order/controller/RefundController.java`
- Modify: `ps-order/src/main/java/com/iotsic/ps/order/controller/EnterpriseQuotaController.java`

**Step 1: 创建Order模块DTO**

```bash
mkdir -p ps-order/src/main/java/com/iotsic/ps/order/dto
```

**Step 2: 为各Controller创建DTO并修正**

- `OrderCreateRequest.java` / `OrderCreateResponse.java`
- `CartAddRequest.java`
- `PaymentCreateRequest.java`
- `RefundCreateRequest.java`
- `QuotaCreateRequest.java`

**Step 3: 修改各Controller**

- 添加类注释和方法Javadoc
- 替换Map参数为DTO

**Step 4: 提交**

```bash
git add ps-order/src/main/java/com/iotsic/ps/order/
git commit -m "refactor(order): 添加DTO和注释符合规范"
```

---

### Task 3: ps-scale 模块修正

**Files:**
- Modify: `ps-scale/src/main/java/com/iotsic/ps/scale/controller/ScaleController.java`
- Modify: `ps-scale/src/main/java/com/iotsic/ps/scale/controller/QuestionController.java`
- Modify: `ps-scale/src/main/java/com/iotsic/ps/scale/controller/ExamController.java`
- Modify: `ps-scale/src/main/java/com/iotsic/ps/scale/controller/ScoringController.java`
- Modify: `ps-scale/src/main/java/com/iotsic/ps/scale/controller/ExamRecordController.java`

**Step 1: 创建Scale模块DTO**

```bash
mkdir -p ps-scale/src/main/java/com/iotsic/ps/scale/dto
```

**Step 2: 创建DTO并修改Controller**

- `ScaleCreateRequest.java`
- `QuestionCreateRequest.java`
- `ExamStartRequest.java`
- `ExamSubmitRequest.java`
- `ScoreCalculateRequest.java`

**Step 3: 提交**

```bash
git add ps-scale/src/main/java/com/iotsic/ps/scale/
git commit -m "refactor(scale): 添加DTO和注释符合规范"
```

---

### Task 4: ps-thirdparty 模块修正

**Files:**
- Modify: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/controller/ThirdPartyConfigController.java`
- Modify: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/controller/ScaleSyncController.java`
- Modify: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/controller/ThirdPartyApiController.java`

**Step 1: 创建DTO并修改Controller**

**Step 2: 提交**

```bash
git add ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/
git commit -m "refactor(thirdparty): 添加DTO和注释符合规范"
```

---

### Task 5: ps-api 模块修正

**Files:**
- Modify: `ps-api/src/main/java/com/iotsic/ps/api/user/UserApi.java`
- Modify: `ps-api/src/main/java/com/iotsic/ps/api/order/OrderApi.java`

**Step 1: 修改Feign接口定义**

- 使用Request/Response DTO替代Map

**Step 2: 提交**

```bash
git add ps-api/src/main/java/com/iotsic/ps/api/
git commit -m "refactor(api): 接口定义使用DTO符合规范"
```

---

## 验证步骤

每个任务完成后验证：

```bash
# 编译检查
mvn compile -DskipTests

# 检查是否还有Map参数
grep -r "@RequestBody Map" --include="*.java"
```

---

**Plan complete and saved to `docs/plans/2026-03-12-backend-code-standardization.md`. Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?**
