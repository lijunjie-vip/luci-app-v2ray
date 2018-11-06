local ucursor = require "luci.model.uci"
local json = require "luci.jsonc"

local proxy_section = ucursor:get_first("v2ray", "transparent_proxy")
local proxy = ucursor:get_all("v2ray", proxy_section)

local server_section = proxy.main_server --"cfg044a8f"
local server = ucursor:get_all("v2ray", server_section)


local function gen_routing()
    local r = {}
    if proxy.bypass_china_addr == '1' then
        table.insert(r, {
            type = "field",
            outboundTag = "direct",
            domain = { "geosite:cn" }
        })
    end
    if proxy.bypass_china_ip == '1' then
        table.insert(r, {
            type = "field",
            outboundTag = "direct",
            ip = { "geoip:cn" }
        })
    end
    table.insert(r, {
        type = "field",
        outboundTag = "direct",
        ip = {
            "0.0.0.0/8",
            "10.0.0.0/8",
            "100.64.0.0/10",
            "127.0.0.0/8",
            "169.254.0.0/16",
            "172.16.0.0/12",
            "192.0.0.0/24",
            "192.0.2.0/24",
            "192.168.0.0/16",
            "198.18.0.0/15",
            "198.51.100.0/24",
            "203.0.113.0/24",
            "::1/128",
            "fc00::/7",
            "fe80::/10"
        }
    })
    return r
end

local v2ray = {
    -- 传入连接
    inbound = {
        port = proxy.local_port,
        protocol = "dokodemo-door",
        settings = {
            network = "tcp",
            followRedirect = true
        },
        sniffing = {
            enabled = true,
            destOverride = { "http", "tls" }
        }
    },
    -- 传出连接
    outbound = {
        protocol = "vmess",
        settings = {
            vnext = {
                {
                    address = server.server,
                    port = tonumber(server.server_port),
                    users = {
                        {
                            id = server.vmess_id,
                            alterId = tonumber(server.alter_id),
                            security = server.security
                        }
                    }
                }
            }
        },
        -- 底层传输配置
        streamSettings = {
            network = server.transport,
            security = (server.tls == '1') and "tls" or "none",
            sockopt = {
                mark = tonumber(proxy.mark)
            },
            tcpSettings = server.transport == "tcp" and {
                header = {
                    type = server.tcp_guise,
                    request = server.tcp_guise == "http" and {
                        version = "1.1",
                        method = "GET",
                        path = server.http_path,
                        headers = {
                            Host = server.http_host,
                            User_Agent = {
                                "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.75 Safari/537.36",
                                "Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_2 like Mac OS X) AppleWebKit/601.1 (KHTML, like Gecko) CriOS/53.0.2785.109 Mobile/14A456 Safari/601.1.46"
                            },
                            Accept_Encoding = { "gzip, deflate" },
                            Connection = { "keep-alive" },
                            Pragma = "no-cache"
                        },
                    } or nil,
                    response = server.tcp_guise == "http" and {
                        version = "1.1",
                        status = "200",
                        reason = "OK",
                        headers = {
                            Content_Type = { "application/octet-stream", "video/mpeg" },
                            Transfer_Encoding = { "chunked" },
                            Connection = { "keep-alive" },
                            Pragma = "no-cache"
                        },
                    } or nil
                }
            } or nil,
            kcpSettings = (server.transport == "kcp") and {
                mtu = tonumber(server.mtu),
                tti = tonumber(server.tti),
                uplinkCapacity = tonumber(server.uplink_capacity),
                downlinkCapacity = tonumber(server.downlink_capacity),
                congestion = (server.congestion == "1") and true or false,
                readBufferSize = tonumber(server.read_buffer_size),
                writeBufferSize = tonumber(server.write_buffer_size),
                header = {
                    type = server.kcp_guise
                }
            } or nil,
            wsSettings = (server.transport == "ws") and {
                path = server.ws_path,
                headers = (server.ws_host ~= nil) and {
                    Host = server.ws_host
                } or nil,
            } or nil,
            httpSettings = (server.transport == "h2") and {
                path = server.h2_path,
                host = server.h2_host,
            } or nil
        }
    },
    -- 额外传出连接
    outboundDetour = {
        {
            protocol = "freedom",
            tag = "direct",
            settings = { keep = "" },
            streamSettings = {
                sockopt = {
                    mark = tonumber(proxy.mark)
                }
            }
        }
    },
    -- 路由
    routing = {
        strategy = "rules",
        settings = {
            domainStrategy = "IPIfNonMatch",
            rules = gen_routing()
        }
    }
}
print(json.stringify(v2ray))