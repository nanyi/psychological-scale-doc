-- ============================================================
-- 心理测评系统数据库初始化脚本
-- 数据库: psychological_scale
-- 版本: 1.0
-- 创建日期: 2026-03-12
-- 作者: Ryan
-- ============================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS psychological_scale 
    DEFAULT CHARACTER SET utf8mb4 
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE psychological_scale;

-- ============================================================
-- 1. 用户模块表
-- ============================================================

-- 用户表
CREATE TABLE IF NOT EXISTS sys_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(100) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(200) NOT NULL COMMENT '密码(BCrypt加密)',
    nickname VARCHAR(100) COMMENT '昵称',
    avatar VARCHAR(500) COMMENT '头像URL',
    phone VARCHAR(20) COMMENT '手机号',
    email VARCHAR(100) COMMENT '邮箱',
    user_type TINYINT NOT NULL DEFAULT 1 COMMENT '用户类型:1-个人,2-企业',
    gender TINYINT NOT NULL DEFAULT 0 COMMENT '性别:0-未知,1-男,2-女',
    birthday DATE COMMENT '生日',
    enterprise_id BIGINT COMMENT '企业ID',
    department_id BIGINT COMMENT '部门ID',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0-禁用,1-正常',
    last_login_ip VARCHAR(50) COMMENT '最后登录IP',
    last_login_time DATETIME COMMENT '最后登录时间',
    login_fail_count INT NOT NULL DEFAULT 0 COMMENT '登录失败次数',
    lock_until DATETIME COMMENT '锁定到期时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    create_by BIGINT COMMENT '创建人',
    update_by BIGINT COMMENT '更新人',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-正常,1-删除',
    version INT DEFAULT 0 COMMENT '版本号',
    INDEX idx_phone (phone),
    INDEX idx_enterprise_id (enterprise_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 企业表
CREATE TABLE IF NOT EXISTS sys_enterprise (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '企业ID',
    enterprise_name VARCHAR(200) NOT NULL COMMENT '企业名称',
    credit_code VARCHAR(50) UNIQUE COMMENT '统一社会信用代码',
    contact_name VARCHAR(100) COMMENT '联系人',
    contact_phone VARCHAR(20) COMMENT '联系电话',
    contact_email VARCHAR(100) COMMENT '联系邮箱',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '状态:0-待审核,1-正常,2-禁用',
    expire_time DATETIME COMMENT '到期时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-正常,1-删除'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业表';

-- 角色表
CREATE TABLE IF NOT EXISTS sys_role (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '角色ID',
    role_name VARCHAR(100) NOT NULL COMMENT '角色名称',
    role_code VARCHAR(50) NOT NULL UNIQUE COMMENT '角色编码',
    role_type TINYINT NOT NULL COMMENT '角色类型:1-系统角色,2-自定义角色',
    description VARCHAR(500) COMMENT '描述',
    is_system TINYINT NOT NULL DEFAULT 0 COMMENT '是否系统角色:0-否,1-是',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0-禁用,1-正常',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    create_by BIGINT COMMENT '创建人',
    update_by BIGINT COMMENT '更新人',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-正常,1-删除',
    version INT DEFAULT 0 COMMENT '版本号'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- 用户角色关联表
CREATE TABLE IF NOT EXISTS sys_user_role (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    create_by BIGINT COMMENT '创建人',
    update_by BIGINT COMMENT '更新人',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-正常,1-删除',
    version INT DEFAULT 0 COMMENT '版本号',
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- 权限表
CREATE TABLE IF NOT EXISTS sys_permission (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '权限ID',
    permission_name VARCHAR(100) NOT NULL COMMENT '权限名称',
    permission_code VARCHAR(100) NOT NULL UNIQUE COMMENT '权限编码',
    permission_type TINYINT NOT NULL COMMENT '类型:1-菜单目录,2-菜单,3-功能,4-数据',
    permission_desc VARCHAR(500) COMMENT '权限描述',
    resource VARCHAR(500) COMMENT '资源路径',
    method VARCHAR(10) COMMENT '请求方式',
    parent_id BIGINT COMMENT '父权限ID',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    icon VARCHAR(50) COMMENT '图标',
    path VARCHAR(500) COMMENT '路径',
    module VARCHAR(50) COMMENT '所属模块',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    create_by BIGINT COMMENT '创建人',
    update_by BIGINT COMMENT '更新人',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-正常,1-删除',
    version INT DEFAULT 0 COMMENT '版本号'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='权限表';

-- 角色权限关联表
CREATE TABLE IF NOT EXISTS sys_role_permission (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    permission_id BIGINT NOT NULL COMMENT '权限ID',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    create_by BIGINT COMMENT '创建人',
    update_by BIGINT COMMENT '更新人',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-正常,1-删除',
    version INT DEFAULT 0 COMMENT '版本号',
    INDEX idx_role_id (role_id),
    INDEX idx_permission_id (permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色权限关联表';

-- 部门表
CREATE TABLE IF NOT EXISTS sys_department (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '部门ID',
    department_name VARCHAR(100) NOT NULL COMMENT '部门名称',
    parent_id BIGINT NOT NULL DEFAULT 0 COMMENT '父部门ID（0=一级部门）',
    enterprise_id BIGINT COMMENT '企业ID',
    leader VARCHAR(50) COMMENT '负责人',
    phone VARCHAR(20) COMMENT '联系电话',
    email VARCHAR(100) COMMENT '邮箱',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    description VARCHAR(500) COMMENT '描述',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    create_by BIGINT COMMENT '创建人',
    update_by BIGINT COMMENT '更新人',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-正常，1-删除',
    version INT DEFAULT 0 COMMENT '版本号',
    INDEX idx_parent_id (parent_id),
    INDEX idx_enterprise_id (enterprise_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门表';

-- 用户分组表
CREATE TABLE IF NOT EXISTS sys_user_group (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分组ID',
    group_name VARCHAR(100) NOT NULL COMMENT '分组名称',
    group_type TINYINT NOT NULL COMMENT '类型:1-学生组,2-员工组,3-自定义',
    enterprise_id BIGINT COMMENT '企业ID',
    parent_id BIGINT COMMENT '父分组ID',
    description VARCHAR(500) COMMENT '描述',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    INDEX idx_enterprise_id (enterprise_id),
    INDEX idx_parent_id (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户分组表';

-- 用户分组关联表
CREATE TABLE IF NOT EXISTS sys_user_group_member (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    group_id BIGINT NOT NULL COMMENT '分组ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_group_id (group_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户分组关联表';

-- ============================================================
-- 2. 量表模块表
-- ============================================================

-- 量表分类表
CREATE TABLE IF NOT EXISTS ps_scale_category (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    category_name VARCHAR(100) NOT NULL COMMENT '分类名称',
    parent_id BIGINT NOT NULL DEFAULT 0 COMMENT '父分类ID（0=一级分类）',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    remark VARCHAR(500) COMMENT '备注',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0-禁用,1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    create_by BIGINT COMMENT '创建人',
    update_by BIGINT COMMENT '更新人',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-正常,1-删除',
    version INT DEFAULT 0 COMMENT '版本号',
    INDEX idx_parent_id (parent_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='量表分类表';

-- 量表表
CREATE TABLE IF NOT EXISTS ps_scale (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '量表ID',
    scale_code VARCHAR(32) NOT NULL UNIQUE COMMENT '量表编码',
    scale_name VARCHAR(200) NOT NULL COMMENT '量表名称',
    scale_name_en VARCHAR(200) COMMENT '英文名',
    category_id BIGINT COMMENT '分类ID',
    target_audience VARCHAR(200) COMMENT '适用人群',
    description TEXT COMMENT '描述',
    instruction TEXT COMMENT '指导语',
    cover VARCHAR(500) COMMENT '封面图URL',
    duration INT COMMENT '预计时长(分钟)',
    question_count INT COMMENT '题目数量',
    dimension_count INT COMMENT '维度数量',
    source_type TINYINT NOT NULL DEFAULT 1 COMMENT '来源:1-内置,2-第三方,3-自定义',
    third_party_id VARCHAR(100) COMMENT '第三方量表ID',
    platform_id BIGINT COMMENT '第三方平台ID',
    price DECIMAL(10,2) COMMENT '价格',
    age_range_min INT COMMENT '年龄范围最小值',
    age_range_max INT COMMENT '年龄范围最大值',
    applicable_gender TINYINT NOT NULL DEFAULT 0 COMMENT '适用性别:1-男,2-女,3-通用',
    attention TEXT COMMENT '注意事项',
    is_free TINYINT NOT NULL DEFAULT 0 COMMENT '是否免费:0-收费,1-免费',
    view_count INT NOT NULL DEFAULT 0 COMMENT '浏览次数',
    use_count INT NOT NULL DEFAULT 0 COMMENT '使用次数',
    publish_time DATETIME COMMENT '发布时间',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '状态:0-草稿,1-已发布,2-已下架',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    create_by BIGINT COMMENT '创建人',
    update_by BIGINT COMMENT '更新人',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-正常,1-删除',
    version INT DEFAULT 0 COMMENT '版本号',
    INDEX idx_category_id (category_id),
    INDEX idx_source_type (source_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='量表表';

-- 量表维度表
CREATE TABLE IF NOT EXISTS ps_scale_dimension (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '维度ID',
    scale_id BIGINT NOT NULL COMMENT '量表ID',
    dimension_code VARCHAR(32) NOT NULL COMMENT '维度编码',
    dimension_name VARCHAR(100) NOT NULL COMMENT '维度名称',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_scale_id (scale_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='量表维度表';

-- 量表因子表
CREATE TABLE IF NOT EXISTS ps_scale_factor (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '因子ID',
    dimension_id BIGINT NOT NULL COMMENT '维度ID',
    factor_code VARCHAR(32) NOT NULL COMMENT '因子编码',
    factor_name VARCHAR(100) NOT NULL COMMENT '因子名称',
    formula VARCHAR(500) COMMENT '计算公式',
    weight DECIMAL(5,2) COMMENT '权重',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_dimension_id (dimension_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='量表因子表';

-- 题目表
CREATE TABLE IF NOT EXISTS ps_question (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '题目ID',
    scale_id BIGINT NOT NULL COMMENT '量表ID',
    question_no VARCHAR(10) NOT NULL COMMENT '题目编号',
    content TEXT NOT NULL COMMENT '题目内容',
    content_type TINYINT NOT NULL DEFAULT 1 COMMENT '内容类型:1-文本,2-图片,3-音频',
    attachment_url VARCHAR(500) COMMENT '附件URL',
    question_type TINYINT NOT NULL COMMENT '题目类型:1-单选,2-多选,3-量表题,4-问答',
    is_reverse TINYINT NOT NULL DEFAULT 0 COMMENT '是否反向计分:0-否,1-是',
    dimension_id BIGINT COMMENT '所属维度ID',
    factor_id BIGINT COMMENT '所属因子ID',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    is_required TINYINT NOT NULL DEFAULT 1 COMMENT '是否必答:0-否,1-是',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_scale_id (scale_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='题目表';

-- 选项表
CREATE TABLE IF NOT EXISTS ps_question_option (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '选项ID',
    question_id BIGINT NOT NULL COMMENT '题目ID',
    option_no VARCHAR(10) NOT NULL COMMENT '选项编号',
    option_text VARCHAR(500) NOT NULL COMMENT '选项文本',
    option_value DECIMAL(10,2) NOT NULL COMMENT '选项分值',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_question_id (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='选项表';

-- 测评任务表
CREATE TABLE IF NOT EXISTS ps_assessment_task (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '任务ID',
    task_no VARCHAR(32) NOT NULL UNIQUE COMMENT '任务编号',
    user_id BIGINT NOT NULL COMMENT '被测评用户ID',
    scale_id BIGINT NOT NULL COMMENT '量表ID',
    enterprise_id BIGINT COMMENT '企业ID（企业安排时有值）',
    assigner_id BIGINT COMMENT '安排人ID（企业安排时有值）',
    task_type TINYINT NOT NULL COMMENT '任务类型：1-企业任务，2-个人任务',
    source_type TINYINT NOT NULL COMMENT '来源类型：1-企业分配，2-个人购买，3-自行设定',
    source_id BIGINT COMMENT '来源ID（订单ID/配额ID）',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待开始，1-进行中，2-已完成，3-已超时，4-已取消',
    progress INT NOT NULL DEFAULT 0 COMMENT '进度（当前题目/总题目）',
    start_time DATETIME COMMENT '开始时间',
    finish_time DATETIME COMMENT '完成时间',
    expire_time DATETIME COMMENT '过期时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-正常，1-删除',
    INDEX idx_user_id (user_id),
    INDEX idx_enterprise_id (enterprise_id),
    INDEX idx_scale_id (scale_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测评任务表';

-- 测评记录表
CREATE TABLE IF NOT EXISTS ps_exam_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    task_id BIGINT COMMENT '测评任务ID（关联测评任务）',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    scale_id BIGINT NOT NULL COMMENT '量表ID',
    enterprise_id BIGINT COMMENT '企业ID',
    record_no VARCHAR(50) NOT NULL UNIQUE COMMENT '记录编号',
    exam_status TINYINT NOT NULL DEFAULT 0 COMMENT '测评状态：0-待开始，1-进行中，2-已完成，3-已暂停，4-已取消',
    total_score INT COMMENT '总分',
    score DECIMAL(5,2) COMMENT '得分',
    correct_count INT COMMENT '正确数',
    wrong_count INT COMMENT '错误数',
    blank_count INT COMMENT '空白数',
    answer_time INT COMMENT '答题时间(秒)',
    start_time DATETIME COMMENT '开始时间',
    submit_time DATETIME COMMENT '提交时间',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    device_info VARCHAR(200) COMMENT '设备信息',
    source VARCHAR(50) COMMENT '来源：pc、小程序、h5',
    dimension_scores TEXT COMMENT '维度得分JSON',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    create_by BIGINT COMMENT '创建人',
    update_by BIGINT COMMENT '更新人',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-正常，1-删除',
    version INT DEFAULT 0 COMMENT '版本号',
    INDEX idx_task_id (task_id),
    INDEX idx_user_id (user_id),
    INDEX idx_scale_id (scale_id),
    INDEX idx_enterprise_id (enterprise_id),
    INDEX idx_record_no (record_no),
    INDEX idx_exam_status (exam_status),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测评记录表';

-- 答题记录表
CREATE TABLE IF NOT EXISTS ps_answer_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    record_id BIGINT NOT NULL COMMENT '测评记录ID（关联测评记录）',
    question_id BIGINT NOT NULL COMMENT '题目ID',
    answer_value VARCHAR(500) COMMENT '答案值',
    answer_text TEXT COMMENT '答案文本',
    score DECIMAL(10,2) COMMENT '得分',
    answer_time INT COMMENT '答题用时(秒)',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    INDEX idx_record_id (record_id),
    INDEX idx_question_id (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='答题记录表';

-- ============================================================
-- 3. 订单模块表
-- ============================================================

-- 订单表
CREATE TABLE IF NOT EXISTS ps_order (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    order_no VARCHAR(32) NOT NULL UNIQUE COMMENT '订单编号',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    order_type TINYINT NOT NULL COMMENT '订单类型:1-个人购买,2-企业团购',
    total_amount DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额',
    pay_amount DECIMAL(10,2) NOT NULL COMMENT '实付金额',
    pay_channel TINYINT COMMENT '支付渠道:1-微信,2-支付宝',
    order_status TINYINT NOT NULL DEFAULT 0 COMMENT '状态:0-待支付,1-已支付,2-已取消,3-已退款,4-部分退款',
    enterprise_id BIGINT COMMENT '企业ID',
    expire_time DATETIME COMMENT '订单过期时间',
    pay_time DATETIME COMMENT '支付时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-正常,1-删除',
    INDEX idx_user_id (user_id),
    INDEX idx_order_status (order_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- 订单项表
CREATE TABLE IF NOT EXISTS ps_order_item (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单项ID',
    order_no VARCHAR(32) NOT NULL COMMENT '订单编号',
    scale_id BIGINT NOT NULL COMMENT '量表ID',
    scale_name VARCHAR(200) NOT NULL COMMENT '量表名称',
    price DECIMAL(10,2) NOT NULL COMMENT '购买单价',
    quantity INT NOT NULL DEFAULT 1 COMMENT '购买数量',
    amount DECIMAL(10,2) NOT NULL COMMENT '小计金额',
    refund_status TINYINT NOT NULL DEFAULT 0 COMMENT '退款状态:0-未退款,1-已退款,2-部分退款',
    refund_amount DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '退款金额',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_order_no (order_no),
    INDEX idx_scale_id (scale_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单项表';

-- 退款记录表
CREATE TABLE IF NOT EXISTS ps_refund (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '退款ID',
    refund_no VARCHAR(32) NOT NULL UNIQUE COMMENT '退款编号',
    order_no VARCHAR(32) NOT NULL COMMENT '原订单编号',
    order_item_id BIGINT NOT NULL COMMENT '订单项ID',
    refund_amount DECIMAL(10,2) NOT NULL COMMENT '退款金额',
    refund_reason VARCHAR(500) COMMENT '退款原因',
    refund_status TINYINT NOT NULL DEFAULT 0 COMMENT '状态:0-处理中,1-成功,2-失败',
    refund_channel TINYINT COMMENT '退款渠道',
    refund_time DATETIME COMMENT '退款时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    INDEX idx_order_no (order_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退款记录表';

-- 用户配额表
CREATE TABLE IF NOT EXISTS sys_user_quota (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '配额ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    scale_id BIGINT NOT NULL COMMENT '量表ID',
    total_quantity INT NOT NULL COMMENT '总量',
    used_quantity INT NOT NULL DEFAULT 0 COMMENT '已使用',
    expire_time DATETIME COMMENT '过期时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    UNIQUE KEY uk_user_scale (user_id, scale_id),
    INDEX idx_user_id (user_id),
    INDEX idx_scale_id (scale_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户配额表';

-- 企业配额表
CREATE TABLE IF NOT EXISTS sys_enterprise_quota (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '配额ID',
    enterprise_id BIGINT NOT NULL COMMENT '企业ID',
    scale_id BIGINT NOT NULL COMMENT '量表ID',
    total_quantity INT NOT NULL COMMENT '总量',
    used_quantity INT NOT NULL DEFAULT 0 COMMENT '已使用',
    expire_time DATETIME COMMENT '过期时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    UNIQUE KEY uk_enterprise_scale (enterprise_id, scale_id),
    INDEX idx_enterprise_id (enterprise_id),
    INDEX idx_scale_id (scale_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业配额表';

-- ============================================================
-- 4. 报告模块表
-- ============================================================

-- 报告表
CREATE TABLE IF NOT EXISTS ps_report (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '报告ID',
    report_no VARCHAR(32) NOT NULL UNIQUE COMMENT '报告编号',
    task_id BIGINT NOT NULL COMMENT '测评任务ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    scale_id BIGINT NOT NULL COMMENT '量表ID',
    scale_name VARCHAR(200) NOT NULL COMMENT '量表名称',
    total_score DECIMAL(10,2) COMMENT '总分',
    dimension_scores TEXT COMMENT '维度得分(JSON)',
    result_level VARCHAR(50) COMMENT '结果等级',
    conclusion TEXT COMMENT '结论',
    suggestions TEXT COMMENT '建议(JSON数组)',
    report_content TEXT COMMENT '完整报告内容(JSON)',
    source_type TINYINT NOT NULL DEFAULT 1 COMMENT '来源:1-本地生成,2-第三方API',
    third_party_report TEXT COMMENT '第三方报告原始数据',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '状态:0-生成中,1-已生成,2-生成失败',
    generate_time DATETIME COMMENT '生成时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-正常,1-删除',
    INDEX idx_user_id (user_id),
    INDEX idx_task_id (task_id),
    INDEX idx_scale_id (scale_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报告表';

-- 报告模板表
CREATE TABLE IF NOT EXISTS ps_report_template (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '模板ID',
    scale_id BIGINT NOT NULL COMMENT '量表ID',
    template_name VARCHAR(100) NOT NULL COMMENT '模板名称',
    template_type TINYINT NOT NULL COMMENT '类型:1-简版,2-详版,3-专业版',
    template_content TEXT NOT NULL COMMENT '模板内容(HTML)',
    variables VARCHAR(1000) COMMENT '变量列表(JSON)',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '状态:0-草稿,1-已发布',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    INDEX idx_scale_id (scale_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报告模板表';

-- ============================================================
-- 5. 第三方对接模块表
-- ============================================================

-- 第三方平台表
CREATE TABLE IF NOT EXISTS ps_third_party_platform (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '平台ID',
    platform_name VARCHAR(100) NOT NULL COMMENT '平台名称',
    api_base_url VARCHAR(200) NOT NULL COMMENT 'API基础地址',
    app_key VARCHAR(100) NOT NULL COMMENT 'AppKey',
    app_secret VARCHAR(500) NOT NULL COMMENT 'AppSecret(加密)',
    callback_url VARCHAR(200) COMMENT '回调地址',
    sync_strategy TINYINT NOT NULL DEFAULT 1 COMMENT '同步策略:1-实时,2-定时',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0-停用,1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='第三方平台表';

-- 量表映射表
CREATE TABLE IF NOT EXISTS ps_scale_mapping (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '映射ID',
    local_scale_id BIGINT NOT NULL COMMENT '本地量表ID',
    third_party_id VARCHAR(100) NOT NULL COMMENT '第三方量表ID',
    platform_id BIGINT NOT NULL COMMENT '平台ID',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_local_scale_id (local_scale_id),
    INDEX idx_platform_id (platform_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='量表映射表';

-- 第三方答题记录表
CREATE TABLE IF NOT EXISTS ps_third_party_answer (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    scale_id BIGINT NOT NULL COMMENT '量表ID',
    third_party_id VARCHAR(100) COMMENT '第三方量表ID',
    task_id VARCHAR(32) COMMENT '第三方任务ID',
    answers TEXT COMMENT '答题记录(JSON)',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '状态:0-待提交,1-待评分,2-已完成,3-失败',
    report_data TEXT COMMENT '报告数据(JSON)',
    submit_time DATETIME COMMENT '提交时间',
    complete_time DATETIME COMMENT '完成时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME COMMENT '更新时间',
    INDEX idx_user_id (user_id),
    INDEX idx_scale_id (scale_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='第三方答题记录表';

-- ============================================================
-- 6. 数据分析模块表
-- ============================================================

-- 常模数据表
CREATE TABLE IF NOT EXISTS ps_norm_data (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '常模ID',
    scale_id BIGINT NOT NULL COMMENT '量表ID',
    dimension_id BIGINT COMMENT '维度ID',
    group_type VARCHAR(20) NOT NULL COMMENT '分组类型',
    group_value VARCHAR(50) NOT NULL COMMENT '分组值',
    mean DECIMAL(10,2) NOT NULL COMMENT '平均分',
    std_dev DECIMAL(10,2) NOT NULL COMMENT '标准差',
    sample_size INT COMMENT '样本量',
    norm_source VARCHAR(100) COMMENT '常模来源',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_scale_id (scale_id),
    INDEX idx_group (scale_id, group_type, group_value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='常模数据表';

-- 统计数据表
CREATE TABLE IF NOT EXISTS ps_statistics (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '统计ID',
    stat_type VARCHAR(50) NOT NULL COMMENT '统计类型',
    stat_date DATE NOT NULL COMMENT '统计日期',
    dimension VARCHAR(50) COMMENT '维度',
    dimension_value VARCHAR(100) COMMENT '维度值',
    metric_name VARCHAR(50) NOT NULL COMMENT '指标名',
    metric_value DECIMAL(20,2) NOT NULL COMMENT '指标值',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_stat_type (stat_type),
    INDEX idx_stat_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='统计数据表';

-- ============================================================
-- 7. 初始化数据
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
INSERT INTO sys_role (role_name, role_code, description, status) VALUES
('超级管理员', 'SUPER_ADMIN', '拥有系统所有权限', 1),
('企业管理员', 'ENTERPRISE_ADMIN', '企业管理权限', 1),
('测评师', 'ASSESSOR', '测评管理权限', 1),
('普通用户', 'USER', '普通用户权限', 1);

-- 初始化权限数据
INSERT INTO sys_permission (permission_name, permission_code, permission_type, parent_id, module) VALUES
-- 用户管理模块
('用户管理', 'user:manage', 1, NULL, 'MOD-001'),
('用户列表', 'user:list', 1, 1, 'MOD-001'),
('用户新增', 'user:add', 1, 1, 'MOD-001'),
('用户编辑', 'user:edit', 1, 1, 'MOD-001'),
('用户删除', 'user:delete', 1, 1, 'MOD-001'),
-- 量表管理模块
('量表管理', 'scale:manage', 1, NULL, 'MOD-002'),
('量表列表', 'scale:list', 1, 6, 'MOD-002'),
('量表新增', 'scale:add', 1, 6, 'MOD-002'),
('量表编辑', 'scale:edit', 1, 6, 'MOD-002'),
('量表删除', 'scale:delete', 1, 6, 'MOD-002'),
-- 订单管理模块
('订单管理', 'order:manage', 1, NULL, 'MOD-003'),
('订单列表', 'order:list', 1, 11, 'MOD-003'),
('订单退款', 'order:refund', 1, 11, 'MOD-003'),
-- 数据分析模块
('数据分析', 'analysis:view', 1, NULL, 'MOD-005'),
('数据导出', 'analysis:export', 1, 15, 'MOD-005'),
-- 报告管理模块
('报告管理', 'report:manage', 1, NULL, 'MOD-006'),
('报告查看', 'report:view', 1, 17, 'MOD-006'),
('报告导出', 'report:export', 1, 17, 'MOD-006');

-- 为超级管理员角色分配所有权限
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 1, id FROM sys_permission;

-- 初始化演示用户 (密码: 123456, BCrypt加密)
INSERT INTO sys_user (username, password, nickname, phone, email, user_type, status) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '系统管理员', '13800138000', 'admin@example.com', 1, 1);

-- 关联管理员角色
INSERT INTO sys_user_role (user_id, role_id) VALUES (1, 1);

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

-- ============================================================
-- 8. 初始化数据完成
-- ============================================================
-- 注意：定时任务（过期配额清理、过期任务处理）由应用层Spring Boot实现
-- 建议使用 @Scheduled 注解或 XXL-Job 进行定时调度
-- ============================================================

-- 定时任务实现参考（应用层代码）：
-- 
-- @Scheduled(cron = "0 0 2 * * ?") // 每天凌晨2点执行
-- public void expireQuotas() {
--     // 1. 过期用户配额
--     LambdaUpdateWrapper<UserQuota> userQuotaWrapper = new LambdaUpdateWrapper<>();
--     userQuotaWrapper.le(UserQuota::getExpireTime, LocalDateTime.now())
--                    .gt(UserQuota::getUsedQuantity, 0)
--                    .setSql("used_quantity = total_quantity");
--     userQuotaMapper.update(null, userQuotaWrapper);
--     
--     // 2. 过期企业配额
--     LambdaUpdateWrapper<EnterpriseQuota> enterpriseQuotaWrapper = new LambdaUpdateWrapper<>();
--     enterpriseQuotaWrapper.le(EnterpriseQuota::getExpireTime, LocalDateTime.now())
--                           .gt(EnterpriseQuota::getUsedQuantity, 0)
--                           .setSql("used_quantity = total_quantity");
--     enterpriseQuotaMapper.update(null, enterpriseQuotaWrapper);
-- }
-- 
-- @Scheduled(cron = "0 0 3 * * ?") // 每天凌晨3点执行
-- public void expireTasks() {
--     LambdaUpdateWrapper<AssessmentTask> taskWrapper = new LambdaUpdateWrapper<>();
--     taskWrapper.eq(AssessmentTask::getStatus, 0)
--                .lt(AssessmentTask::getExpireTime, LocalDateTime.now())
--                .set(AssessmentTask::getStatus, 3);
--     assessmentTaskMapper.update(null, taskWrapper);
-- }

-- ============================================================
-- 脚本执行完成
-- ============================================================
