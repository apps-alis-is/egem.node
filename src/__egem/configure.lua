local _user = am.app.get("user")
ami_assert(type(_user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)
local _ok, _uid = fs.safe_getuid(_user)
if not _ok or not _uid then
    log_info("Creating user - " .. _user .. "...")
    local _ok = os.execute('adduser --disabled-login --disabled-password --gecos "" ' .. _user)
    ami_assert(_ok, "Failed to create user - " .. _user, EXIT_INVALID_CONFIGURATION)
    log_info("User " .. _user .. " created.")
else
    log_info("User " .. _user .. " found.")
end

local DATA_PATH = am.app.get_model("DATA_DIR")
local _ok, _error = fs.safe_mkdirp(DATA_PATH)
local _ok, _uid = fs.safe_getuid(_user)
ami_assert(_ok, "Failed to get " .. _user .. "uid - " .. (_uid or ""))

local _ok, _error = fs.safe_chown(DATA_PATH, _uid, _uid, {recurse = true})
if not _ok then
	ami_error("Failed to chown " .. DATA_PATH .. " - " .. (_error or ""))
end

if am.app.get_model("IS_ISOLATED") ~= nil then 
	log_info"'netns' isolation required. Downloading netns-cli..."
	local _tmpFile = os.tmpname()
    local _ok, _error = net.safe_download_file("https://github.com/alis-is/netns-cli/releases/download/0.0.3/netns-cli.lua", _tmpFile, {followRedirects = true})
    if not _ok then
        fs.remove(_tmpFile)
        ami_error("Failed to download: " .. tostring(_error))
    end
	fs.move(_tmpFile, "bin/netns-cli.lua")
	log_success"netns-cli downloaded"
end

log_info "Configuring EGEM services..."
-- we reuse ethereum base
am.execute_extension("__eth/configure.lua")
log_success "EGEM services configured"

