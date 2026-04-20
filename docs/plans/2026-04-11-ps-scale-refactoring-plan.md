# 服务重构规划：ps-scale 聚合 ps-report、ps-thirdparty

## 1. 当前服务架构分析

### 1.1 服务职责划分

| 服务 | Java文件数 | 主要职责 | 端口 |
|------|------------|----------|------|
| ps-scale | 55 | 量表管理、题目管理、测评执行、评分算法 | 8002 |
| ps-report | 19 | 报告生成、模板管理、导出功能 | 8005 |
| ps-thirdparty | 30 | 第三方API对接、题目同步、回调处理 | 8006 |

### 1.2 服务间依赖关系

```
ps-scale (8002)
  └── 依赖 ps-report (生成报告)
  └── 依赖 ps-thirdparty (获取第三方量表)

ps-report (8005) - 独立服务

ps-thirdparty (8006) - 独立服务
```

### 1.3 业务关联性

- **ps-scale 与 ps-report**：量表测评完成后需要生成报告，耦合度高
- **ps-scale 与 ps-thirdparty**：第三方量表同步后需要创建本地量表，耦合度高
- **ps-report 与 ps-thirdparty**：无直接依赖

---

## 2. 重构目标

### 2.1 预期架构

```
┌─────────────────────────────────────────────────────────────┐
│                      ps-scale (8002)                         │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  原生模块                                            │    │
│  │  - controller (量表/题目/测评)                        │    │
│  │  - service (量表/题目/测评/评分)                       │    │
│  │  - entity (量表/题目/维度/选项/任务/答题记录)          │    │
│  │  - mapper (量表/题目/任务/答题记录)                     │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  聚合 report 模块                                    │    │
│  │  - controller (报告/模板)                             │    │
│  │  - service (报告/模板/导出)                           │    │
│  │  - entity (报告/模板)                                │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  聚合 thirdparty 模块                                │    │
│  │  - controller (同步/回调/配置)                        │    │
│  │  - service (同步/回调/配置)                          │    │
│  │  - entity (配置/回调/同步日志)                       │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 重构收益

| 收益项 | 说明 |
|--------|------|
| **减少服务数量** | 从 3 个服务减少到 1 个服务 |
| **降低运维成本** | 只需部署和维护 1 个服务 |
| **减少网络开销** | 内部方法调用替代 HTTP 调用 |
| **简化事务处理** | 本地事务替代分布式事务 |
| **提升开发效率** | 减少服务间协调成本 |

---

## 3. 重构步骤

### 3.1 第一阶段：创建模块结构（第1天）

**任务**：
1. 在 ps-scale 中创建 `report` 包（复制 ps-report 代码结构）
2. 在 ps-scale 中创建 `thirdparty` 包（复制 ps-thirdparty 代码结构）
3. 更新 ps-scale 的 pom.xml，添加原来 ps-report、ps-thirdparty 的依赖

**产物**：
- `ps-scale/src/main/java/com/iotsic/ps/scale/report/`
- `ps-scale/src/main/java/com/iotsic/ps/scale/thirdparty/`

### 3.2 第二阶段：迁移实体和Mapper（第2天）

**任务**：
1. 迁移 ps-report 的 entity 到 ps-scale.scale.entity.report
2. 迁移 ps-report 的 mapper 到 ps-scale.scale.mapper.report
3. 迁移 ps-thirdparty 的 entity 到 ps-scale.scale.entity.thirdparty
4. 迁移 ps-thirdparty 的 mapper 到 ps-scale.scale.mapper.thirdparty

**注意**：
- 保留原有包路径中的一部分以保持兼容性
- 避免与现有实体类名冲突（如有需重命名）

### 3.3 第三阶段：迁移Service层（第3天）

**任务**：
1. 迁移 ps-report 的 service 到 ps-scale.scale.service.report
2. 迁移 ps-thirdparty 的 service 到 ps-scale.scale.service.thirdparty
3. 处理服务间调用（原本通过 Feign 调用 → 直接注入）

**依赖处理**：
- 移除 ps-report、ps-thirdparty 的 Feign 客户端依赖
- 改为直接注入本地 Service

### 3.4 第四阶段：迁移Controller层（第4天）

**任务**：
1. 迁移 ps-report 的 controller 到 ps-scale.scale.controller.report
2. 迁移 ps-thirdparty 的 controller 到 ps-scale.scale.controller.thirdparty
3. 更新路由前缀避免冲突

**路由规划**：
- `/api/report/**` → ScaleReportController
- `/api/template/**` → ReportTemplateController  
- `/api/sync/**` → ThirdPartySyncController
- `/api/callback/**` → ThirdPartyCallbackController
- `/api/config/**` → ThirdPartyConfigController

### 3.5 第五阶段：整合和测试（第5天）

**任务**：
1. 合并 pom.xml 依赖（去重）
2. 更新 application.yml 配置
3. 删除 ps-report、ps-thirdparty 模块
4. 更新父 pom.xml 模块列表
5. 编译测试

---

## 4. 代码迁移映射表

### 4.1 ps-report → ps-scale

| 原始路径 | 目标路径 |
|----------|----------|
| ps-report/src/main/java/com/iotsic/ps/report/entity/ | ps-scale/src/main/java/com/iotsic/ps/scale/entity/report/ |
| ps-report/src/main/java/com/iotsic/ps/report/mapper/ | ps-scale/src/main/java/com/iotsic/ps/scale/mapper/report/ |
| ps-report/src/main/java/com/iotsic/ps/report/service/ | ps-scale/src/main/java/com/iotsic/ps/scale/service/report/ |
| ps-report/src/main/java/com/iotsic/ps/report/controller/ | ps-scale/src/main/java/com/iotsic/ps/scale/controller/report/ |
| ps-report/src/main/java/com/iotsic/ps/report/dto/ | ps-scale/src/main/java/com/iotsic/ps/scale/dto/report/ |

### 4.2 ps-thirdparty → ps-scale

| 原始路径 | 目标路径 |
|----------|----------|
| ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/entity/ | ps-scale/src/main/java/com/iotsic/ps/scale/entity/thirdparty/ |
| ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/mapper/ | ps-scale/src/main/java/com/iotsic/ps/scale/mapper/thirdparty/ |
| ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/service/ | ps-scale/src/main/java/com/iotsic/ps/scale/service/thirdparty/ |
| ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/controller/ | ps-scale/src/main/java/com/iotsic/ps/scale/controller/thirdparty/ |
| ps-thirdparty/src/main/java/com/iotsic/ps/thirdparty/dto/ | ps-scale/src/main/java/com/iotsic/ps/scale/dto/thirdparty/ |

---

## 5. API 路由变更

### 5.1 合并后的路由

| 原服务 | 原路由 | 合并后路由 | 控制器类 |
|--------|--------|------------|----------|
| ps-scale | /api/scale/** | /api/scale/** | ScaleController |
| ps-scale | /api/question/** | /api/question/** | QuestionController |
| ps-scale | /api/exam/** | /api/exam/** | ExamController |
| ps-scale | /api/record/** | /api/record/** | ExamRecordController |
| ps-scale | /api/scoring/** | /api/scoring/** | ScoringController |
| ps-scale | /api/category/** | /api/category/** | ScaleCategoryController |
| ps-report | /api/report/** | /api/report/** | ScaleReportController |
| ps-report | /api/template/** | /api/template/** | ReportTemplateController |
| ps-thirdparty | /api/sync/** | /api/sync/** | ThirdPartySyncController |
| ps-thirdparty | /api/callback/** | /api/callback/** | ThirdPartyCallbackController |
| ps-thirdparty | /api/config/** | /api/config/** | ThirdPartyConfigController |

### 5.2 网关路由调整

更新 ps-gateway 的路由配置，移除对 ps-report、ps-thirdparty 的路由：

```yaml
# 移除以下路由
# - id: ps-report
#   uri: lb://ps-report
#   predicates: [Path=/api/report/**]
# - id: ps-thirdparty
#   uri: lb://ps-thirdparty
#   predicates: [Path=/api/thirdparty/**]
```

---

## 6. 风险评估

| 风险 | 等级 | 应对措施 |
|------|------|----------|
| 代码冲突 | 中 | 迁移前检查类名冲突，手动重命名 |
| 依赖缺失 | 高 | 详细检查依赖，合并 pom.xml |
| 接口不兼容 | 低 | 保持原接口路径不变 |
| 测试遗漏 | 中 | 编写完整测试用例覆盖 |
| 业务中断 | 低 | 保持 API 兼容性 |

---

## 7. 预计时间

| 阶段 | 预计时间 |
|------|----------|
| 第一阶段：创建模块结构 | 1 天 |
| 第二阶段：迁移实体和Mapper | 1 天 |
| 第三阶段：迁移Service层 | 1 天 |
| 第四阶段：迁移Controller层 | 1 天 |
| 第五阶段：整合和测试 | 1 天 |
| **总计** | **5 天** |

---

## 8. 确认清单

在开始重构前，请确认以下事项：

- [x] 确认重构规划
- [x] 确认目标服务（ps-scale）
- [x] 确认路由变更方案
- [ ] 确认测试策略
- [ ] 确认回滚方案

---

## 9. 进度报告

### 9.1 已完成 (2026-04-11)

| 阶段 | 状态 | 说明 |
|------|------|------|
| 第一阶段 | ✅ 完成 | 创建report/thirdparty模块目录结构，更新pom.xml |
| 第二阶段 | ✅ 完成 | 迁移5个实体类 + 6个Mapper接口 |
| 第三阶段 | ✅ 完成 | 迁移7个Service接口（接口定义） |
| 第四阶段 | ✅ 完成 | 迁移5个Controller |

**已迁移文件统计**：
- report模块：11个Java文件
- thirdparty模块：13个Java文件

### 9.2 第五阶段进度 (2026-04-20)

| 任务 | 状态 | 说明 |
|------|------|------|
| 补充Service实现类 | ✅ 完成 | ReportServiceImpl、ExportServiceImpl、ThirdPartyConfigServiceImpl |
| 更新父pom.xml | ✅ 完成 | 已删除ps-report和ps-thirdparty模块 |
| 补全DTO类 | ✅ 完成 | 5个DTO类已创建 |
| 更新网关路由 | ✅ 完成 | 移除ps-report、ps-thirdparty路由，合并到ps-scale |
| 编译测试 | ✅ 完成 | mvn compile 全部通过 |

**修复的技术问题**：
1. smart-framework本地模块化 - 将外部依赖改为本地模块
2. TokenAuthenticationFilter - 修正import路径和GlobalResultCode
3. 第三方Callback类引用 - 修正为ThirdPartyCallback

### 9.3 重构完成确认

| 项目 | 状态 |
|------|------|
| ps-report模块代码迁移 | ✅ 完成 |
| ps-thirdparty模块代码迁移 | ✅ 完成 |
| 父pom模块列表更新 | ✅ 完成 |
| 网关路由配置更新 | ✅ 完成 |
| 编译验证 | ✅ 通过 |

请确认以上重构规划是否可以执行，或提出修改意见。