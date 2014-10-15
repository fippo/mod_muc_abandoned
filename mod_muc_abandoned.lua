-- transfers ownership of a muc when the owner leaves
-- LICENSE: MIT
local serialization = require "util.serialization"

module:hook("muc-occupant-left", function (event)
        local room, nick, occupant = event.room, event.nick, event.occupant
	if room:get_affiliation(occupant.bare_jid) == "owner" and room:get_persistent() == nil then
		if room:has_occupant() then
			local next_occupant = room:get_occupant_by_nick(next(room._occupants))
			local ok, err = room:set_affiliation(occupant.bare_jid, next_occupant.bare_jid, "owner")
		end
	end
end, 2);
log("info", "mod_muc_abandoned loaded");
