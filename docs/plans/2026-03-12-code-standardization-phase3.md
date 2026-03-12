# 代码规范审查报告与执行规划

## 一、审查结果

### 1.1 问题汇总

| 规范类型 | 问题数量 | 严重程度 |
|----------|----------|----------|
| @RequestBody Map 参数 | 46处 | 严重 |
| RestResult<Map> 返回值 | 28处 | 严重 |
| 缺少类注释 | 约10个 | 中等 |
| 缺少方法Javadoc | 约40个 | 中等 |
| 接口路径参数位置不当 | 约20处 | 中等 |

### 1.2 详细问题列表

#### 1.2.1 @RequestBody Map 参数问题（46处）

**ps-order模块（14处）**
- `OrderController.java:107` - getOrderList params
- `RefundController.java:24,44,51,66` - 退款相关接口
- `PaymentController.java:20,29,38,45,57` - 支付相关接口
- `EnterpriseQuotaController.java:23,46,55` - 配额相关接口
- `CartController.java:22,32,41` - 购物车接口

**ps-scale模块（13处）**
- `ScaleController.java:34,40` - 量表创建/更新
- `QuestionController.java:33,39,51,69,75` - 题目相关
- `ExamController.java:23,44,52` - 测评相关
- `ScoringController.java:23,29,51,57,74,83` - 计分相关

**ps-user模块（5处）**
- `UserGroupController.java:35,46,60,68` - 用户组管理
- `EnterpriseController.java:33,45` - 企业管理

**ps-thirdparty模块（4处）**
- `ThirdPartyApiController.java:33,47`
- `ThirdPartyConfigController.java:22,28`
- `ScaleSyncController.java` - 同步接口

**ps-analysis模块（1处）**
- `AnalysisController.java:159` - 导出接口

#### 1.2.2 RestResult<Map> 返回值问题（28处）

**ps-order模块**
- `OrderController.java:118` - getOrderStatistics
- `PaymentController.java:20,29,52`

**ps-scale模块**
- `ScoringController.java:74,83` - 计分/解读
- `ExamRecordController.java:35,47` - 记录详情/统计
- `ExamController.java:52,85` - 提交/进度

**ps-user模块**
- `UserController.java:128` - refreshToken
- `UserGroupController.java:76` - 获取组成员
- `RoleController.java:38` - 获取权限

**ps-analysis模块（7处）**
- `AnalysisController.java` - 各报表接口

**ps-report模块**
- `ReportController.java:151` - 下载报告

**ps-thirdparty模块（7处）**
- `ThirdPartyApiController.java` - 第三方API
- `ThirdPartyConfigController.java:67`
- `ScaleSyncController.java` - 同步统计

#### 1.2.3 接口路径参数位置问题

以下接口路径参数在中间位置，违反规范：
- `/api/user/{id}` → 应改为 `/api/user/info/{id}`
- `/api/user/username/{username}` → 应改为 `/api/user/by-username/{username}`
- `/api/user/phone/{phone}` → 应改为 `/api/user/by-phone/{phone}`
- `/api/user/info/{userId}` → 应改为 `/api/user/info/detail/{userId}`
- `/api/order/{id}` → 应改为 `/api/order/detail/{id}`
- `/api/order/no/{orderNo}` → 应改为 `/api/order/by-no/{orderNo}`
- `/api/order/user/{userId}` → 应改为 `/api/order/by-user/{userId}`
- `/api/scale/{id}` → 应改为 `/api/scale/detail/{id}`
- `/api/scale/code/{code}` → 应改为 `/api/scale/by-code/{code}`
- `/api/scale/{id}/publish` → 应改为 `/api/scale/publish/{id}`
- `/api/scale/{id}/offline` → 应改为 `/api/scale/offline/{id}`
- `/api/scale/{id}/use` → 应改为 `/api/scale/use/{id}`

#### 1.2.4 缺少注释的Controller

以下Controller缺少类注释或方法Javadoc：
- `CartController.java` - 完全缺少注释
- `ScaleController.java` - 大部分方法缺少Javadoc
- `QuestionController.java` - 缺少注释
- `ExamController.java` - 缺少注释
- `ScoringController.java` - 缺少注释
- `ExamRecordController.java` - 缺少注释
- `RefundController.java` - 缺少注释
- `EnterpriseQuotaController.java` - 缺少注释

---

## 二、执行规划

### 2.1 第一阶段：修正@RequestBody Map参数（严重）

创建以下Request DTO类：

**ps-order**
- `OrderListRequest` - 订单列表查询参数
- `RefundCreateRequest` - 退款创建（已有）
- `RefundApproveRequest` - 退款审批（已有）
- `PaymentCreateRequest` - 支付创建（已有）
- `PaymentCancelRequest` - 支付取消
- `QuotaCreateRequest` - 配额创建（已有）
- `QuotaUseRequest` - 配额使用（已有）
- `QuotaRechargeRequest` - 配额充值（已有）
- `CartAddRequest` - 购物车添加（已有）
- `CartRemoveRequest` - 购物车移除
- `CartUpdateRequest` - 购物车更新（已有）

**ps-scale**
- `ScaleCreateRequest` - 量表创建（已有）
- `ScaleUpdateRequest` - 量表更新（已有）
- `QuestionCreateRequest` - 题目创建（已有）
- `QuestionUpdateRequest` - 题目更新（已有）
- `QuestionReorderRequest` - 题目重排（已有）
- `DimensionCreateRequest` - 维度创建（已有）
- `DimensionUpdateRequest` - 维度更新（已有）
- `ExamStartRequest` - 测评开始（已有）
- `AnswerSaveRequest` - 答案保存（已有）
- `ExamSubmitRequest` - 测评提交（已有）
- `ScoringRuleCreateRequest` - 计分规则创建（已有）
- `ScoringRuleUpdateRequest` - 计分规则更新（已有）
- `OptionScoreCreateRequest` - 选项分数创建（已有）
- `OptionScoreUpdateRequest` - 选项分数更新（已有）

**ps-user**
- `UserGroupCreateRequest` - 用户组创建（已有）
- `UserGroupUpdateRequest` - 用户组更新
- `UserGroupMemberRequest` - 组成员操作
- `EnterpriseCreateRequest` - 企业创建
- `EnterpriseUpdateRequest` - 企业更新

**ps-thirdparty**
- `ThirdPartyConfigRequest` - 第三方配置（已有）
- `ThirdPartyConfigUpdateRequest` - 配置更新（已有）
- `ScaleSyncRequest` - 量表同步（已有）
- `AnswerSubmitRequest` - 答案提交（已有）

**ps-analysis**
- `ReportExportRequest` - 报表导出（已有）

### 2.2 第二阶段：修正Map返回值（严重）

创建以下Response DTO类：

- `OrderStatisticsResponse` - 订单统计
- `TokenRefreshResponse` - Token刷新结果
- `GroupMembersResponse` - 组成员列表
- `UserPermissionsResponse` - 用户权限
- `ScaleUsageReportResponse` - 量表使用报表
- `UserExamReportResponse` - 用户测评报表
- `IncomeReportResponse` - 收入报表
- `ResultDistributionResponse` - 结果分布
- `EnterpriseUsageResponse` - 企业使用报表
- `GroupTrendResponse` - 群体趋势
- `ReportDownloadResponse` - 报告下载
- `ConnectionTestResponse` - 连接测试结果
- `SyncStatisticsResponse` - 同步统计
- `ScoreCalculateResponse` - 分数计算结果
- `ScoreInterpretResponse` - 分数解读结果
- `ExamRecordDetailResponse` - 测评记录详情
- `ExamRecordStatisticsResponse` - 测评记录统计
- `ExamSubmitResponse` - 测评提交结果
- `ExamProgressResponse` - 测评进度
- `PaymentStatusResponse` - 支付状态
- `WechatPayOrderResponse` - 微信支付订单
- `AlipayOrderResponse` - 支付宝订单

### 2.3 第三阶段：修正接口路径（中等）

按照规范修正所有路径参数位置。

### 2.4 第四阶段：添加注释（中等）

为缺少注释的Controller和public方法添加Javadoc。

---

## 三、执行顺序

1. 创建所需DTO类（Request/Response）
2. 修改Controller使用DTO替代Map
3. 修正接口路径参数位置
4. 添加缺失的注释
5. 编译验证
6. 提交代码

---

## 四、注意事项

1. 支付回调接口（notify）可暂时保留Map参数，因为是第三方回调
2. 路径修正需要考虑前端兼容性，建议先添加新路径再废弃旧路径
3. 每次修改后需运行 `mvn compile` 验证编译通过
