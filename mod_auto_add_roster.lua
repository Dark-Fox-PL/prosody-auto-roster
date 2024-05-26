local st = require "util.stanza";
local jid = require "util.jid";
local storagemanager = require "core.storagemanager";

module:hook("message/bare", function(event)
    local origin, stanza = event.origin, event.stanza;
    local sender_jid = stanza.attr.from;
    local recipient_jid = stanza.attr.to;

    if stanza.attr.type == "chat" then
        local recipient_user = jid.split(recipient_jid);
        local recipient_host = jid.host(recipient_jid);
        local sender_user = jid.split(sender_jid);

        local roster = storagemanager.open(recipient_host, "roster");
        local recipient_roster = roster:get(recipient_user) or {};

        if not recipient_roster[sender_user] then
            recipient_roster[sender_user] = {
                subscription = "both",
                name = sender_user,
                groups = { "Contacts" }
            };
            roster:set(recipient_user, recipient_roster);

            origin.send(st.presence({ to = sender_jid, from = recipient_jid, type = "subscribed" }));
            origin.send(st.presence({ to = sender_jid, from = recipient_jid, type = "subscribe" }));
        end
    end
end);
