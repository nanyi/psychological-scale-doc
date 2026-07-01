-- ============================================================
-- 心理测评系统数据初始化脚本
-- 数据库: psychological_scale
-- 版本: 1.0
-- 创建日期: 2026-03-12
-- 作者: Ryan
-- ============================================================

USE psychological_scale;

-- ============================================================
-- 1. 初始化数据
-- ============================================================

-- 初始化量表分类数据
INSERT INTO ps_scale_category (category_name, parent_id, sort_order, status) VALUES
('人格测评', 0, 1, 1),
('心理健康', 0, 2, 1),
('职业测评', 0, 3, 1),
('智力测评', 0, 4, 1),
('家庭测评', 0, 5, 1),
('教育测评', 0, 6, 1),
('临床测评', 0, 7, 1);

-- 初始化二级分类
INSERT INTO ps_scale_category (category_name, parent_id, sort_order, status) VALUES
('抑郁', 2, 1, 1),
('焦虑', 2, 2, 1),
('情绪管理', 2, 3, 1);

-- 初始化角色数据
INSERT INTO sys_role (role_name, role_code, role_type, is_system, description, status) VALUES
('超级管理员', 'SUPER_ADMIN', 1, 1, '拥有系统所有权限', 1),
('企业管理员', 'ENTERPRISE_ADMIN', 2, 0, '企业管理权限', 1),
('测评师', 'ASSESSOR', 2, 0, '测评管理权限', 1),
('普通用户', 'USER', 2, 0, '普通用户权限', 1);

-- 初始化权限数据
INSERT INTO sys_permission (permission_name, permission_code, permission_type, parent_id, module, sort_order) VALUES
-- 用户管理模块
('用户管理', 'user:manage', 1, NULL, 'MOD-001', 1),
('用户列表', 'user:list', 2, 1, 'MOD-001', 1),
('用户新增', 'user:add', 3, 1, 'MOD-001', 2),
('用户编辑', 'user:edit', 3, 1, 'MOD-001', 3),
('用户删除', 'user:delete', 3, 1, 'MOD-001', 4),
-- 量表管理模块
('量表管理', 'scale:manage', 1, NULL, 'MOD-002', 2),
('量表列表', 'scale:list', 2, 6, 'MOD-002', 1),
('量表新增', 'scale:add', 3, 6, 'MOD-002', 2),
('量表编辑', 'scale:edit', 3, 6, 'MOD-002', 3),
('量表删除', 'scale:delete', 3, 6, 'MOD-002', 4),
-- 订单管理模块
('订单管理', 'order:manage', 1, NULL, 'MOD-003', 3),
('订单列表', 'order:list', 2, 11, 'MOD-003', 1),
('订单退款', 'order:refund', 3, 11, 'MOD-003', 2),
-- 数据分析模块
('数据分析', 'analysis:view', 1, NULL, 'MOD-005', 4),
('数据导出', 'analysis:export', 3, 15, 'MOD-005', 1),
-- 报告管理模块
('报告管理', 'report:manage', 1, NULL, 'MOD-006', 5),
('报告查看', 'report:view', 3, 17, 'MOD-006', 1),
('报告导出', 'report:export', 3, 17, 'MOD-006', 2);

-- 为超级管理员角色分配所有权限
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 1, id FROM sys_permission;

-- 初始化演示用户 (密码: 123456, BCrypt加密)
INSERT INTO sys_user (username, password, nickname, phone, email, user_type, status) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '系统管理员', '13800138000', 'admin@example.com', 1, 1);

-- 关联管理员角色
INSERT INTO sys_user_role (user_id, role_id) VALUES (1, 1);

-- 初始化演示企业数据
INSERT INTO sys_enterprise (enterprise_name, credit_code, contact_name, contact_phone, contact_email, status, expire_time) VALUES
('深圳市心理健康科技有限公司', '91440300MA5DQXXX00', '张三', '13800138001', 'zhangsan@example.com', 1, '2027-12-31 23:59:59'),
('广州心理咨询中心', '91440100MA5DQYYY11', '李四', '13800138002', 'lisi@example.com', 1, '2027-06-30 23:59:59'),
('北京教育科技有限公司', '91110000MA5DQZZZ22', '王五', '13800138003', 'wangwu@example.com', 1, '2026-12-31 23:59:59');

-- 初始化演示部门数据
INSERT INTO sys_department (department_name, parent_id, enterprise_id, leader, phone, email, sort_order, status) VALUES
-- 深圳市心理健康科技有限公司的部门
('深圳市心理健康科技有限公司', 0, 1, '张三', '13800138001', 'zhangsan@example.com', 1, 1),
('研发部', 4, 1, '研发经理', '13800138011', 'rd@example.com', 1, 1),
('产品部', 4, 1, '产品经理', '13800138012', 'pm@example.com', 2, 1),
('运营部', 4, 1, '运营经理', '13800138013', 'ops@example.com', 3, 1),
('销售部', 4, 1, '销售经理', '13800138014', 'sales@example.com', 4, 1),
('客户服务部', 4, 1, '客服经理', '13800138015', 'cs@example.com', 5, 1),
('研发一组', 5, 1, '组长A', '13800138021', 'a@example.com', 1, 1),
('研发二组', 5, 1, '组长B', '13800138022', 'b@example.com', 2, 1),
-- 广州心理咨询中心的部门
('广州心理咨询中心', 0, 2, '李四', '13800138002', 'lisi@example.com', 1, 1),
('测评部', 14, 2, '测评主管', '13800138031', 'eval@example.com', 1, 1),
('咨询部', 14, 2, '咨询主管', '13800138032', 'consult@example.com', 2, 1),
('市场部', 14, 2, '市场主管', '13800138033', 'market@example.com', 3, 1),
-- 北京教育科技有限公司的部门
('北京教育科技有限公司', 0, 3, '王五', '13800138003', 'wangwu@example.com', 1, 1),
('教学部', 23, 3, '教学主管', '13800138041', 'teach@example.com', 1, 1),
('技术部', 23, 3, '技术主管', '13800138042', 'tech@example.com', 2, 1);

-- 初始化经典心理量表数据
INSERT INTO ps_scale (scale_code, scale_name, scale_name_en, category_id, target_audience, description, instruction, duration, question_count, dimension_count, source_type, price, status) VALUES
('SCL90', '症状自评量表', 'SCL-90', 2, '成人', '包含90个项目，分为10个因子，主要用于评估个体的心理健康状况。', '请根据您最近一周的实际情况，对以下每一条陈述进行评估。', 30, 90, 10, 1, 0.00, 1),
('SAS', '焦虑自评量表', 'Zung Self-Rating Anxiety Scale', 2, '成人', '包含20个项目，用于评估焦虑状态的轻重程度。', '请根据您最近一周的实际情况，选择最符合您的选项。', 10, 20, 1, 1, 0.00, 1),
('SDS', '抑郁自评量表', 'Zung Self-Rating Depression Scale', 2, '成人', '包含20个项目，用于评估抑郁状态的轻重程度。', '请根据您最近一周的实际情况，选择最符合您的选项。', 10, 20, 1, 1, 0.00, 1),
('PSQI', '匹兹堡睡眠质量指数', 'Pittsburgh Sleep Quality Index', 2, '成人', '包含18个项目，用于评估睡眠质量。', '请根据您最近一个月的睡眠情况进行选择。', 15, 18, 7, 1, 0.00, 1),
('UCLA', 'UCLA孤独量表', 'UCLA Loneliness Scale', 1, '成人', '包含20个项目，用于评估孤独感程度。', '请根据您的实际感受，选择最符合的选项。', 10, 20, 1, 1, 0.00, 1);

-- 为SCL-90初始化维度数据
INSERT INTO ps_scale_dimension (scale_id, dimension_code, dimension_name, sort_order) VALUES
(1, 'somatization', '躯体化', 1),
(1, 'obsessive', '强迫症状', 2),
(1, 'interpersonal', '人际关系敏感', 3),
(1, 'depression', '抑郁', 4),
(1, 'anxiety', '焦虑', 5),
(1, 'hostility', '敌对', 6),
(1, 'phobic', '恐怖', 7),
(1, 'paranoid', '偏执', 8),
(1, 'psychoticism', '精神病性', 9),
(1, 'other', '其他', 10);

-- 为PSQI初始化维度数据
INSERT INTO ps_scale_dimension (scale_id, dimension_code, dimension_name, sort_order) VALUES
(4, 'sleep_quality', '睡眠质量', 1),
(4, 'sleep_latency', '入睡时间', 2),
(4, 'sleep_duration', '睡眠时间', 3),
(4, 'sleep_efficiency', '睡眠效率', 4),
(4, 'sleep_disorder', '睡眠障碍', 5),
(4, 'sleep_medication', '催眠药物', 6),
(4, 'daytime_dysfunction', '日间功能障碍', 7);

-- 初始化题目和选项 (以SCL-90为例，仅示例2道题)
INSERT INTO ps_question (scale_id, question_no, content, content_type, question_type, is_reverse, dimension_id, is_required) VALUES
(1, '1', '头痛', 1, 3, 0, 1, 1),
(1, '2', '神经过敏，心中不踏实', 1, 3, 0, 2, 1);

INSERT INTO ps_question_option (question_id, option_no, option_text, option_value, sort_order) VALUES
(1, '1', '从无', 1, 1),
(1, '2', '轻度', 2, 2),
(1, '3', '中度', 3, 3),
(1, '4', '偏重', 4, 4),
(1, '5', '严重', 5, 5),
(2, '1', '从无', 1, 1),
(2, '2', '轻度', 2, 2),
(2, '3', '中度', 3, 3),
(2, '4', '偏重', 4, 4),
(2, '5', '严重', 5, 5);

-- 初始化常模数据 (以SCL-90为例)
INSERT INTO ps_norm_data (scale_id, dimension_id, group_type, group_value, mean, std_dev, sample_size, norm_source) VALUES
(1, NULL, 'gender', 'male', 128.50, 38.70, 1000, '中国常模'),
(1, NULL, 'gender', 'female', 132.80, 40.20, 1000, '中国常模'),
(1, 1, 'gender', 'male', 1.35, 0.48, 1000, '中国常模'),
(1, 1, 'gender', 'female', 1.42, 0.52, 1000, '中国常模'),
(1, 4, 'gender', 'male', 1.65, 0.58, 1000, '中国常模'),
(1, 4, 'gender', 'female', 1.82, 0.62, 1000, '中国常模');
