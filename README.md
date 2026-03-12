# Psychological Scale 心理测评系统

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Java](https://img.shields.io/badge/Java-21-blue)](https://openjdk.org/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.2-green)](https://spring.io/projects/spring-boot)
[![Vue](https://img.shields.io/badge/Vue-3.4-green)](https://vuejs.org/)

## 项目介绍

Psychological Scale 是一套功能全面、专业可靠、开箱即用的心理测评系统，基于现代化的 SpringBoot + Vue 前后端分离架构构建，集成专业心理量表，旨在为心理学研究、教育培训、企业人力资源及临床咨询等领域，提供一个安全、稳定、高可扩展的在线测评解决方案。

## 核心功能

### 📊 量表管理
- 海量题库：内置经过信效度检验的经典量表
- 灵活扩展：支持自定义添加、编辑、停用量表
- 自定义评分：支持自定义评分算法与结果解释体系

### 🛒 订单与支付
- 量表购买：支持单个或批量购买量表
- 多种支付：集成微信支付、支付宝支付
- 退款机制：支持部分退款（单量表退款）
- 企业团购：支持企业批量购买和配额管理

### 🔗 第三方对接
- API对接：支持对接第三方量表服务平台
- 题目获取：自动同步第三方量表题目
- 报告回调：自动接收并处理第三方报告结果

### 📝 测评执行
- 智能答题：流畅的答题体验，支持断点续答
- 进度保存：自动保存答题进度
- 实时监控：管理员可实时查看测评状态

### 📈 报告系统
- 自动生成：测评完成后即时生成结构化报告
- 多格式导出：支持 Word 和 PDF 格式导出
- 专业分析：包含分数详情、维度分析、专业建议

### 📉 数据分析
- 数据驾驶舱：可视化数据看板
- 群体分析：多维度统计分析
- 常模对比：支持常模数据对比分析

## 技术架构

### 后端技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 3.2.2 | 后端框架 |
| Java | 21 | 编程语言 |
| Spring Cloud | 2023.0.0 | 微服务治理 |
| MyBatis-Plus | 3.5.5 | ORM框架 |
| MySQL | 8.0 | 关系型数据库 |
| Redis | 7.0 | 缓存数据库 |

### 前端技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Vue | 3.4 | 前端框架 |
| ElementUI | 2.5 | UI组件库 |
| TypeScript | 5.x | 类型系统 |
| Pinia | 2.x | 状态管理 |

### 系统架构图

```
┌─────────────────────────────────────────────────────────────────────┐
│                         前端层 (Frontend)                            │
│  Vue 3 + ElementUI + 微信小程序 + H5                                 │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         网关层 (API Gateway)                         │
│  Spring Cloud Gateway + OAuth 2.0 + JWT                              │
└─────────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        ▼                           ▼                           ▼
┌───────────────┐          ┌───────────────┐          ┌───────────────┐
│  用户服务     │          │  量表服务     │          │  订单服务     │
│  (User)       │          │  (Scale)      │          │  (Order)      │
└───────────────┘          └───────────────┘          └───────────────┘
        │                           │                           │
        ▼                           ▼                           ▼
┌───────────────┐          ┌───────────────┐          ┌───────────────┐
│  支付服务     │          │  报告服务     │          │  第三方服务   │
│  (Payment)   │          │  (Report)     │          │  (ThirdParty)│
└───────────────┘          └───────────────┘          └───────────────┘
```

## 应用场景

### 🏫 高校与科研机构
用于心理学教学实验、大规模人群数据采集与科研分析。

### 🏢 企业人力资源
应用于员工心理健康关怀（EAP）、人才招聘、团队建设与领导力评估。

### 🏤 中小学与教育系统
开展学生发展性评估、心理健康筛查与生涯规划教育。

### 🏥 临床与咨询中心
作为辅助工具，用于初访评估、咨询效果评估与个案管理。

## 项目结构

```
psychological-scale/                 # 项目根目录
├── AGENTS.md                       # 开发指南
├── README.md                       # 项目总览
├── docs/                          # 项目文档
│   ├── requirements/               # 需求文档
│   │   ├── MOD-001-用户与账户管理/
│   │   ├── MOD-002-量表库管理与测评执行/
│   │   ├── MOD-003-量表订单与支付/
│   │   ├── MOD-004-第三方量表服务对接/
│   │   ├── MOD-005-数据分析/
│   │   ├── MOD-006-报告生成与导出/
│   │   └── 需求文档模板.md
│   ├── design/                    # 技术设计文档
│   │   ├── architecture-design.md
│   │   ├── database-design.md
│   │   ├── api-design.md
│   │   ├── security-design.md
│   │   └── ui-design.md
│   ├── plans/                     # 实施计划
│   ├── test/                      # 测试文档
│   └── psychological-scale/       # 量表模板
├── backend/                       # 后端代码
│   ├── ps-common/                 # 公共模块
│   ├── ps-core/                  # 核心模块
│   ├── ps-security/              # 安全模块
│   ├── ps-api/                   # API接口
│   ├── ps-user/                  # 用户服务
│   ├── ps-scale/                 # 量表服务
│   ├── ps-order/                 # 订单服务
│   ├── ps-payment/               # 支付服务
│   ├── ps-report/                # 报告服务
│   ├── ps-thirdparty/            # 第三方服务
│   └── ps-analysis/              # 分析服务
└── frontend/                     # 前端代码
    └── (Vue 3 + ElementUI)
```

## 快速开始

### 环境要求

- JDK 21+
- Maven 3.8+
- Node.js 18+
- MySQL 8.0+
- Redis 7.0+

### 构建项目

```bash
# 克隆项目
git clone https://github.com/nanyi/psychological-scale.git

# 构建后端
cd psychological-scale
mvn clean install -DskipTests

# 构建前端
cd frontend
npm install
npm run dev
```

### 配置说明

详细配置说明请参考 [部署文档](docs/deployment/README.md)。

## 量表模板

系统内置以下经典心理量表：

| 量表名称 | 分类 | 题目数 |
|----------|------|--------|
| SCL-90症状自评量表 | 心理健康 | 90 |
| 焦虑自评量表(SAS) | 情绪测评 | 20 |
| 抑郁自评量表(SDS) | 情绪测评 | 20 |
| 匹兹堡睡眠质量指数(PSQI) | 睡眠测评 | 18 |
| UCLA孤独量表 | 人格测评 | 20 |
| Conners儿童行为问卷 | 儿童测评 | 48 |

更多量表模板请参考 [量表模板目录](docs/psychological-scale/)。

## API 文档

核心API接口说明：

### 订单模块
- `POST /api/order/create` - 创建订单
- `POST /api/order/refund` - 申请退款
- `POST /api/payment/wechat/pay` - 微信支付
- `POST /api/payment/alipay/pay` - 支付宝支付

### 量表模块
- `POST /api/scale/create` - 创建量表
- `GET /api/scale/list` - 量表列表
- `POST /api/assessment/start` - 开始测评

### 报告模块
- `POST /api/report/generate` - 生成报告
- `POST /api/report/export/word` - 导出Word
- `POST /api/report/export/pdf` - 导出PDF

详细API文档请参考 [API设计文档](docs/design/api-design.md)。

## 需求文档

本项目已创建以下核心模块需求文档：

- [量表库管理与测评执行需求文档](docs/requirements/MOD-002-量表库管理与测评执行/量表库管理与测评执行需求文档.md)
- [量表订单与支付需求文档](docs/requirements/MOD-003-量表订单与支付/量表订单与支付需求文档.md)
- [第三方量表服务对接需求文档](docs/requirements/MOD-004-第三方量表服务对接/第三方量表服务对接需求文档.md)
- [报告生成与导出需求文档](docs/requirements/MOD-006-报告生成与导出/报告生成与导出需求文档.md)

## 安全合规

- ✅ 接口级权限验证
- ✅ 关键数据加密存储
- ✅ 操作审计日志
- ✅ 数据定时自动备份

## 性能保障

- ✅ Redis缓存高频数据
- ✅ 高并发场景优化
- ✅ 服务熔断降级
- ✅ 负载均衡

## 贡献指南

欢迎提交 Pull Request，请先阅读 [贡献指南](CONTRIBUTING.md)。

## 许可证

本项目基于 MIT 许可证开源，详见 [LICENSE](LICENSE) 文件。

## 联系方式

- 邮箱：support@psychological-scale.com
- 项目地址：https://github.com/nanyi/psychological-scale

---

*Psychological Scale - 专业的心理测评解决方案*
