# 管理后台前端功能页面实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** 在管理后台项目中增加量表管理、订单与支付、第三方服务、系统设置相关前端功能页面

**Architecture:** 基于Vue3 + Element Plus，采用组件化开发，所有API调用封装为独立模块，页面按模块组织在views目录下

**Tech Stack:** Vue 3.4 + Element Plus + TypeScript + Vite

---

## 待实现页面清单

| 模块 | 页面 | 路由 | 对应后端API |
|------|------|------|------------|
| 量表管理 | 题目管理 | /scale/:id/questions | QuestionController |
| 量表管理 | 测评任务 | /scale/exam | ExamController |
| 量表管理 | 测评记录/监控 | /scale/exam-records | ExamRecordController |
| 订单与支付 | 订单详情 | /order/:id | OrderController |
| 订单与支付 | 企业配额 | /enterprise-quota | EnterpriseQuotaController |
| 第三方服务 | API配置 | /thirdparty/config | ThirdPartyConfigController |
| 第三方服务 | 同步日志 | /thirdparty/sync-logs | ScaleSyncController |
| 第三方服务 | 服务监控 | /thirdparty/monitor | ThirdPartyApiController |
| 系统设置 | 系统设置 | /system/setting | (新建API或复用) |

---

## Task 1: 题目管理页面

**Files:**
- Create: `frontend/src/api/scaleQuestion.ts`
- Create: `frontend/src/views/scale/ScaleQuestionList.vue`
- Modify: `frontend/src/router/index.ts`
- Modify: `frontend/src/layouts/MainLayout.vue`

**Step 1: 创建API模块**

```typescript
// frontend/src/api/scaleQuestion.ts
import request from '@/utils/request'
import type { Question, Dimension } from '@/types'

export function getQuestionsByScaleId(scaleId: number) {
  return request.get(`/scale/questions/by-scale/${scaleId}`)
}

export function getQuestionDetail(id: number) {
  return request.get(`/scale/questions/detail/${id}`)
}

export function createQuestion(data: any) {
  return request.post('/scale/questions/create', data)
}

export function updateQuestion(id: number, data: any) {
  return request.put(`/scale/questions/update/${id}`, data)
}

export function deleteQuestion(id: number) {
  return request.delete(`/scale/questions/delete/${id}`)
}

export function getDimensionsByScaleId(scaleId: number) {
  return request.get(`/scale/dimensions/by-scale/${scaleId}`)
}
```

**Step 2: 创建题目管理页面**

```vue
<!-- frontend/src/views/scale/ScaleQuestionList.vue -->
<template>
  <div class="scale-question">
    <!-- 页面标题和操作栏 -->
    <div class="page-header">
      <h2>题目管理</h2>
      <el-button type="primary" @click="handleAdd">新增题目</el-button>
    </div>
    
    <!-- 搜索筛选 -->
    <el-card class="filter-card">
      <el-form inline>
        <el-form-item label="维度">
          <el-select v-model="filters.dimensionId" placeholder="请选择" clearable>
            <el-option v-for="dim in dimensions" :key="dim.id" :label="dim.name" :value="dim.id" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadQuestions">搜索</el-button>
          <el-button @click="resetFilters">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    
    <!-- 题目列表 -->
    <el-card>
      <el-table :data="questions" row-key="id" :tree-props="{ children: 'children' }">
        <el-table-column prop="questionNo" label="题号" width="80" />
        <el-table-column prop="content" label="题目内容" show-overflow-tooltip />
        <el-table-column prop="dimensionName" label="所属维度" width="120" />
        <el-table-column prop="questionType" label="题型" width="100">
          <template #default="{ row }">
            <el-tag>{{ getQuestionTypeName(row.questionType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="required" label="必答" width="80">
          <template #default="{ row }">
            <el-tag :type="row.required ? 'danger' : 'info'">{{ row.required ? '是' : '否' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="primary" @click="handleAddChild(row)" v-if="!row.dimensionId">添加子题</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>
```

**Step 3: 更新路由**

在 `router/index.ts` 添加:
```typescript
{
  path: 'scale/:id/questions',
  name: 'ScaleQuestions',
  component: () => import('@/views/scale/ScaleQuestionList.vue'),
  meta: { title: '题目管理' }
}
```

**Step 4: 更新菜单**

在 `MainLayout.vue` 量表管理菜单下添加子菜单:
```vue
<el-menu-item index="/scale/:id/questions">题目管理</el-menu-item>
```

---

## Task 2: 测评任务页面

**Files:**
- Create: `frontend/src/api/exam.ts`
- Create: `frontend/src/views/scale/ExamList.vue`
- Modify: `frontend/src/router/index.ts`
- Modify: `frontend/src/layouts/MainLayout.vue`

---

## Task 3: 测评记录/监控页面

**Files:**
- Create: `frontend/src/api/examRecord.ts`
- Create: `frontend/src/views/scale/ExamRecordList.vue`
- Modify: `frontend/src/router/index.ts`
- Modify: `frontend/src/layouts/MainLayout.vue`

---

## Task 4: 订单详情页面

**Files:**
- Create: `frontend/src/api/order.ts` (扩展现有)
- Create: `frontend/src/views/order/OrderDetail.vue`
- Modify: `frontend/src/router/index.ts`

---

## Task 5: 企业配额页面

**Files:**
- Create: `frontend/src/api/enterpriseQuota.ts`
- Create: `frontend/src/views/order/EnterpriseQuotaList.vue`
- Modify: `frontend/src/router/index.ts`
- Modify: `frontend/src/layouts/MainLayout.vue`

---

## Task 6: 第三方API配置页面

**Files:**
- Create: `frontend/src/api/thirdParty.ts`
- Create: `frontend/src/views/thirdparty/ThirdPartyConfigList.vue`
- Modify: `frontend/src/router/index.ts`
- Modify: `frontend/src/layouts/MainLayout.vue`

---

## Task 7: 同步日志页面

**Files:**
- Create: `frontend/src/views/thirdparty/SyncLogList.vue`
- Modify: `frontend/src/router/index.ts`
- Modify: `frontend/src/layouts/MainLayout.vue`

---

## Task 8: 服务监控页面

**Files:**
- Create: `frontend/src/views/thirdparty/ServiceMonitor.vue`
- Modify: `frontend/src/router/index.ts`
- Modify: `frontend/src/layouts/MainLayout.vue`

---

## Task 9: 系统设置页面

**Files:**
- Create: `frontend/src/api/system.ts`
- Create: `frontend/src/views/system/SystemSetting.vue`
- Modify: `frontend/src/router/index.ts`
- Modify: `frontend/src/layouts/MainLayout.vue`

---

## 实施顺序

1. 先创建API模块
2. 创建页面组件
3. 配置路由
4. 添加菜单
5. 构建验证
6. 提交代码
