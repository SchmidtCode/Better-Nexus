-- Package A #24: remote wire/storage text stays lossless while ordinary rich
-- presentation receives one deterministic display-only projection.
local H = dofile("tests/harness.lua")

local Identity = Nexus.Identity
local plain = "Caf\195\169 \226\152\131"
local multiline = "first line\nsecond line"
local hostile = {
    "|cffff0000remote|r",
    "|Hitem:1|hspoof|h",
    "|TInterface\\Icons\\INV_Misc_QuestionMark:16|t",
    "before |cffff0000unclosed adjacent",
    "trailing |",
}

assert(type(Identity.DisplaySafeText) == "function",
    "formatting-shaped wire-safe remote text reaches an ordinary presentation seam")
assert(Identity.DisplaySafeText(plain, 120, false) == plain,
    "plain UTF-8 changed at the display boundary")
assert(Identity.DisplaySafeText(multiline, 4000, false, true) == multiline,
    "allowed multiline text changed at the display boundary")
for _, raw in ipairs(hostile) do
    local displayed = Identity.DisplaySafeText(raw, 120, false)
    assert(displayed == raw:gsub("|", "||"),
        "pipe-shaped rich-text syntax did not become inert")
end
assert(Identity.DisplaySafeText("", 120, true) == ""
    and Identity.DisplaySafeText("", 120, false) == nil,
    "empty display text did not follow field ownership")
local maximum = string.rep("|", 120)
assert(#Identity.DisplaySafeText(maximum, 120, false) == 240
    and Identity.DisplaySafeText(maximum .. "x", 120, false) == nil,
    "maximum-length display projection was not bounded")

local rawTitle = hostile[1] .. " " .. hostile[2]
local rawDescription = multiline .. "\n" .. hostile[3] .. " " .. hostile[4]
local build = {
    id="display-probe",title=rawTitle,description=rawDescription,
    author="Peer-Ebonhold",ownerKey="peer@ebonhold",realm="ebonhold",
    ownerVerified=true,class="MAGE",lastModified=1,ordinaryComplete=true,
    fingerprint="700001x1",
    echoes={{spellId=700001,quality=3,stacks=1}},
    future={keep=true},
}
local presented = assert(Identity.PresentPublicRecords({build}, "author"))[1]
assert(presented.title == rawTitle and presented.description == rawDescription
    and build.title == rawTitle and build.description == rawDescription,
    "raw presentation evidence was rewritten")
assert(presented.displayTitle == rawTitle:gsub("|", "||")
    and presented.displayDescription == rawDescription:gsub("|", "||"),
    "public presentation omitted deterministic display projections")

local originalCompleteness = Nexus.LoadoutEvidence.OrdinaryCompleteness
local originalPublicCompleteness = Nexus.LoadoutEvidence.PublicOrdinaryCompleteness
Nexus.LoadoutEvidence.OrdinaryCompleteness = function()
    return {complete=true,echoCount=1}
end
Nexus.LoadoutEvidence.PublicOrdinaryCompleteness =
    Nexus.LoadoutEvidence.OrdinaryCompleteness
local projection = Nexus.CommunityInternals.Projection.New({
    builds=function() return {build}, {filtered=1} end,
    buildsCurrent=function() return false end,
    loadBuild=function(id) return id == build.id and build or nil end,
    revisionSnapshot=function() return {build=1,dps=1} end,
    leaderboard=function(_, category)
        if category == "dummy" then
            return {{player=hostile[1],dps=1234}}
        end
        return {}
    end,
})
local detail = assert(projection.Detail(build.id, {
    ownerKey="local@ebonhold",ownedBySpell={},detailsAvailable=false,
}))
assert(detail.build.title == rawTitle
    and detail.build.description == rawDescription
    and detail.build.displayTitle == rawTitle:gsub("|", "||")
    and detail.build.displayDescription == rawDescription:gsub("|", "||")
    and detail.dummyRecord:find(hostile[1]:gsub("|", "||"), 1, true)
    and build.future.keep == true,
    "legacy Community detail or record label bypassed display ownership")
Nexus.LoadoutEvidence.OrdinaryCompleteness = originalCompleteness
Nexus.LoadoutEvidence.PublicOrdinaryCompleteness = originalPublicCompleteness

local function Read(path)
    local file = assert(io.open(path, "rb"))
    local source = file:read("*a")
    file:close()
    return source
end
local renderer = Read("ui/CommunityRenderer.lua")
local leaderboard = Read("ui/Leaderboard.lua")
local panel = Read("ui/Panel.lua")
local nameplate = Read("ui/Nameplate.lua")
local logViewer = Read("ui/LogViewer.lua")
local wishlistRenderer = Read("ui/WishlistRenderer.lua")
local main = Read("core/Main.lua")
assert(renderer:find("DisplaySafeText", 1, true)
    and renderer:find("displayTitle", 1, true)
    and renderer:find("displayDescription", 1, true)
    and not renderer:find(
        'detailPanel.title:SetText(build.title or "")', 1, true),
    "Community rich-text sinks do not consume the display projection")
assert(leaderboard:find("DisplaySafeText", 1, true)
    and not leaderboard:find(
        'detail.title:SetText(b.title or "Record Loadout")', 1, true),
    "Leaderboard rich-text sinks do not consume the display projection")
assert(panel:find("DisplaySafeText", 1, true)
    and not panel:find("GameTooltip:AddLine(info.title", 1, true)
    and nameplate:find("DisplaySafeText", 1, true)
    and not nameplate:find("info.title:sub", 1, true),
    "Panel or nameplate tooltip bypassed the display projection")
assert(logViewer:find("InertCopyText", 1, true)
    and logViewer:find("reversible inert export", 1, true)
    and logViewer:find("DisplaySafeText", 1, true)
    and wishlistRenderer:find("M.SetNameText", 1, true)
    and wishlistRenderer:find("DisplaySafeText", 1, true)
    and main:find("DisplaySafeText", 1, true),
    "ordinary diagnostics or editor copy labels bypassed display safety")
assert(renderer:find(
        'detailPanel.linkBox:_NexusSetRawText(build.link or "")', 1, true)
    and renderer:find("linkBox:_NexusRawText()", 1, true)
    and not renderer:find("self:SetText(state.raw)", 1, true)
    and not renderer:find("_NexusBeginExplicitRawEdit", 1, true),
    "build-link field exposes raw rich text or loses its reversible boundary")

print("remote display projection matrix -- OK")
