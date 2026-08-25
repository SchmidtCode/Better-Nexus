"use strict";

const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");
const fengari = require("fengari");

const ACCEPTED_BASE = "e70de8a7582d0146cc6746677084b3f4a270290b";
const repoRoot = path.resolve(process.cwd());

function git(...args) {
    return execFileSync("git", ["-c", `safe.directory=${repoRoot}`, ...args], {
        cwd: repoRoot,
        encoding: "utf8",
        maxBuffer: 32 * 1024 * 1024,
        stdio: ["ignore", "pipe", "pipe"],
    }).trimEnd();
}

const resolvedBase = git("rev-parse", `${ACCEPTED_BASE}^{commit}`).trim();
if (resolvedBase !== ACCEPTED_BASE) {
    throw new Error(`accepted prerequisite mismatch: ${resolvedBase}`);
}

const baseToc = git("show", `${ACCEPTED_BASE}:Nexus.toc`);
const productPaths = baseToc.split(/\r?\n/)
    .map((line) => line.trim().replace(/\\/g, "/"))
    .filter((line) => line && !line.startsWith("#") && line.endsWith(".lua"));

function productHashes() {
    const out = {};
    for (const relative of ["Nexus.toc", ...productPaths]) {
        const content = fs.readFileSync(path.join(repoRoot, relative));
        out[relative] = crypto.createHash("sha256").update(content).digest("hex");
    }
    return out;
}

const beforeHashes = productHashes();
const overlays = {};
for (const relative of productPaths) {
    overlays[relative] = git("show", `${ACCEPTED_BASE}:${relative}`) + "\n";
}

const { lua, lauxlib, lualib, to_jsstring, to_luastring } = fengari;
const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);

function fileRead(state) {
    lua.lua_getfield(state, 1, to_luastring("_content"));
    return 1;
}

function fileClose(state) {
    lua.lua_pushboolean(state, true);
    return 1;
}

function currentFileOpen(state) {
    const raw = lauxlib.luaL_checkstring(state, 1);
    const filePath = path.resolve(repoRoot, to_jsstring(raw));
    try {
        const content = fs.readFileSync(filePath, "utf8");
        lua.lua_createtable(state, 0, 3);
        lua.lua_pushstring(state, to_luastring(content));
        lua.lua_setfield(state, -2, to_luastring("_content"));
        lua.lua_pushcfunction(state, fileRead);
        lua.lua_setfield(state, -2, to_luastring("read"));
        lua.lua_pushcfunction(state, fileClose);
        lua.lua_setfield(state, -2, to_luastring("close"));
        return 1;
    } catch (error) {
        lua.lua_pushnil(state);
        lua.lua_pushstring(state, to_luastring(String(error.message || error)));
        return 2;
    }
}

lua.lua_getglobal(L, to_luastring("io"));
lua.lua_pushcfunction(L, currentFileOpen);
lua.lua_setfield(L, -2, to_luastring("open"));
lua.lua_pop(L, 1);

lua.lua_createtable(L, 0, productPaths.length);
for (const [relative, source] of Object.entries(overlays)) {
    lua.lua_pushstring(L, to_luastring(source));
    lua.lua_setfield(L, -2, to_luastring(relative));
}
lua.lua_setglobal(L, to_luastring("NEXUS_ACCEPTED_BASE_SOURCES"));

const output = [];
function capturePrint(state) {
    const count = lua.lua_gettop(state);
    const parts = [];
    for (let index = 1; index <= count; index += 1) {
        lua.lua_getglobal(state, to_luastring("tostring"));
        lua.lua_pushvalue(state, index);
        if (lua.lua_pcall(state, 1, 1, 0) !== lua.LUA_OK) {
            return lua.lua_error(state);
        }
        parts.push(to_jsstring(lua.lua_tostring(state, -1)));
        lua.lua_pop(state, 1);
    }
    const line = parts.join("\t");
    output.push(line);
    console.log(line);
    return 0;
}
lua.lua_pushcfunction(L, capturePrint);
lua.lua_setglobal(L, to_luastring("print"));

const prelude = [
    "unpack = unpack or table.unpack",
    "math.atan2 = math.atan2 or math.atan",
    "package.preload.bit = function() return {} end",
    "local originalDofile = dofile",
    "local originalOpen = io.open",
    "local function normalized(filePath)",
    "  return type(filePath) == 'string' and filePath:gsub('\\\\', '/') or filePath",
    "end",
    "function dofile(filePath)",
    "  local name = normalized(filePath)",
    "  local source = NEXUS_ACCEPTED_BASE_SOURCES and NEXUS_ACCEPTED_BASE_SOURCES[name]",
    "  if source then",
    "    local chunk, why = load(source, '@' .. name)",
    "    if not chunk then error(why, 0) end",
    "    return chunk()",
    "  end",
    "  return originalDofile(filePath)",
    "end",
    "function io.open(filePath, mode)",
    "  local name = normalized(filePath)",
    "  local source = NEXUS_ACCEPTED_BASE_SOURCES and NEXUS_ACCEPTED_BASE_SOURCES[name]",
    "  if source then",
    "    return { read=function() return source end, close=function() return true end }",
    "  end",
    "  return originalOpen(filePath, mode)",
    "end",
].join("; ");

let status = lauxlib.luaL_loadstring(L, to_luastring(prelude));
if (status === lua.LUA_OK) status = lua.lua_pcall(L, 0, 0, 0);
if (status !== lua.LUA_OK) {
    throw new Error(to_jsstring(lua.lua_tostring(L, -1)));
}

function expectedFailure(label, source) {
    lua.lua_settop(L, 0);
    let scenarioStatus = lauxlib.luaL_loadstring(L, to_luastring(source));
    if (scenarioStatus === lua.LUA_OK) {
        scenarioStatus = lua.lua_pcall(L, 0, 0, 0);
    }
    if (scenarioStatus === lua.LUA_OK) {
        throw new Error(`expected-red scenario unexpectedly passed: ${label}`);
    }
    const oracle = to_jsstring(lua.lua_tostring(L, -1));
    if (!oracle.includes(label)) {
        throw new Error(`missing expected-red oracle: ${label}; actual=${oracle}`);
    }
    console.log(`EXPECTED-RED confirmed=${label}`);
    console.log(`EXPECTED-RED oracle=${oracle}`);
}

const repairSource = fs.readFileSync(
    path.join(repoRoot, "tests/run_pr58_authority_pair_repair.lua"), "utf8");
const pairSection = repairSource.indexOf(
    "------------------------------------------------------------------------\n-- Strongest single valid DPS");
const copySection = repairSource.indexOf("local historicalBuild = {");
if (pairSection < 0 || copySection < 0) {
    throw new Error("unable to isolate historical Copy expected-red fixture");
}
const historicalCopyOracle = repairSource.slice(0, pairSection)
    + "local Evidence = assert(Nexus.CandidateEvidence)\n"
    + repairSource.slice(copySection);
expectedFailure(
    "historical auto-DPS locked row still authorizes Copy",
    historicalCopyOracle);

expectedFailure("synchronous and cursor summaries disagree under crossed category maxima", [
    "local function row(category,dps,owner,spell) return {category=category,dps=dps,player=owner,author=owner,ownerKey=owner:lower()..'@ebonhold',ownerVerified=true,realm='ebonhold',class='MAGE',fingerprint=tostring(spell)..'x1',echoes={{spellId=spell,quality=2,stacks=1}},lockedEchoes={},buildId='pair-'..owner,duration=60,level=80,ts=1} end",
    "local sd,sl=row('dummy',1000,'Strongest',982001),row('lk',100,'Strongest',982001)",
    "local bd,bl=row('dummy',700,'Balanced',982002),row('lk',700,'Balanced',982002)",
    "Nexus.DpsCapture={GetDpsBoard=function(c) return c=='dummy' and {bd,sd} or {bl,sl} end}",
    "Nexus.ViewProjections.Reset()",
    "local sync=Nexus.ViewProjections.Leaderboard('combined',{classFilter='ALL',search=''})",
    "assert(sync[1] and sync[1].player=='Strongest' and sync[1].dps==1000, 'synchronous and cursor summaries disagree under crossed category maxima: synchronous projection ranks the independently averaged maxima')",
].join("; "));

expectedFailure("Average affects ranking or UI authority", [
    "local function row(category,dps,owner,spell) return {category=category,dps=dps,player=owner,author=owner,ownerKey=owner:lower()..'@ebonhold',ownerVerified=true,realm='ebonhold',class='MAGE',fingerprint=tostring(spell)..'x1',echoes={{spellId=spell,quality=2,stacks=1}},lockedEchoes={},buildId='rank-'..owner,duration=60,level=80,ts=1} end",
    "local sd,sl=row('dummy',1000,'Strongest',983001),row('lk',100,'Strongest',983001)",
    "local bd,bl=row('dummy',700,'Balanced',983002),row('lk',700,'Balanced',983002)",
    "Nexus.DpsCapture={GetDpsBoard=function(c) return c=='dummy' and {bd,sd} or {bl,sl} end}",
    "Nexus.ViewProjections.Reset()",
    "local ranked=Nexus.ViewProjections.Leaderboard('combined',{classFilter='ALL',search=''})",
    "assert(ranked[1] and ranked[1].player=='Strongest' and ranked[1].dps==1000, 'Average affects ranking or UI authority: balanced Average still outranks strongest single DPS')",
].join("; "));

expectedFailure("historical duplicate order loses the strongest compatible pair", [
    "local function row(category,dps,source) return {category=category,dps=dps,player='Budget',author='Budget',ownerKey='budget@ebonhold',ownerVerified=true,realm='ebonhold',class='MAGE',fingerprint='984001x1',echoes={{spellId=984001,quality=2,stacks=1}},lockedEchoes={},buildId='budget-pair',sourceIdentity=source,duration=60,level=80,ts=1} end",
    "local dummy={row('dummy',1096,'strong-dummy'),row('dummy',1001,'late-dummy')}; local lk={row('lk',2096,'strong-lk'),row('lk',2001,'late-lk')}",
    "Nexus.DpsCapture={GetDpsBoard=function(c) return c=='dummy' and dummy or lk end}",
    "Nexus.ViewProjections.Reset()",
    "local rows=Nexus.ViewProjections.Leaderboard('combined',{classFilter='ALL',search=''})",
    "assert(#rows==1 and rows[1].dummyDps==1096 and rows[1].lkDps==2096, 'historical duplicate order loses the strongest compatible pair: selected '..tostring(rows[1] and rows[1].dummyDps)..'/'..tostring(rows[1] and rows[1].lkDps))",
].join("; "));

const afterHashes = productHashes();
if (JSON.stringify(afterHashes) !== JSON.stringify(beforeHashes)) {
    throw new Error("expected-red execution changed product bytes");
}

console.log(`EXPECTED-RED prerequisite=${ACCEPTED_BASE}`);
console.log("EXPECTED-RED product_bytes_unchanged=true");
console.log("PR58 exact-publication-parent expected red -- OK");
