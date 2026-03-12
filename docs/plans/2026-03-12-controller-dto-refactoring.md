# Controller/Api 返回值 DTO 化执行规划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将所有 Controller 和 API 接口中的 `RestResult<Map>` 返回值改为具体的 DTO 类

**Architecture:** 根据每个接口的业务逻辑，创建对应的 Response DTO 类，并修改 Controller/Service 接口的实现

**Tech Stack:** Spring Boot, MyBatis-Plus, Java 21

---

## 待修改清单

### 1. ScaleSyncController (3处)
- `syncScales` - 返回 Map → SyncResultResponse
- `syncSingleScale` - 返回 Map → SyncResultResponse  
- `getSyncStatistics` - 返回 Map → SyncStatisticsResponse

### 2. ThirdPartyApiController (4处)
- `getQuestions` - 返回 Map → PlatformQuestionsResponse
- `submitAnswers` - 返回 Map → PlatformAnswerResponse
- `getReport` - 返回 Map → PlatformReportResponse
- `handleCallback` - 返回 Map → CallbackResponse

### 3. OrderApi (6处)
- `getOrderById` - 返回 Map → OrderResponse
- `getOrderByNo` - 返回 Map → OrderResponse
- `createOrder` - 请求/返回 Map → OrderCreateRequest/OrderResponse
- `payOrder` - 请求/返回 Map → PayOrderRequest/PayOrderResponse
- `refundOrder` - 请求/返回 Map → RefundOrderRequest/RefundOrderResponse
- `getUserOrders` - 返回 Map → OrderListResponse

### 4. UserApi (6处)
- `getUserById` - 返回 Map → UserResponse
- `getUserByUsername` - 返回 Map → UserResponse
- `getUserByPhone` - 返回 Map → UserResponse
- `register` - 请求 Map → UserRegisterRequest
- `login` - 请求 Map → UserLoginRequest
- `refreshToken` - 返回 Map → TokenResponse

### 5. ScaleApi (6处)
- `getScaleById` - 返回 Map → ScaleResponse
- `getScaleByCode` - 返回 Map → ScaleResponse
- `getScaleList` - 请求/返回 Map → ScaleListRequest/ScaleListResponse
- `getDimensionsByScaleId` - 返回 Map → DimensionListResponse
- `getQuestionsByScaleId` - 返回 Map → QuestionListResponse
- `checkPurchase` - 返回 Map → PurchaseCheckResponse

### 6. RoleController (1处)
- `getUserPermissions` - 返回 Map → UserPermissionsResponse

### 7. AnalysisController (1处)
- `exportReportData` - 返回 Map → ExportDataResponse

---

## Task 1: ScaleSyncController DTO 化

**Files:**
- Create: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/dto/SyncResultResponse.java`
- Create: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/dto/SyncStatisticsResponse.java`
- Modify: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/controller/ScaleSyncController.java`
- Modify: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/service/ScaleSyncService.java`
- Modify: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/service/ScaleSyncServiceImpl.java`

**Step 1: 创建 SyncResultResponse DTO**

```java
package com.iotsic.ps.thirdparty.dto;

import lombok.Data;
import java.util.List;

/**
 * 同步结果响应DTO
 *
 * @author Ryan
 * @since 2026-03-12
 */
@Data
public class SyncResultResponse {

    /**
     * 同步成功的数量
     */
    private Integer successCount;

    /**
     * 同步失败的数量
     */
    private Integer failCount;

    /**
     * 同步的量表ID列表
     */
    private List<Long> scaleIds;

    /**
     * 错误信息
     */
    private String errorMessage;
}
```

**Step 2: 创建 SyncStatisticsResponse DTO**

```java
package com.iotsic.ps.thirdparty.dto;

import lombok.Data;
import java.util.Map;

/**
 * 同步统计响应DTO
 *
 * @author Ryan
 * @since 2026-03-12
 */
@Data
public class SyncStatisticsResponse {

    /**
     * 总同步次数
     */
    private Integer totalSyncCount;

    /**
     * 成功次数
     */
    private Integer successCount;

    /**
     * 失败次数
     */
    private Integer failCount;

    /**
     * 最后同步时间
     */
    private String lastSyncTime;

    /**
     * 统计数据
     */
    private Map<String, Object> statistics;
}
```

**Step 3: 修改 ScaleSyncService 接口**

修改返回值类型从 `Map<String, Object>` 改为对应的 DTO

**Step 4: 修改 ScaleSyncServiceImpl 实现**

创建 DTO 对象并返回

**Step 5: 修改 ScaleSyncController**

修改返回类型

**Step 6: 编译验证**

Run: `mvn compile -DskipTests -pl ps-thirdparty -am`

---

## Task 2: ThirdPartyApiController DTO 化

**Files:**
- Create: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/dto/PlatformQuestionsResponse.java`
- Create: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/dto/PlatformAnswerResponse.java`
- Create: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/dto/PlatformReportResponse.java`
- Create: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/dto/CallbackResponse.java`
- Modify: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/controller/ThirdPartyApiController.java`
- Modify: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/service/ThirdPartyApiService.java`
- Modify: `ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/service/ThirdPartyApiServiceImpl.java`

---

## Task 3: OrderApi DTO 化

**Files:**
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/OrderResponse.java`
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/PayOrderRequest.java`
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/PayOrderResponse.java`
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/RefundOrderRequest.java`
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/RefundOrderResponse.java`
- Modify: `ps-api/src/main/java/com/iotsic/ps/api/order/OrderApi.java`
- Modify: `ps-order/src/main/java/com/iotsic/ps/order/service/OrderService.java`
- Modify: `ps-order/src/main/java/com/iotsic/ps/order/service/OrderServiceImpl.java`

---

## Task 4: UserApi DTO 化

**Files:**
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/UserResponse.java`
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/TokenResponse.java`
- Modify: `ps-api/src/main/java/com/iotsic/ps/api/user/UserApi.java`
- Modify: `ps-user/src/main/java/com/iotsic/ps/user/service/UserService.java`
- Modify: `ps-user/src/main/java/com/iotsic/ps/user/service/UserServiceImpl.java`

---

## Task 5: ScaleApi DTO 化

**Files:**
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/ScaleResponse.java`
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/ScaleListRequest.java`
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/ScaleListResponse.java`
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/DimensionListResponse.java`
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/QuestionListResponse.java`
- Create: `ps-api/src/main/java/com/iotsic/ps/api/dto/PurchaseCheckResponse.java`
- Modify: `ps-api/src/main/java/com/iotsic/ps/api/scale/ScaleApi.java`
- Modify: `ps-scale/src/main/java/com/iotsic/ps/scale/service/ScaleService.java`
- Modify: `ps-scale/src/main/java/com/iotsic/ps/scale/service/ScaleServiceImpl.java`

---

## Task 6: RoleController DTO 化

**Files:**
- Create: `ps-user/src/main/java/com/iotsic/ps/user/dto/UserPermissionsResponse.java`
- Modify: `ps-user/src/main/java/com/iotsic/ps/user/controller/RoleController.java`
- Modify: `ps-user/src/main/java/com/iotsic/ps/user/service/RoleService.java`

---

## Task 7: AnalysisController DTO 化

**Files:**
- Create: `ps-analysis/src/main/java/com/iotsic/ps/analysis/dto/ExportDataResponse.java`
- Modify: `ps-analysis/src/main/java/com/iotsic/ps/analysis/controller/AnalysisController.java`
- Modify: `ps-analysis/src/main/java/com/iotsic/ps/analysis/service/AnalysisService.java`
- Modify: `ps-analysis/src/main/java/com/iotsic/ps/analysis/service/AnalysisServiceImpl.java`

---

## 执行命令

**每完成一个 Task 后执行编译验证：**

```bash
mvn compile -DskipTests
```

**提交命令：**

```bash
git add -A && git commit -m "refactor: XXX接口返回DTO化"
```

---

## 预期结果

所有 Controller 和 API 接口的返回值都使用具体的 DTO 类，不再使用 `Map<String, Object>`
