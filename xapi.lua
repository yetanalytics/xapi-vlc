
function descriptor()
    return {
        title = "xAPI Integration",
        capabilities = {"input-listener", "playing-listener"}
    }
end

local api_key = ""
local api_secret = ""
local api_url = ""
local api_userid = ""
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function activate()
  show_api_settings_dialog()

  if socket and http then
    vlc.msg.info("LuaSocket and socket.http are available!")
  else
    vlc.msg.err("LuaSocket is not available in this environment.")
  end
end

function deactivate()
end

function input_changed()
    vlc.msg.info("[Now Playing] input_changed")
end

-- *************** Hook ************

function playing_changed()
  vlc.msg.info("[Now Playing] playing_changed")

  -- Status
  local status = vlc.playlist.status()
  vlc.msg.info("Status: " .. status)
  
  -- Metadata
  local input = vlc.object.input()
  if not input then
    vlc.msg.warn("No input available.")
    return
  end
  send_metadata(input, status)
end

-- Function to retrieve metadata and send it off
function send_metadata(input, status)
  if not input then
    vlc.msg.warn("No input to fetch metadata.")
    return
  end

  -- Get media item (the current playing media)
  local item = vlc.input.item()
  if not item then
    vlc.msg.warn("No media item available.")
    return
  end

  -- Fetch metadata
  local title = item:name() or "Unknown Title"
  local duration = item:duration() or "Unknown Duration"
  local current_time = vlc.var.get(input, "time") or "Unknown Time"
  local position = vlc.var.get(input, "position") or "Unknown Position"

  -- Log metadata
  vlc.msg.info("Title: " .. title)
  vlc.msg.info("Duration: " .. (duration ~= -1 and (duration .. " seconds") or "Live Stream"))
  vlc.msg.info("Current Time: " .. (current_time / 1000000) .. " seconds")
  vlc.msg.info("Current Position: " .. (position * 100) .. "%")
  local statement = form_statement({title = title, status = status})
  vlc.msg.info(statement)
  post_request(statement)
end

-- *************** Interface ************

-- Function to create the API settings dialog
function show_api_settings_dialog()
    -- Create a dialog window
    dlg = vlc.dialog("xAPI  Integration Settings")

    dlg:add_label("User ID (email):", 1, 1)
    api_userid_input = dlg:add_text_input(api_userid, 1, 2)

    dlg:add_label("API Key:", 1, 3)
    api_key_input = dlg:add_text_input(api_key, 1, 4)

    dlg:add_label("API Secret:", 1, 5)
    api_secret_input = dlg:add_password(api_secret, 1, 6)

    dlg:add_label("API URL:", 1, 7)
    api_url_input = dlg:add_text_input(api_url, 1, 8)

    -- Add a Save button
    dlg:add_button("Save", save_api_settings, 1, 9)

    -- Add a Cancel button to close the dialog
    dlg:add_button("Cancel", close_dialog, 1, 10)
end

-- Function to save the API settings
function save_api_settings()
    api_key = api_key_input:get_text()
    api_secret = api_secret_input:get_text()
    api_url = api_url_input:get_text()
    api_userid = api_userid_input:get_text()

    -- Close the dialog after saving
    close_dialog()
end

-- Function to close the dialog
function close_dialog()
    if dlg then
        dlg:delete()
    end
end

-- *************** xAPI Statement ************

function form_statement(args)
  local title = args.title
  local status = args.status
  local base_url = "https://yet.systems/xapi/profiles/vlc"
  local verb = base_url .. "/verbs/" .. status
  local activity_url = base_url .. "/activity"
  local video_url = activity_url .. "/video"
  local object = video_url .. "/" .. title

    -- Manually construct the JSON string with results
  local json_statement = 
    '{' ..
      '"actor": {' ..
        '"mbox": "mailto:' .. api_userid .. '",' ..
        '"objectType": "Agent"' ..
      '},' ..
      '"verb": {' ..
        '"id": "' .. verb .. '"' ..
      '},' ..
      '"object": {' ..
        '"id": "' .. object .. '",' ..
        '"objectType": "Activity"' ..
      '}' ..
    '}'
  return json_statement
end

-- *************** Rest Client ************

-- shamelessly ripped from: http://lua-users.org/wiki/BaseSixtyFour 
function base64_encode(data)
  return ((data:gsub('.', function(x) 
    local r,b='',x:byte()
    for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
    return r;
  end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if (#x < 6) then return '' end
    local c=0
    for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
    return b:sub(c+1,c+1)
  end)..({ '', '==', '=' })[#data%3+1])
end

function post_request(json_body)
  -- Encode API key and secret as Base64 for Basic Auth
  local auth = "Basic " .. base64_encode(api_key .. ":" .. api_secret)
    -- Construct the curl command to make the HTTP POST request
  local command = 'curl -X POST ' .. api_url .. ' '
      .. '-H "Content-Type: application/json" '
      .. '-H "Authorization: ' .. auth .. '" '
      .. '-H "X-Experience-API-Version: 1.0.3" '
      .. '-d \'' .. json_body .. '\''

  vlc.msg.info("command: " .. command)

  -- Use io.popen to execute the curl command and capture the output
  local handle = io.popen(command)
  local result = handle:read("*a")  -- Read the full response
  handle:close()

  -- Log the result
  vlc.msg.info("Curl response: " .. result)
end
