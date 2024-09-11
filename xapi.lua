
function descriptor()
    return {
        title = "xAPI Integration",
        capabilities = {"input-listener", "playing-listener"}
    }
end

-- *************** Configuration ************

local api_key = ""
local api_secret = ""
local api_url = ""
local api_homepage = ""
local api_userid = ""
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local config_file_path = ""

-- *************** Events ************

function activate()
  api_userid = get_uid()
  config_file_path = get_vlc_config_directory() .. "config.txt"
  load_config(config_file_path)
  vlc.msg.info("config_file_path: "..config_file_path)
  vlc.msg.info("UID is: " .. api_userid)
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

-- *************** Read Config ************

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function get_uid()
  local command = 'whoami '
  local handle = io.popen(command)
  local username = handle:read("*a")
  handle:close()
  if not username then
    return ""
  else
    return trim(username)
  end
end

function get_vlc_config_directory()
  local config_dir

  -- Check the first character of package.config to determine the OS
  if package.config:sub(1,1) == '/' then
    -- Linux or macOS
    if os.getenv("HOME") then
      if io.popen("uname"):read("*l") == "Darwin" then
        -- macOS
        config_dir = os.getenv("HOME") .. "/Library/Preferences/org.videolan.vlc/"
      else
        -- Linux
        config_dir = os.getenv("HOME") .. "/.config/vlc/"
      end
    end
  else
    -- Windows
    config_dir = os.getenv("APPDATA") .. "\\vlc\\"
  end

  if not config_dir then
    vlc.msg.err("Could not determine VLC configuration directory.")
    return nil
  end

  -- Ensure the directory exists (for Linux/macOS, `mkdir -p` is supported)
  local result
  if package.config:sub(1,1) == '/' then
    result = os.execute('mkdir -p "' .. config_dir .. '"')
  else
    -- For Windows, use mkdir
    result = os.execute('mkdir "' .. config_dir .. '"')
  end

  if result ~= 0 then
    vlc.msg.err("Directory already exists: " .. config_dir)
    return config_dir
  end

  return config_dir
end

function read_config(file_path)
  local config = {}
  local file = io.open(file_path, "r")

  if not file then
    vlc.msg.err("Could not open config file: " .. file_path)
    return nil
  end

  for line in file:lines() do
    local key, value = string.match(line, "([%w_]+)%s*=%s*(%S+)")
    if key and value then
      config[key] = value
    else
      vlc.msg.err("Invalid line in config file: " .. line)
    end
  end

  -- print_table(config)

  file:close()

  return config
end

function print_table(tbl)
  for key, value in pairs(tbl) do
    vlc.msg.info(key .. " = " .. tostring(value))
  end
end

-- Function to load configuration
function load_config(file_path)
  local config = read_config(file_path)
  if config then
    for key, value in pairs(config) do
      if key == "api_homepage" then
        api_homepage = value
      elseif key == "api_key" then
        api_key = value
      elseif key == "api_secret" then
        api_secret = value
      elseif key == "api_url" then
        api_url = value
      else
        vlc.msg.err("Unknown key " .. key .. " found in config at filepath " .. file_path)
      end
    end
  else
    vlc.msg.err("Failed to load config.")
  end
end

function write_config(config, file_path)
  -- Open the file for writing ("w" overwrites the file)
  local file = io.open(file_path, "w")

  if not file then
    vlc.msg.err("No config file exists at " .. file_path .. " ...creating one.")
    io.popen("touch " .. filepath):close()
    file = io.open(file_path, "w")
  end

  -- Iterate over the key-value pairs in the config table
  for key, value in pairs(config) do
    -- Write each key-value pair in the format: key = value
    file:write(key .. " = " .. tostring(value) .. "\n")
  end

  -- Close the file
  file:close()
  return true
end

-- *************** Hook ************

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
  local current_time = (vlc.var.get(input, "time") / 1000000) or "Unknown Time"
  local position = vlc.var.get(input, "position") or "Unknown Position"

  -- Log metadata
  vlc.msg.info("Title: " .. title)
  vlc.msg.info("Duration: " .. (duration ~= -1 and (duration .. " seconds") or "Live Stream"))
  vlc.msg.info("Current Time: " .. current_time .. " seconds")
  vlc.msg.info("Current Position: " .. (position * 100) .. "%")

  local statement = form_statement({title = title,
                                    status = status,
                                    duration = tostring(duration),
                                    current_time = tostring(current_time),
                                    progress = tostring(position)})
  vlc.msg.info("Statement: " .. statement)
  post_request(statement)
end

-- *************** Interface ************

-- Function to create the API settings dialog
function show_api_settings_dialog()
    -- Create a dialog window
    dlg = vlc.dialog("xAPI  Integration Settings")

    dlg:add_label("Homepage URL:", 1, 1)
    api_homepage_input = dlg:add_text_input(api_homepage, 1, 2)

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
    api_homepage = api_homepage_input:get_text()

    write_config({api_homepage = api_homepage,
                  api_key = api_key,
                  api_secret = api_secret,
                  api_url = api_url}, config_file_path)

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
  local duration = args.duration
  local progress = args.progress
  local current_time = args.current_time
  local base_url = "https://yet.systems/xapi/profiles/vlc"
  local verb = base_url .. "/verbs/" .. status
  local activity_url = base_url .. "/activity"
  local video_url = activity_url .. "/video"
  local object = video_url .. "/" .. title
  local extension_url = base_url .. "/extensions/"
  local duration_url = extension_url .. "duration"
  local progress_url = extension_url .. "progress"
  local current_time_url = extension_url .. "currentTime"

    -- Manually construct the JSON string with results
  local json_statement =
    '{' ..
      '"actor": {' ..
        '"account": {' ..
          '"homePage": "' .. api_homepage .. '",' ..
          '"name": "' .. api_userid .. '"' ..
        '},' ..
        '"objectType": "Agent"' ..
      '},' ..
      '"verb": {' ..
        '"id": "' .. verb .. '"' ..
      '},' ..
      '"object": {' ..
        '"id": "' .. object .. '",' ..
        '"objectType": "Activity"' ..
      '},' ..
      '"result": {' ..
        '"extensions": {' ..
          '"' .. duration_url .. '": ' .. duration .. ',' ..
          '"' .. progress_url .. '": ' .. progress .. ',' ..
          '"' .. current_time_url .. '": ' .. current_time ..
        '}' ..
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
