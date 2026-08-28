-- Package A #31: peer versions are bounded diagnostics, never release proof.
local H = dofile("tests/harness.lua")

local Updates = Nexus.Updates
Nexus.Release.availableVersion = nil
Nexus.Release.availableReleaseVersion = nil
NexusDB = {
    settings={updateNotifications=true},
    updateNotice={
        version="999.0.0",source="UntrustedPeer",observedAt=7,
        future={keep=true},
    },
    futureRoot={keep=true},
}
local notices, refreshes = {}, 0
local function Init()
    Updates.Init({
        notify=function(version, url)
            notices[#notices + 1] = {version=version,url=url}
        end,
        refresh=function() refreshes = refreshes + 1 end,
    })
end

Nexus.Release.availableReleaseVersion = "999.0.0"
Init()
assert(Updates.GetCandidate() == nil and #notices == 0,
    "undocumented release alias became bundled release authority")
Nexus.Release.availableReleaseVersion = nil

Init()
assert(NexusDB.updateNotice == nil and Updates.GetCandidate() == nil
    and type(NexusDB.updateNoticeQuarantine) == "table"
    and NexusDB.updateNoticeQuarantine.version == "999.0.0"
    and NexusDB.updateNoticeQuarantine.future.keep == true
    and NexusDB.futureRoot.keep == true and #notices == 0,
    "untrusted peer 999.0.0 retains authoritative persisted update state")
local quarantined = NexusDB.updateNoticeQuarantine
Init()
assert(NexusDB.updateNotice == nil
    and NexusDB.updateNoticeQuarantine == quarantined and #notices == 0,
    "persisted peer notice neutralization was not idempotent")

local versions = {
    "1.19.5", "1.18.0", "9.0.0-rc.1", "9.0.0+local", "999.0.0",
}
for index, version in ipairs(versions) do
    assert(Updates.Observe(version, "Peer" .. index),
        "valid peer version observation was discarded")
end
local observations = Updates.PeerObservations()
assert(#observations == #versions and Updates.GetCandidate() == nil
    and NexusDB.updateNotice == nil and #notices == 0,
    "peer version observations manufactured release authority")
observations[1].version = "mutated"
assert(Updates.PeerObservations()[1].version == versions[1],
    "peer observation query exposed mutable diagnostic state")
for index = 1, 40 do
    assert(Updates.Observe(tostring(1000 + index) .. ".0.0", "Many" .. index))
end
assert(#Updates.PeerObservations() == 32 and Updates.GetCandidate() == nil,
    "multiple peers grew observation state or aggregated authority")

Nexus.Release.availableVersion = "2.0.0"
Init()
local candidate = Updates.GetCandidate()
assert(candidate and candidate.version == "2.0.0"
    and candidate.source == "bundled-release"
    and candidate.authority == "bundled-release"
    and Updates.GetVisibleNotice().version == "2.0.0" and #notices == 1,
    "independent bundled release authority stopped working")
candidate.version = "mutated"
assert(Updates.GetCandidate().version == "2.0.0",
    "authoritative candidate query exposed mutable state")
assert(#Updates.PeerObservations() == 0,
    "peer observations persisted across reload")

local function Read(path)
    local file = assert(io.open(path, "rb"))
    local source = file:read("*a")
    file:close()
    return source
end
local source = Read("core/Updates.lua")
assert(not source:find("Download", 1, true)
    and not source:find("Install", 1, true),
    "peer-version repair added a download or install path")

print("peer-version observation and release-authority matrix -- OK")
