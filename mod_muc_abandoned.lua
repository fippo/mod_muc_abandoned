-- transfers ownership of a muc when the owner leaves
-- LICENSE: MIT
local serialization = require "util.serialization"

-- < daurnimator> fippo, ps; when you have something like that `occupants` table. use module:shared.
local occupants = {}

module:hook("muc-occupant-joined", function (event)
        local room, nick, occupant = event.room, event.nick, event.occupant
	if not occupants[room.jid] then occupants[room.jid] = {}; end
	occupants[room.jid][#occupants[room.jid]+1] = event.nick
end, 2)

module:hook("muc-occupant-left", function (event)
        local room, nick, occupant = event.room, event.nick, event.occupant
	if occupants[room.jid] then
		for _, v in ipairs(occupants[room.jid]) do
			if v == event.nick then
				table.remove(occupants[room.jid], _)
				if table.getn(occupants[room.jid]) == 0 then occupants[room.jid] = nil; end
				break
			end
		end
	end
	if room:get_affiliation(occupant.bare_jid) == "owner" and room:get_persistent() == nil then
		if room:has_occupant() then
			local has_owner = 0
			for owner in room:each_affiliation("owner") do
				has_owner = has_owner + 1
                break
			end
			if has_owner == 1 then
				-- pick the oldest occupant
				local next_occupant = room:get_occupant_by_nick(occupants[room.jid][1])
				-- FIXME: occupant.bare_jid should no longer be necessary soon, bug is fixed in trunk,
				-- just pass true
				local ok, err, reason = room:set_affiliation(occupant.bare_jid, next_occupant.bare_jid, "owner")
				--module:log("debug", "%s %s %s", tostring(ok), tostring(err), tostring(reason));
				-- FIXME: would be good to pass nil here so the occupant is removed
				-- FIXME: occupant.bare_jid should no longer be necessary soon, bug is fixed in trunk,
				-- just pass true
				ok, err, reason = room:set_affiliation(occupant.bare_jid, occupant.bare_jid, "none")
				--module:log("debug", "%s %s %s", tostring(ok), tostring(err), tostring(reason));
			end
			--module:log("debug", "room %s", serialization.serialize(room))
		end
	end
end, 2);
log("info", "mod_muc_abandoned loaded");
