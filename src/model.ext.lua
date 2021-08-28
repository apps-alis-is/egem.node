local _dataDir = path.combine(os.cwd(), "data")

local _which = proc.exec("which ip", { stdout = "pipe" })
IP_PATH="/usr/sbin/ip"
if _which.exitcode == 0 and _which.stdoutStream ~= nil then 
    IP_PATH = _which.stdoutStream:read("a"):gsub("^%s*(.-)%s*$", "%1")
end

am.app.set_model(
    {
        IP_PATH = IP_PATH,
        IPC_PATH = path.combine(_dataDir, ".ethergem/egem.ipc"),
        IS_ISOLATED = am.app.get_configuration("OUTBOUND_ADDR", false) or am.app.get_configuration("PORT_MAP", false),
        SERVICES = {
            ["egem-geth"] = "__egem/assets/daemon.service",
            ["egem-stats"] = "__egem/assets/stats.service"
        }
    },
    { merge = true, overwrite = true }
)

am.app.set_model({
    ["egem-geth"] = "__egem/assets/daemon.service",
    ["egem-stats"] = "__egem/assets/stats.service"
}, "SERVICES")