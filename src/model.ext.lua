local _dataDir = path.combine(os.cwd(), 'data')

local _which = proc.exec('which ip', {stdout = 'pipe'})
IP_PATH = '/usr/sbin/ip'
if _which.exitcode == 0 and _which.stdoutStream ~= nil then
    IP_PATH = _which.stdoutStream:read('a'):gsub('^%s*(.-)%s*$', '%1')
end

local _portMap = am.app.get_configuration('PORT_MAP')
if am.app.get_configuration('OUTBOUND_ADDR', false) and not _portMap then
    _portMap = {
        '30666:30666',
        '30666:30666/udp',
        '8895:8895',
        '8895:8895/udp',
        '8897:8897',
        '8897:8897/udp'
    }
end

local _configFilePath = path.combine(am.app.get_model('DATA_DIR', 'data'), 'config.toml')
am.app.set_model(
    {
        STARTUP_ARGS = {
            '--config=' .. _configFilePath,
            '--syncmode=fast',
            '--rpc',
            '--rpcapi=web3,eth,net',
            '--rpccorsdomain=*',
            '--rpcaddr=0.0.0.0',
            ' --rpcvhosts=*'
        }
    },
    {merge = true}
)

am.app.set_model(
    {
        IP_PATH = IP_PATH,
        IPC_PATH = path.combine(_dataDir, 'egem.ipc'),
        IS_ISOLATED = am.app.get_configuration('OUTBOUND_ADDR', false) or
            am.app.get_configuration('PORT_MAP', false) and true,
        SERVICES = {
            ['egem-geth'] = '__egem/assets/daemon.service',
            ['egem-stats'] = '__egem/assets/stats.service'
        },
        PORT_MAP = _portMap
    },
    {merge = true, overwrite = true}
)

am.app.set_model(
    {
        ['egem-geth'] = '__egem/assets/daemon.service',
        ['egem-stats'] = '__egem/assets/stats.service'
    },
    'SERVICES'
)
