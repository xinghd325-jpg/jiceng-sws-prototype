# 社会工作服务板块演示原型 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 交付可离线运行、全量深交互的 `pc.html` + `h5.html`，嵌入金华基层智治壳演示「社会工作服务」PC 板块与群众 H5 端，并共享 `localStorage` 跑通闭环。

**Architecture:** 单文件双端 SPA；统一 `sws_v1_*` 领域存储 + `DataAPI` 权限过滤；PC 为顶栏一级菜单 + 浅色侧栏 + 列表/右抽屉；H5 为手机框 + 底栏「首页/服务/我的」。无构建无后端。

**Tech Stack:** 原生 HTML/CSS/JS；Remix Icon（CDN 线性图标）；`localStorage`；可选浏览器直接打开验证。

## Global Constraints

- 交付仅 `pc.html`、`h5.html`（外加 docs）；浏览器直接打开
- 存储前缀 `sws_v1_`；会话键 `sws_v1_session_pc` / `sws_v1_session_h5`
- UI：政务 Ant/Element 风；圆角 ≤4px；禁渐变业务背景、重阴影、玻璃态、装饰动画、emoji、彩色填充图标
- PC 列表：绿「+ 新增」、蓝查询、浅蓝表头、操作文字链；新增/编辑/查看 = **右侧抽屉**
- 顶栏在「首页」与「应急管理指挥」之间插入「社会工作服务」
- H5：首页全量入口；服务 Tab 仅设施+力量；帮扶进度四步且无咨询电话
- 帮扶状态机：`submitted` → `rejected` | `assigned` → `returned` | `completed`（审核通过即办结）
- 功能与字段以 spec `docs/superpowers/specs/2026-07-24-social-work-service-demo-design.md` 为准
- 本仓库若无 git：Task 0 初始化后再按任务 commit；若用户禁止 git 则跳过 commit 步骤并在任务末做文件保存确认

---

## File Structure

| 文件 | 职责 |
|------|------|
| `pc.html` | PC 端全部：tokens、shell、DataAPI 副本、种子、各管理页、抽屉 UI |
| `h5.html` | H5 端全部：tokens、三 Tab shell、同一 DataAPI/种子协议、群众业务页 |
| `docs/superpowers/specs/2026-07-24-social-work-service-demo-design.md` | 设计真源（只读） |
| `docs/superpowers/plans/2026-07-24-social-work-service-demo.md` | 本计划 |

两端须 **复制同一套** 存储 key、实体字段、权限函数逻辑（保持行为一致；单文件约束下允许代码重复）。

建议 `pc.html` / `h5.html` 内部用注释分区：

```text
/* === 0. TOKENS/CSS === */
/* === 1. SEED & STORAGE === */
/* === 2. DATA API & ACL === */
/* === 3. UI KIT === */
/* === 4. PAGES === */
/* === 5. SHELL & ROUTER === */
/* === 6. BOOT === */
```

---

### Task 0: 仓库与空壳骨架

**Files:**
- Create: `pc.html`
- Create: `h5.html`
- Create: `.gitignore`（含 `.DS_Store`）

**Interfaces:**
- Produces: 两个可打开的 HTML，含标题与空根节点 `#app`

- [ ] **Step 1: 初始化 git（若尚未初始化）**

```bash
cd "/Users/xhd/Documents/AI/基层智治/基层智治升级迭代/社会工作服务端"
git init
printf ".DS_Store\n.~*\n" > .gitignore
```

- [ ] **Step 2: 写入最小 `pc.html`**

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>金华市基层智治综合应用 - 社会工作服务</title>
  <link href="https://cdn.jsdelivr.net/npm/remixicon@4.2.0/fonts/remixicon.css" rel="stylesheet" />
  <style>
    :root {
      --color-primary: #1677FF;
      --color-success: #52C41A;
      --color-danger: #FF4D4F;
      --color-warning: #FAAD14;
      --color-border: #D9D9D9;
      --color-bg: #F0F2F5;
      --color-bg-elevated: #FFFFFF;
      --color-text: rgba(0,0,0,0.88);
      --color-text-secondary: rgba(0,0,0,0.65);
      --radius: 2px;
      --control-height: 32px;
      --font-size: 14px;
      --header-height: 48px;
      --sidebar-width: 220px;
      --drawer-width: 640px;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, "Microsoft YaHei", "PingFang SC", sans-serif;
      font-size: var(--font-size);
      color: var(--color-text);
      background: var(--color-bg);
    }
    #app { min-height: 100vh; }
  </style>
</head>
<body>
  <div id="app">PC 骨架加载中</div>
  <script>
    /* === sections filled in later tasks === */
    document.getElementById("app").textContent = "社会工作服务 PC 原型骨架 OK";
  </script>
</body>
</html>
```

- [ ] **Step 3: 写入最小 `h5.html`**

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
  <title>社会工作服务 - 群众端</title>
  <link href="https://cdn.jsdelivr.net/npm/remixicon@4.2.0/fonts/remixicon.css" rel="stylesheet" />
  <style>
    :root {
      --color-primary: #1677FF;
      --color-success: #52C41A;
      --color-danger: #FF4D4F;
      --color-border: #D9D9D9;
      --color-bg: #F5F5F5;
      --color-bg-elevated: #FFFFFF;
      --radius: 2px;
      --phone-width: 375px;
      --phone-height: 812px;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, "Microsoft YaHei", "PingFang SC", sans-serif;
      font-size: 14px;
      background: #e8e8e8;
      color: rgba(0,0,0,0.88);
    }
    #app { min-height: 100vh; }
  </style>
</head>
<body>
  <div id="app">H5 骨架加载中</div>
  <script>
    document.getElementById("app").textContent = "社会工作服务 H5 原型骨架 OK";
  </script>
</body>
</html>
```

- [ ] **Step 4: 浏览器验证骨架**

Run: 用浏览器打开 `pc.html` 与 `h5.html`  
Expected: 分别显示「PC 原型骨架 OK」「H5 原型骨架 OK」，无控制台报错

- [ ] **Step 5: Commit**

```bash
git add pc.html h5.html .gitignore
git commit -m "chore: scaffold pc.html and h5.html shells"
```

---

### Task 1: 共享领域种子与 Storage 层（先写入 pc.html，再同步 h5.html）

**Files:**
- Modify: `pc.html`
- Modify: `h5.html`

**Interfaces:**
- Produces:
  - `const STORE_PREFIX = 'sws_v1_'`
  - `function storageGet(key): any`
  - `function storageSet(key, value): void`
  - `function ensureSeed(forceReset?: boolean): void`
  - `function resetDemoData(): void`
  - Seed keys（完整列表）见 Step 2

- [ ] **Step 1: 在 `pc.html` 的 script 顶部实现 storage 工具**

```javascript
const STORE_PREFIX = "sws_v1_";
const KEYS = {
  meta: STORE_PREFIX + "meta",
  orgs: STORE_PREFIX + "orgs",
  depts: STORE_PREFIX + "depts",
  pcSession: STORE_PREFIX + "session_pc",
  h5Session: STORE_PREFIX + "session_h5",
  residents: STORE_PREFIX + "residents",
  notices: STORE_PREFIX + "notices",
  activities: STORE_PREFIX + "activities",
  activitySignups: STORE_PREFIX + "activity_signups",
  affairs: STORE_PREFIX + "affairs",
  serviceItems: STORE_PREFIX + "service_items",
  suggestionInbox: STORE_PREFIX + "suggestion_inbox",
  collectCampaigns: STORE_PREFIX + "collect_campaigns",
  suggestions: STORE_PREFIX + "suggestions",
  surveys: STORE_PREFIX + "surveys",
  surveyAnswers: STORE_PREFIX + "survey_answers",
  topics: STORE_PREFIX + "topics",
  topicComments: STORE_PREFIX + "topic_comments",
  topicVotes: STORE_PREFIX + "topic_votes",
  facilities: STORE_PREFIX + "facilities",
  forces: STORE_PREFIX + "forces",
  vulnerablePersons: STORE_PREFIX + "vulnerable_persons",
  aidPolicies: STORE_PREFIX + "aid_policies",
  foundations: STORE_PREFIX + "foundations",
  assistRecords: STORE_PREFIX + "assist_records",
  assistApplications: STORE_PREFIX + "assist_applications",
  emergingObjects: STORE_PREFIX + "emerging_objects",
  emergingParty: STORE_PREFIX + "emerging_party",
  emergingGovernance: STORE_PREFIX + "emerging_governance",
  baseVillage: STORE_PREFIX + "base_village",
  baseConsult: STORE_PREFIX + "base_consult",
  baseLists: STORE_PREFIX + "base_lists",
  baseTeams: STORE_PREFIX + "base_teams",
};

function storageGet(key) {
  const raw = localStorage.getItem(key);
  if (raw == null) return null;
  try { return JSON.parse(raw); } catch (e) { return null; }
}
function storageSet(key, value) {
  localStorage.setItem(key, JSON.stringify(value));
}
function uid(prefix) {
  return prefix + "_" + Date.now().toString(36) + "_" + Math.random().toString(36).slice(2, 7);
}
function nowISO() {
  return new Date().toISOString();
}
```

- [ ] **Step 2: 实现 `buildSeed()` 返回完整初始数据对象**

必须包含（字段可扩展但下列必有）：

```javascript
function buildSeed() {
  const orgs = [
    { id: "org_city", name: "金华市", level: "city", parentId: null, path: ["org_city"] },
    { id: "org_wc", name: "婺城区", level: "district", parentId: "org_city", path: ["org_city", "org_wc"] },
    { id: "org_cx", name: "城西街道", level: "town", parentId: "org_wc", path: ["org_city", "org_wc", "org_cx"] },
    { id: "org_xf", name: "幸福社区", level: "village", parentId: "org_cx", path: ["org_city", "org_wc", "org_cx", "org_xf"] },
    { id: "org_mf", name: "民丰社区", level: "village", parentId: "org_cx", path: ["org_city", "org_wc", "org_cx", "org_mf"] },
    { id: "org_jd", name: "金东区", level: "district", parentId: "org_city", path: ["org_city", "org_jd"] },
  ];
  const depts = [
    { id: "dept_center", orgId: "org_cx", name: "综合信息指挥室", role: "center" },
    { id: "dept_mz", orgId: "org_cx", name: "民政办", role: "department" },
    { id: "dept_sh", orgId: "org_cx", name: "社会事务办", role: "department" },
  ];
  // residents ≥2；notices/activities/… 各 5～12 条
  // assistApplications 至少：
  //   1 条 submitted 待中心
  //   1 条 assigned 待部门
  // 活动 1 条 published 可报名；征集 1 条 open；议题 1 条 voting
  // 省级回流实体各 ≥3 条，含 source、syncedAt
  return { orgs, depts, /* ...全部 KEYS 对应数组 */ };
}
```

实现时把每类数组写全（禁止留空数组作为最终种子）。每条业务数据带 `orgId/orgLevel/orgName/status/createdAt`。

- [ ] **Step 3: 实现 ensureSeed / resetDemoData**

```javascript
function ensureSeed(forceReset) {
  const meta = storageGet(KEYS.meta);
  if (forceReset || !meta || meta.version !== 1) {
    const seed = buildSeed();
    Object.keys(KEYS).forEach((k) => {
      if (k === "pcSession" || k === "h5Session" || k === "meta") return;
      if (seed[k] !== undefined) storageSet(KEYS[k], seed[k]);
    });
    // map seed property names to KEYS carefully in implementation
    storageSet(KEYS.meta, { version: 1, seededAt: nowISO() });
    if (!storageGet(KEYS.pcSession)) {
      storageSet(KEYS.pcSession, {
        orgId: "org_cx",
        userName: "中心管理员",
        role: "center", // center | department | admin | village
        deptId: "dept_center",
      });
    }
    if (!storageGet(KEYS.h5Session)) {
      storageSet(KEYS.h5Session, {
        userId: "res_001",
        userName: "张先生",
        orgId: "org_xf",
      });
    }
  }
}
function resetDemoData() {
  ensureSeed(true);
}
```

注意：`buildSeed` 返回值的键名与 `storageSet` 映射在实现里写明确的赋值列表，勿依赖隐式同名。

- [ ] **Step 4: boot 时调用 ensureSeed，console 校验条数**

```javascript
ensureSeed(false);
console.log("notices", (storageGet(KEYS.notices) || []).length);
console.log("assistApplications", (storageGet(KEYS.assistApplications) || []).length);
```

- [ ] **Step 5: 浏览器验证**

Run: 打开 `pc.html`，DevTools → Application → Local Storage  
Expected: 存在多个 `sws_v1_*` 键；`assist_applications` 含 `submitted` 与 `assigned`；无 JS 错误

- [ ] **Step 6: 将相同 SEED & STORAGE 代码块复制到 `h5.html` 并 boot**

Expected: 打开 H5 不覆盖已有数据（`forceReset=false`）；与 PC 读到同一批 notices

- [ ] **Step 7: Commit**

```bash
git add pc.html h5.html
git commit -m "feat: add sws_v1 seed data and storage helpers"
```

---

### Task 2: DataAPI 与组织权限

**Files:**
- Modify: `pc.html`
- Modify: `h5.html`

**Interfaces:**
- Produces:
  - `function getPcSession()` / `setPcSession(s)`
  - `function getH5Session()` / `setH5Session(s)`
  - `function getOrg(id)` / `function getOrgDescendants(orgId): string[]`（含自身）
  - `function canManage(record): boolean` — `record.orgId === session.orgId`
  - `function listVisible(key, opts): array` — PC 向下可见；H5 按模块规则
  - `function getById(key, id)` / `function saveRecord(key, record)` / `function removeRecord(key, id)`
  - `const VISIBILITY = { notices: 'upward', affairs: 'village', ... }`

- [ ] **Step 1: 组织树辅助函数**

```javascript
function getAll(key) { return storageGet(key) || []; }
function getOrg(id) { return getAll(KEYS.orgs).find((o) => o.id === id) || null; }
function getOrgDescendants(orgId) {
  return getAll(KEYS.orgs)
    .filter((o) => (o.path || []).includes(orgId))
    .map((o) => o.id);
}
function isAncestorOrg(ancestorId, childId) {
  const child = getOrg(childId);
  return !!(child && (child.path || []).includes(ancestorId));
}
```

- [ ] **Step 2: PC 列表可见性与 canManage**

```javascript
function getPcSession() { return storageGet(KEYS.pcSession); }
function listForPc(key) {
  const session = getPcSession();
  const ids = new Set(getOrgDescendants(session.orgId));
  return getAll(key).filter((r) => ids.has(r.orgId) && !r.deleted);
}
function canManage(record) {
  const session = getPcSession();
  return record && record.orgId === session.orgId;
}
```

- [ ] **Step 3: H5 可见性（按 spec 规则）**

```javascript
function listForH5(moduleKey) {
  const session = getH5Session();
  const userOrg = getOrg(session.orgId);
  const path = userOrg ? userOrg.path : [];
  const all = getAll(moduleKey).filter((r) => !r.deleted && r.status === "published");
  // notices/serviceItems/facilities/forces/aidPolicies/foundations: orgId in path (本级+上级)
  // affairs/topics: orgId === session.orgId
  // activities/campaigns/surveys: published/open AND scope matches
  // 实现时对每个 key 分支写清
  return all;
}
```

`suggestions` / `assistApplications` 的「本人」过滤：`r.userId === session.userId`。

- [ ] **Step 4: 通用 CRUD**

```javascript
function saveRecord(key, record) {
  const list = getAll(key);
  const idx = list.findIndex((x) => x.id === record.id);
  if (idx >= 0) list[idx] = record; else list.unshift(record);
  storageSet(key, list);
  return record;
}
function removeRecord(key, id) {
  const list = getAll(key).map((x) => (x.id === id ? { ...x, deleted: true } : x));
  storageSet(key, list);
}
```

- [ ] **Step 5: 浏览器控制台验证权限**

```javascript
// PC session org_cx 时 listForPc(notices) 应含下级社区数据
// canManage(市级记录) === false
// H5 session org_xf 时 listForH5 notices 含市级+区+街+本社区 published
```

- [ ] **Step 6: 同步 API 到 h5.html 后 Commit**

```bash
git add pc.html h5.html
git commit -m "feat: add DataAPI and org-scoped visibility"
```

---

### Task 3: PC UI Kit（toast、确认框、表格、右抽屉）

**Files:**
- Modify: `pc.html`

**Interfaces:**
- Produces:
  - `toast(message, type?)`
  - `confirmDialog({ title, content, onOk })`
  - `renderTable(container, { columns, rows, rowActions })`
  - `openDrawer({ title, mode: 'create'|'edit'|'view', bodyHtml, onSubmit? })`
  - `closeDrawer()`
  - CSS：筛选卡、绿新增、浅蓝表头、抽屉 640px

- [ ] **Step 1: 写入 PC 布局与组件 CSS**

必须包含：`.pc-header` 纯色蓝顶栏；`.pc-sidebar` 浅底；`.filter-card`；`.btn` / `.btn-primary` / `.btn-success` / `.btn-default` / `.btn-danger-ghost`；`.table-wrap th` 浅蓝；`.drawer` 右侧 fixed；`.drawer-mask`；圆角 `var(--radius)`；无 box-shadow 大阴影（可用 1px border）。

- [ ] **Step 2: 实现 toast + confirmDialog**

```javascript
function toast(msg) {
  let el = document.getElementById("sws-toast");
  if (!el) {
    el = document.createElement("div");
    el.id = "sws-toast";
    el.style.cssText = "position:fixed;top:64px;left:50%;transform:translateX(-50%);background:#000a;color:#fff;padding:8px 16px;border-radius:2px;z-index:4000;font-size:13px";
    document.body.appendChild(el);
  }
  el.textContent = msg;
  el.style.display = "block";
  clearTimeout(el._t);
  el._t = setTimeout(() => { el.style.display = "none"; }, 2000);
}
```

确认框：居中约 400px 白底、标题、内容、取消/确定。

- [ ] **Step 3: 实现 openDrawer / closeDrawer**

```javascript
function openDrawer({ title, mode, bodyHtml, onSubmit }) {
  // mask + panel
  // header: title | [提交 if mode!=='view'] [关闭]
  // body: bodyHtml
  // 提交调用 onSubmit，返回 false 则不关闭
}
function closeDrawer() { /* remove or hide mask+panel */ }
```

查看模式：仅关闭按钮；表单控件 `disabled` 或纯文本展示。

- [ ] **Step 4: 实现 renderTable**

```javascript
function renderTable(el, { columns, rows, rowActions }) {
  // columns: [{ key, title, width?, render?(row) }]
  // rowActions: (row) => [{ label, onClick, show? }]
  // 操作列渲染为蓝色文字链，空格分隔
}
```

- [ ] **Step 5: 临时页验证 UI Kit**

在 boot 渲染：筛选假表单 + 绿新增打开抽屉 + 5 行假表格。  
Expected: 视觉对照 spec 截图特征（绿新增、浅蓝表头、右抽屉顶栏提交/关闭）

- [ ] **Step 6: Commit**

```bash
git add pc.html
git commit -m "feat(pc): add toast, confirm, table, right drawer UI kit"
```

---

### Task 4: PC Shell（顶栏一级菜单 + 侧栏路由）

**Files:**
- Modify: `pc.html`

**Interfaces:**
- Produces:
  - `const PC_MENU = [...]` 树（与 spec §4.2 一致）
  - `function navigate(routeId)`
  - `function renderShell()`
  - `Pages = { [routeId]: () => html or mount(container) }`

- [ ] **Step 1: 定义顶栏一级菜单数组与侧栏树**

```javascript
const TOP_MENUS = [
  { id: "home", label: "首页", enabled: false },
  { id: "sws", label: "社会工作服务", enabled: true },
  { id: "emergency", label: "应急管理指挥", enabled: false },
  { id: "event", label: "事件管理", enabled: false },
  { id: "warning", label: "预警管理", enabled: false },
  { id: "task", label: "任务管理", enabled: false },
  { id: "dispute", label: "矛调调处", enabled: false },
  { id: "data", label: "数据管理", enabled: false },
  // …贯通/绩效/办公等可列但 enabled:false
];
```

侧栏 `PC_MENU` 含 routeId：如 `emerging-objects`, `notice-list`, `assist-apply`, …

- [ ] **Step 2: 渲染顶栏 + 侧栏 + 内容 `#pc-content`**

- 顶栏 Logo 文案：`金华市基层智治综合应用 -智治系统`
- 「社会工作服务」默认选中高亮
- 点击其它一级：`toast("本演示仅开放社会工作服务")`
- 侧栏分组折叠；线性图标 `ri-*`
- 右上角：当前组织 `<select>` 绑定 `setPcSession` + `navigate` 刷新；用户名

- [ ] **Step 3: 路由**

```javascript
const Pages = {};
function navigate(routeId) {
  sessionStorage.setItem("sws_pc_route", routeId);
  // highlight sidebar
  const mount = document.getElementById("pc-content");
  mount.innerHTML = "";
  const page = Pages[routeId];
  if (page) page(mount);
  else mount.innerHTML = "<div class='page-card'>页面开发中：" + routeId + "</div>";
}
```

- [ ] **Step 4: 验证**

Expected: 顶栏顺序为 首页 | **社会工作服务** | 应急管理指挥 | …；侧栏可点切换占位页；切换组织后 session 变

- [ ] **Step 5: Commit**

```bash
git add pc.html
git commit -m "feat(pc): system shell with top menu and sidebar routes"
```

---

### Task 5: PC 页面工厂 + 信息公开四模块

**Files:**
- Modify: `pc.html`

**Interfaces:**
- Produces:
  - `function mountCrudPage(container, config)`  
    config: `{ title, storeKey, columns, filters, formFields, statusActions, levelColumn: true }`
  - Pages: `notice-list`, `activity-list`, `affair-list`, `service-item-list`

- [ ] **Step 1: 实现 mountCrudPage**

行为：
1. 筛选区根据 `filters` 渲染，查询/重置  
2. 工具条：绿新增（省级只读页不传 create）  
3. 表格：`listForPc(storeKey)` + 本级可编辑按钮、下级仅查看  
4. 新增/编辑：`openDrawer` + 动态表单（两列 layout）  
5. 发布/下架/删除：改 status 或 soft delete + toast  
6. 活动页额外：报名名单抽屉（读 `activity_signups`）+ 导出 CSV（`Blob` 下载）

- [ ] **Step 2: 注册通知公告**

字段：`title, category, content, status, orgId, publishedAt`  
状态：draft/published/offline  

- [ ] **Step 3: 注册活动**

字段：`title, place, startAt, endAt, signupEnabled, scopeType, scopeOrgIds, content, status`  
报名名单列：姓名、手机脱敏、报名时间  

- [ ] **Step 4: 注册三务公开**

字段：`title, affairType(party|village|finance), content, status`  
筛选含类型  

- [ ] **Step 5: 注册服务项目**

字段：`name, target, content, conditions, provider, contact, status`  

- [ ] **Step 6: 浏览器验证**

Expected: 四菜单均可 CRUD；下级数据无编辑；发布后 localStorage 中 status 变化  

- [ ] **Step 7: Commit**

```bash
git add pc.html
git commit -m "feat(pc): information disclosure CRUD pages"
```

---

### Task 6: PC 人民建议 + 议事协商 + 服务资源

**Files:**
- Modify: `pc.html`

**Interfaces:**
- Pages:
  - `suggestion-inbox`, `collect-campaign`, `suggestion-handle`, `survey-manage`
  - `topic-list`, `topic-discuss`, `topic-vote`, `resident-list`
  - `facility-list`, `force-list`

- [ ] **Step 1: 建议线索归集页**

列表 `suggestion_inbox`；操作：受理/驳回/办结（确认框+原因）；「转为处置」写入 `suggestions` 一条 `submitted`。

- [ ] **Step 2: 征集活动管理**

CRUD `collect_campaigns`；状态 draft/open/closed。

- [ ] **Step 3: 线索建议受理**

列表 `suggestions`；流转 accepted/processing/done/rejected；写 `reply` 字段。

- [ ] **Step 4: 民主评议与满意度测评**

`surveys` 类型 review|satisfaction；题目用 JSON 文本数组；明细读 `survey_answers`；导出 CSV。

- [ ] **Step 5: 议事四页**

- 议题 CRUD：`topics` 状态 discussing/voting/closed  
- 讨论：按议题查看 `topic_comments`，管理员可回复  
- 表决结果：聚合 `topic_votes` 同意/反对/弃权计数 + 公示开关字段  
- 居民：`residents` CRUD  

- [ ] **Step 6: 设施与力量 CRUD**

`facilities` / `forces` 字段对齐 spec。

- [ ] **Step 7: 验证 + Commit**

```bash
git add pc.html
git commit -m "feat(pc): suggestions, deliberation, resource pages"
```

---

### Task 7: PC 帮扶全流程 + 统计 + 省级只读

**Files:**
- Modify: `pc.html`

**Interfaces:**
- Pages:
  - `vulnerable-warehouse`, `aid-policy`, `foundation`, `assist-record`
  - `assist-track`（核心）
  - `assist-stats`
  - `emerging-*`, `base-*` 共 7 个只读页

- [ ] **Step 1: 数据仓 / 政策 / 基金会 / 帮扶记录**

标准 CRUD 或只读+维护；政策/基金会可发布下架。

- [ ] **Step 2: 帮扶申请全流程跟踪页 `assist-track`**

列表列：标题、申请人、状态、当前办理单位、申报时间、操作  

**角色动作：**

```javascript
// session.role === 'center' || dept.role === 'center'
// submitted | returned:
//   - 不予受理 → status=rejected, rejectReason, progressText
//   - 受理并指派 → drawer: assignNote + deptId → status=assigned, assigneeDeptId, assigneeDeptName, acceptedAt, assignedAt

// session.role === 'department'
// assigned && record.assigneeDeptId === session.deptId:
//   - 审核通过 → status=completed, reviewNote, completedAt
//   - 退回 → status=returned, returnReason
```

进度说明字段 `progressText` 每次操作更新，供 H5 展示。

- [ ] **Step 3: 帮扶统计页**

卡片：申请总量、待受理、办理中、已办结、驳回率；简单 CSS 条形分布（按类型/状态）。

- [ ] **Step 4: 省级 7 页**

`mountReadOnlyPage`：筛选 + 表格 + 查看抽屉 + 页头「同步刷新」更新全部 `syncedAt` + toast。无新增。

- [ ] **Step 5: 侧栏所有 route 绑定完毕，无「开发中」死链**

- [ ] **Step 6: 重置演示数据入口**

用户下拉或侧栏底部按钮 → confirm → `resetDemoData()` → toast → 刷新当前页。

- [ ] **Step 7: 验证帮扶剧本（仅 PC 侧准备）+ Commit**

```bash
git add pc.html
git commit -m "feat(pc): assist workflow, stats, provincial read-only pages"
```

---

### Task 8: H5 Shell（手机框 + 三 Tab）

**Files:**
- Modify: `h5.html`

**Interfaces:**
- Produces: `renderH5Shell()`, `h5Navigate(path)`, `PagesH5`, 底栏 首页/服务/我的

- [ ] **Step 1: CSS 手机框居中**

```css
.phone {
  width: var(--phone-width);
  height: var(--phone-height);
  margin: 24px auto;
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: 2px;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}
.phone-body { flex: 1; overflow: auto; }
.tabbar {
  height: 50px;
  border-top: 1px solid var(--color-border);
  display: flex;
  background: #fff;
}
.tabbar-item { flex: 1; text-align: center; font-size: 11px; color: rgba(0,0,0,0.65); padding-top: 6px; }
.tabbar-item.active { color: var(--color-primary); }
```

图标用 `<i class="ri-home-line">` 等线性图标。

- [ ] **Step 2: 三 Tab 根路由**

- `home` / `service` / `mine` 显示 tabbar  
- 子路由如 `home/notices` 隐藏 tabbar，顶栏返回  

- [ ] **Step 3: 首页**

- 顶区：纯色主色条 + 村社名 + 问候 + 搜索框  
- 分组宫格：信息公开 / 社情民意 / 帮扶服务（线性图标，单色）  
- 资讯摘要：最新 notices/activities 2～3 条  

- [ ] **Step 4: 服务 Tab**

仅两个入口：设施资源、力量资源（或分段列表直接展示设施+力量检索）。

- [ ] **Step 5: 我的 Tab**

身份卡、切换居民（写 `h5Session`）、入口列表到各「我的记录」。

- [ ] **Step 6: 验证 + Commit**

```bash
git add h5.html
git commit -m "feat(h5): phone shell with home/service/mine tabs"
```

---

### Task 9: H5 业务页（全量入口可点）

**Files:**
- Modify: `h5.html`

**Interfaces:**
- PagesH5 for: notices, activities(+signup), affairs, serviceItems, campaigns(+submit suggestion), surveys(+answer), progress, topics(+comment+vote), facilities, forces, policies, foundations, assistApply, assistMine, my records

- [ ] **Step 1: 通用列表/详情/表单组件（H5）**

`h5ListPage`、`h5DetailPage`、`h5FormPage`：紧凑卡片、主按钮底栏固定。

- [ ] **Step 2: 信息公开四类只读浏览 + 活动报名**

报名写 `activity_signups`：`{ id, activityId, userId, userName, mobile, createdAt }`，防重复报名。

- [ ] **Step 3: 建议征集提交 + 办理进度列表**

写 `suggestions`：`status: 'submitted', userId, campaignId, content, createdAt`。

- [ ] **Step 4: 评议/测评答题**

写 `survey_answers`；已答提示。

- [ ] **Step 5: 议事讨论与表决**

评论写 `topic_comments`；表决写 `topic_votes` 一人一票。

- [ ] **Step 6: 服务 Tab 设施/力量检索详情**

- [ ] **Step 7: 帮扶政策/基金会浏览 + 提交申请**

```javascript
// assist application create
{
  id: uid("apl"),
  title, type, content, userId, userName,
  orgId: session.orgId, // 群众所属村社
  status: "submitted",
  handleOrgName: "城西街道综合信息指挥室",
  progressText: "已提交，待乡镇中心受理",
  createdAt: nowISO()
}
```

注意：业务上「推送至乡镇中心」——列表在 PC 端由城西中心账号 `listForPc` 可见（seed 中村社 path 含 org_cx；PC 中心 orgId=org_cx 向下可见）。

- [ ] **Step 8: 帮扶进度卡片组件（无电话）**

```javascript
function renderAssistProgressCard(app) {
  // 四步：提交、受理、指派、审核
  // 根据 status 点亮/标红
  // 字段：title, steps, handleOrgName, progressText, createdAt
  // 禁止渲染咨询电话
}
```

映射：
- submitted → 步1完，步2当前「受理中」
- rejected → 步2红「不予受理」
- assigned → 步1-3完，步4「审核中」
- returned → 示警退回
- completed → 四步全完「完成」

- [ ] **Step 9: 验证每个宫格可达 + Commit**

```bash
git add h5.html
git commit -m "feat(h5): full citizen service pages and assist progress"
```

---

### Task 10: 跨端闭环走查与打磨

**Files:**
- Modify: `pc.html`（若有 bug）
- Modify: `h5.html`（若有 bug）

**Interfaces:**
- Consumes: 全部既有 API
- Produces: 稳定演示剧本

- [ ] **Step 1: 剧本 A 活动**

1. PC 发布活动  
2. H5 报名  
3. PC 打开报名名单可见该居民  

- [ ] **Step 2: 剧本 B 建议**

1. PC 征集 open  
2. H5 提交  
3. PC 受理并回复  
4. H5 办理进度显示回复  

- [ ] **Step 3: 剧本 C 帮扶**

1. H5 提交申请  
2. PC 中心账号：不予受理 → H5 红步+原因；再重置或用第二条  
3. 受理并指派民政办  
4. PC 切换部门账号：退回 → 中心再指派 → 审核通过  
5. H5 卡片四步完成，**无咨询电话**  

- [ ] **Step 4: 剧本 D 议事**

PC 议题 voting → H5 评论+投票 → PC 计票变化  

- [ ] **Step 5: 剧本 E 权限**

PC 切到幸福社区：仅本级可编辑；市级数据只读  

- [ ] **Step 6: 剧本 F 服务资源**

PC 改设施开放时间 → H5 服务 Tab 详情同步  

- [ ] **Step 7: UI 验收清单**

- [ ] 无 emoji、无彩色填色大图标  
- [ ] 圆角 ≤4px  
- [ ] PC 右抽屉非居中大弹窗  
- [ ] 顶栏菜单顺序正确  
- [ ] H5 底栏三项职责正确  

- [ ] **Step 8: Commit**

```bash
git add pc.html h5.html
git commit -m "fix: end-to-end demo scripts and UI polish"
```

---

## Plan Self-Review

### Spec coverage

| Spec 区域 | 任务 |
|-----------|------|
| 交付双 HTML + 存储前缀 | Task 0–1 |
| DataAPI/四级权限/可见性 | Task 2 |
| PC 列表+右抽屉 UI | Task 3 |
| 顶栏插入社会工作服务+侧栏 | Task 4 |
| 信息公开/建议/议事/资源 | Task 5–6 |
| 帮扶流程+统计+省级只读 | Task 7 |
| H5 三 Tab 与入口划分 | Task 8 |
| H5 全量业务+进度卡 | Task 9 |
| 闭环剧本 | Task 10 |
| UI 硬约束 | Task 0/3/8/10 |

### Placeholder scan

无 TBD/TODO；种子「写全」在 Task 1 已强制；页面字段在各任务列出。

### Type consistency

- 状态名统一英文小写：`published`/`submitted`/`assigned`/`completed`/`rejected`/`returned`  
- Key 常量统一 `KEYS.*`  
- 会话字段：`orgId`, `role`, `deptId`, `userId`  

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-07-24-social-work-service-demo.md`.

**两种执行方式：**

1. **Subagent-Driven（推荐）** — 每任务新开子代理，任务间审查，迭代快  
2. **Inline Execution** — 本会话按 executing-plans 连续执行并设检查点  

你更想用哪一种？回复 **1** 或 **2** 即可开始实现。
