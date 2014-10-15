-- transfers ownership of a muc when the owner leaves
-- LICENSE: MIT
local serialization = require "util.serialization"

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
		-- FIXME: only if this was the only owner
		if room:has_occupant() then
			-- pick the oldest occupant
			local next_occupant = room:get_occupant_by_nick(occupants[room.jid][1])
			-- FIXME: occupant.bare_jid should no longer be necessary soon, bug is fixed in trunk,
			-- just pass true
			local ok, err = room:set_affiliation(occupant.bare_jid, next_occupant.bare_jid, "owner")
			-- FIXME: remove old owner
		end
	end
end, 2);
log("info", "mod_muc_abandoned loaded");
