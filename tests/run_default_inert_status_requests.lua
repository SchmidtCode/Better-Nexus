-- Package A #27: public clients never answer unsolicited remote status
-- requests. Local explicit diagnostic export remains available.
local H = dofile("tests/harness.lua")
dofile("core/Codec.lua")
dofile("core/SyncSession.lua")

local sent = {}
local session = Nexus.SyncInternals.Session.New({
    now=function() return H.now end,
    myName=function() return "Local" end,
    normalizePeerName=function(value)
        return type(value) == "string" and value:lower() or ""
    end,
    maxKnownPeers=16,
    getAdapter=function()
        return {
            Slots=function() return {maxSlots=5,activeSlot=3} end,
            Wishlist=function() return {name="Private Wishlist"} end,
        }
    end,
    getDpsCapture=function()
        return {GetPlayerInfo=function()
            return {dps=123456,category="lk"}
        end}
    end,
    playerLevel=function() return 80 end,
    getCatalog=function() return {Count=function() return 17 end} end,
    statusVersion=function() return "1.20.0-beta.1" end,
    getCodec=function() return Nexus.Codec end,
    chatLimit=255,
    sendWhisper=function(message, target)
        sent[#sent + 1] = {message=message,target=target}
        return true
    end,
})

session.MarkPeer("KnownPeer", "1.20.0")
for _, request in ipairs({
    {"Unknown", "token"},
    {"KnownPeer", "token"},
    {"Unknown", ""},
    {"Unknown", nil},
}) do
    assert(session.HandleStatusRequest(request[1], request[2]) == false,
        "unsolicited correctly shaped developer-status request schedules a response")
end
for index = 1, 100 do
    assert(session.HandleStatusRequest("Spam", "token" .. index) == false,
        "status-request spam acquired pending reply state")
end
assert(session.FlushStatusReply() == false and #sent == 0,
    "remote status request disclosed local state or amplified traffic")
session.Reset()
assert(session.FlushStatusReply() == false and #sent == 0,
    "status reply survived reset, expiry, or replay boundary")

assert(session.SendStatusTo("") == false
    and session.SendStatusTo("ManualTarget") == true
    and #sent == 1 and sent[1].target == "ManualTarget"
    and sent[1].message:find("^WLRQ|Local|dev|"),
    "explicit local diagnostic export was removed")

local function Read(path)
    local file = assert(io.open(path, "rb"))
    local source = file:read("*a")
    file:close()
    return source
end
local lifecycle = Read("core/MainLifecycle.lua")
assert(not lifecycle:find("HandleStatusRequest", 1, true),
    "whisper lifecycle still routes hidden remote status requests")

print("default-inert diagnostic response matrix -- OK")
