setfpscap(10)

local cfg = {
    api = "http://108.181.155.25:8000",
    usr = game:GetService("Players").LocalPlayer.Name,
    min = 1,
    max = nil,
    hooks = {
        {min = 1, max = 9999999, url = "https://discord.com/api/webhooks/1457569650975178804/JiJhRoE2ZP054g8kMeKaZ-H2nOLDa48MSuz0bXoR0RPNSLaD4MQ33ZuP4xkw4w6jbRjC", role = "1457570544391294996"},
        {min = 10000000, max = 50000000, url = "https://discord.com/api/webhooks/1457569841895702610/3Aqn5B92pOPMrWdMF3e2_n6_v08PJ4pcxrBIc_tggmyS6U66R-tTAM2bHK8DWNlAQrJR", role = "1457570617158275072"},
        {min = 50000000, max = 100000000, url = "https://discord.com/api/webhooks/1457570017502691409/g8BviND1dIg04gzPSzkeiZpR3mhfflLyhbAOlyWBRUm7FzLX54nE_sU7dMnCv1iNBDRd", role = "1457570622870782013"},
        {min = 100000000, max = 500000000, url = "https://discord.com/api/webhooks/1457570068123877470/W_CsLF9GjNk31wkbltasOemMNaH0COCuI12tMhYTvtVsP9lUOVqx41UdHbYKsuY2qgyu", role = "1457570624888111104"},
        {min = 500000000, max = nil, url = "https://discord.com/api/webhooks/1457570437075566726/Q-x-HI1DaWlqumkqctsbecrzNbb3slq3EaUfMWtozoHNW-eUxBjfCIbH8789iglrR_Gk", role = "1457570732732059668"}
    },
    hlHook = "https://discord.com/api/webhooks/1457569001944121648/bAkPidt9lS6qZCSUXXCdBRO-H3syTkBDjv2XB52BhiRyLek9NpRabHurwdgqyaONP2ZX",
    scanWait = 0.3,
    hopWait = 0.3,
    retryWait = 1,
    tpTimeout = 5,
    maxRetries = 3,
    parallel = true,
    scanTimeout = 2,
    waitPlots = true,
    maxWaitPlots = 2
}

local data = loadstring(game:HttpGet("https://raw.githubusercontent.com/v0qh/LuauScripts/main/NotifierData.lua"))()
local emj = data and data.Emojis or {}
local hl = data and data.Highlights or {}
local brand = data and data.Branding or {Footer = "https://media.discordapp.net/attachments/1457535472413970503/1459695036274049261/Comis-removebg-preview.png"}

local traits = game:GetService("ReplicatedStorage"):WaitForChild("Datas"):WaitForChild("Traits")

local perf = {opt = false, cons = {}}

function perf:init()
    if self.opt then return end
    self.opt = true
    
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        
        local ws = game:GetService("Workspace")
        for _, o in ipairs(ws:GetDescendants()) do
            if o:IsA("Texture") or o:IsA("Decal") then
                o.Transparency = 1
            elseif o:IsA("ParticleEmitter") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
                o.Enabled = false
            elseif o:IsA("MeshPart") or o:IsA("Part") then
                o.Material = Enum.Material.SmoothPlastic
                o.CastShadow = false
            end
        end
        
        local l = game:GetService("Lighting")
        l.GlobalShadows = false
        l.FogEnd = 9e9
        for _, fx in ipairs(l:GetChildren()) do
            if fx:IsA("PostEffect") then
                fx.Enabled = false
            end
        end
    end)
end

function perf:clean()
    for _, c in pairs(self.cons) do
        pcall(function() c:Disconnect() end)
    end
    self.cons = {}
    
    pcall(function()
        for i = 1, 3 do
            game:GetService("RunService").Heartbeat:Wait()
        end
    end)
end

function perf:add(c)
    table.insert(self.cons, c)
end

local val = {}

function val:parse(txt)
    if not txt or type(txt) ~= "string" then return 0 end
    
    txt = txt:gsub("[%$,/s%s]", "")
    local num, sfx = txt:match("^([%d%.]+)([KMBTQ]?)$")
    if not num then return 0 end
    
    local n = tonumber(num)
    if not n then return 0 end
    
    local m = {K=1e3, M=1e6, B=1e9, T=1e12, Q=1e15}
    if sfx and #sfx > 0 then
        local mult = m[sfx:upper()]
        if mult then n = n * mult end
    end
    
    return n
end

function val:fmt(v)
    local s = {"", "K", "M", "B", "T", "Q"}
    local i = 1
    
    while v >= 1000 and i < #s do
        v = v / 1000
        i = i + 1
    end
    
    return string.format("%.2f%s", v, s[i])
end

function val:strip(txt)
    if not txt or type(txt) ~= "string" then return txt end
    
    txt = txt:gsub("<[^>]+>", "")
    txt = txt:gsub("</[^>]+>", "")
    txt = txt:gsub("%s+", " ")
    txt = txt:match("^%s*(.-)%s*$") or txt
    
    return txt
end

local api = {}
api.__index = api

function api.new(base, usr)
    local s = setmetatable({}, api)
    s.base = base
    s.usr = usr
    s.http = game:GetService("HttpService")
    return s
end

function api:init()
    local ok, res = pcall(function()
        local req = request or http_request or (syn and syn.request)
        if req then
            local r = req({
                Url = self.base .. "/init",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = self.http:JSONEncode({username = self.usr})
            })
            return r.Body
        end
    end)
    
    if ok and res then
        local data = self.http:JSONDecode(res)
        print(string.format("[API] Init: %d bots", data.count or 0))
        return true
    end
    
    print("[API] Init failed:", res or "no response")
    return false
end

function api:job()
    local req = request or http_request or (syn and syn.request)
    if not req then return nil end

    local ok, r = pcall(function()
        return req({
            Url = self.base .. "/job",
            Method = "GET"
        })
    end)

    if not ok or not r then
        warn("[API] request failed")
        return nil
    end
    
    if r.StatusCode ~= 200 or not r.Body or r.Body == "" then
        return nil
    end

    local success, data = pcall(function()
        return self.http:JSONDecode(r.Body)
    end)

    if success and type(data) == "table" then
        return data.jobId
    end

    return nil
end


local debris = {temps = {}, last = 0, dur = 0.5}

function debris:upd()
    local t = tick()
    if t - self.last < self.dur then
        return self.temps
    end
    
    self.temps = {}
    local d = game:GetService("Workspace"):FindFirstChild("Debris")
    if d then
        for _, c in pairs(d:GetChildren()) do
            if c.Name == "FastOverheadTemplate" then
                local g = c:FindFirstChild("AnimalOverhead")
                if g and g:IsA("SurfaceGui") then
                    local dn = g:FindFirstChild("DisplayName")
                    if dn and dn:IsA("TextLabel") then
                        table.insert(self.temps, {
                            gui = g,
                            pos = c.Position,
                            name = dn.Text or "",
                            lower = string.lower(dn.Text or "")
                        })
                    end
                end
            end
        end
    end
    self.last = t
    return self.temps
end

function debris:find(n, p)
    local t = self:upd()
    if #t == 0 then return nil end
    
    local nl = string.lower(n)
    local closest, dist = nil, math.huge
    
    for _, temp in ipairs(t) do
        if temp.name == n or temp.lower == nl or 
           temp.lower:find(nl, 1, true) or nl:find(temp.lower, 1, true) then
            
            if p then
                local d = (temp.pos - p).Magnitude
                if d < dist then
                    dist = d
                    closest = temp.gui
                end
            else
                return temp.gui
            end
        end
    end
    
    return closest
end

function debris:clr()
    self.temps = {}
    self.last = 0
end

local scan = {}
scan.__index = scan

function scan.new(minv, maxv, c)
    local s = setmetatable({}, scan)
    s.minv = minv
    s.maxv = maxv
    s.cfg = c
    return s
end

function scan:owner(plt)
    local ok, own = pcall(function()
        return plt:FindFirstChild("PlotSign"):FindFirstChild("SurfaceGui"):FindFirstChild("Frame"):FindFirstChild("TextLabel").Text:match("^(.+)'s? Base") or "Unknown"
    end)
    return ok and own or "Unknown"
end

function scan:traits(oh)
    if not oh then return {} end
    
    local tr = oh:FindFirstChild("Traits")
    if not tr then return {} end
    
    local found = {}
    for _, img in pairs(tr:GetChildren()) do
        if img:IsA("ImageLabel") then
            local aid = img.Image:match("rbxassetid://(%d+)")
            if aid then
                for tn, td in pairs(traits:GetChildren()) do
                    if td:IsA("ModuleScript") then
                        local ok, tdata = pcall(function() return require(td) end)
                        if ok and tdata.Icon then
                            local tid = tdata.Icon:match("rbxassetid://(%d+)")
                            if tid == aid then
                                table.insert(found, tn)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    return found
end

function scan:pet(oh)
    if not oh or (not oh:IsA("BillboardGui") and not oh:IsA("SurfaceGui")) then 
        return nil 
    end
    
    local gen = oh:FindFirstChild("Generation")
    local nm = oh:FindFirstChild("DisplayName")
    if not gen or not nm then return nil end
    
    local gtxt = gen.Text or "0/s"
    local mps = val:parse(gtxt)
    local pnm = val:strip(nm.Text or "Unknown")
    
    local rar = "Unknown"
    local rlbl = oh:FindFirstChild("Rarity")
    if rlbl and rlbl:IsA("TextLabel") and rlbl.Text ~= "" then
        rar = val:strip(rlbl.Text)
    end
    
    local mut = "Normal"
    local mlbl = oh:FindFirstChild("Mutation")
    if mlbl and mlbl:IsA("TextLabel") and mlbl.Visible and mlbl.Text ~= "" then
        mut = val:strip(mlbl.Text)
    end
    
    local trs = self:traits(oh)
    
    return {
        nm = pnm,
        gen = gtxt,
        val = mps,
        rar = rar,
        mut = mut,
        traits = trs
    }
end

function scan:plt(plt)
    local res = {}
    if not plt:IsA("Model") then return res end
    
    local own = self:owner(plt)
    local proc = {}
    
    for _, c in pairs(plt:GetChildren()) do
        if c:IsA("Model") and not c:FindFirstChild("Humanoid") then
            local vis = false
            for _, p in pairs(c:GetChildren()) do
                if p:IsA("MeshPart") and p.Transparency < 1 then
                    vis = true
                    break
                end
            end
            
            if vis then
                local oh = c:FindFirstChild("AnimalOverhead") or c:FindFirstChild("AnimalOverhead", true)
                
                if not oh and debris then
                    local pp = c.PrimaryPart or c:FindFirstChildOfClass("BasePart")
                    if pp then
                        oh = debris:find(c.Name, pp.Position)
                    end
                end
                
                if oh then
                    local pd = self:pet(oh)
                    if pd and pd.val > 0 then
                        if not pd.nm or pd.nm == "" then 
                            pd.nm = c.Name or "Unknown" 
                        end
                        
                        local ok = pd.val >= self.minv
                        if self.maxv then
                            ok = ok and pd.val <= self.maxv
                        end
                        
                        if ok and not proc[c] then
                            proc[c] = true
                            table.insert(res, {
                                plt = plt.Name,
                                own = own,
                                pet = pd,
                                val = pd.val,
                                fmt = val:fmt(pd.val)
                            })
                        end
                    end
                end
            end
        end
    end
    
    local pods = plt:FindFirstChild("AnimalPodiums")
    if pods then
        for _, pod in pairs(pods:GetChildren()) do
            if pod:IsA("Model") then
                local base = pod:FindFirstChild("Base")
                if base then
                    local spwn = base:FindFirstChild("Spawn")
                    if spwn then
                        local att = spwn:FindFirstChild("Attachment")
                        if att then
                            local oh = att:FindFirstChild("AnimalOverhead")
                            
                            local mdl = nil
                            for _, ch in pairs(att:GetChildren()) do
                                if ch:IsA("Model") and not ch:FindFirstChild("Humanoid") then 
                                    mdl = ch
                                    break
                                end
                            end
                            
                            if not oh and mdl and debris then
                                local prt = mdl.PrimaryPart or mdl:FindFirstChildOfClass("BasePart")
                                if prt then
                                    oh = debris:find(mdl.Name, prt.Position)
                                end
                            end
                            
                            if oh then
                                local pd = self:pet(oh)
                                if pd and pd.val > 0 then
                                    if not pd.nm or pd.nm == "" then 
                                        pd.nm = (mdl and mdl.Name) or pod.Name or "Unknown" 
                                    end
                                    
                                    local ok = pd.val >= self.minv
                                    if self.maxv then
                                        ok = ok and pd.val <= self.maxv
                                    end
                                    
                                    if ok and mdl and not proc[mdl] then
                                        proc[mdl] = true
                                        table.insert(res, {
                                            plt = plt.Name,
                                            own = own,
                                            pet = pd,
                                            val = pd.val,
                                            fmt = val:fmt(pd.val)
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return res
end

function scan:all()
    local ws = game:GetService("Workspace")
    local plts = ws:FindFirstChild("Plots")
    
    if not plts and self.cfg.waitPlots then
        local st = tick()
        while not plts and (tick() - st) < self.cfg.maxWaitPlots do
            task.wait(0.05)
            plts = ws:FindFirstChild("Plots")
        end
    end
    
    if not plts then 
        return {} 
    end
    
    local plist = plts:GetChildren()
    local allres = {}
    local done = 0
    
    if self.cfg.parallel then
        for _, p in ipairs(plist) do
            task.spawn(function()
                local r = self:plt(p)
                for _, x in ipairs(r) do
                    table.insert(allres, x)
                end
                done = done + 1
            end)
        end
        
        local to = tick() + self.cfg.scanTimeout
        while done < #plist and tick() < to do
            task.wait(0.05)
        end
    else
        for _, p in ipairs(plist) do
            local r = self:plt(p)
            for _, x in ipairs(r) do
                table.insert(allres, x)
            end
        end
    end
    
    return allres
end

local hook = {}
hook.__index = hook

function hook.new(hcfg, http)
    return setmetatable({
        cfg = hcfg,
        http = http
    }, hook)
end

function hook:getHook(v)
    for _, h in ipairs(self.cfg) do
        if v >= h.min and (not h.max or v <= h.max) then
            return h
        end
    end
    return nil
end

function hook:traitStr(trs)
    if not trs or #trs == 0 or not emj then return "" end
    
    local str = ""
    for _, t in ipairs(trs) do
        local eid = emj[t]
        if eid then
            str = str .. string.format("<:t:%s> ", eid)
        else
            print("[DEBUG] Trait not found in emojis:", t)
        end
    end
    
    return str
end

function hook:send(res, jid, pid)
    if not res or #res == 0 then return end
    
    local sent = {}
    
    for _, r in ipairs(res) do
        local nm = r.pet.nm
        print("[DEBUG] Pet name:", nm)
        
        local hd = hl[nm]
        
        if hd then
            print("[DEBUG] Highlight found! Min:", hd.Min, "Val:", r.val)
            if r.val >= (hd.Min or 0) and not sent[nm] then
                sent[nm] = true
                task.spawn(function()
                    self:hl(r, hd, jid, pid)
                end)
            end
        else
            print("[DEBUG] No highlight for:", nm)
        end
    end
    

function hook:send(res, jid, pid)
    if not res or #res == 0 then return end
    
    local sent = {}
    
    for _, r in ipairs(res) do
        local nm = r.pet.nm
        local hd = hl[nm]
        
        if hd and r.val >= (hd.Min or 0) and not sent[nm] then
            sent[nm] = true
            task.spawn(function()
                self:hl(r, hd, jid, pid)
            end)
        end
    end
    
    local grp = {}
    for _, r in ipairs(res) do
        local h = self:getHook(r.val)
        if h then
            local k = h.url
            if not grp[k] then
                grp[k] = {hook = h, res = {}}
            end
            table.insert(grp[k].res, r)
        end
    end
    
    for _, g in pairs(grp) do
        task.spawn(function()
            self:post(g.hook, g.res, jid, pid)
        end)
    end
end

function hook:hl(r, hd, jid, pid)
    local p = r.pet
    
    local tstr = self:traitStr(p.traits)
    local ms = ""
    if p.mut and p.mut ~= "Normal" and p.mut ~= "" then
        ms = string.format(" • **[%s]**", p.mut)
    end
    
    local desc = string.format(
        "**%s** %s\n└ `$%s/s` • *%s*%s\n\n### Server Info\n🆔 `%s`\n👥 `%d/8`",
        p.nm, tstr, val:fmt(r.val), p.rar, ms,
        jid, #game:GetService("Players"):GetPlayers()
    )
    
    local pay = {
        embeds = {{
            title = string.format("%s Found • $%s/s", p.nm, val:fmt(r.val)),
            description = desc,
            color = 0xFF00FF,
            thumbnail = {url = hd.Icon or ""},
            footer = {
                text = "Cosmic Notifier",
                icon_url = brand.Footer
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }
    
    pcall(function()
        local req = request or http_request or (syn and syn.request)
        if req then
            req({
                Url = cfg.hlHook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = self.http:JSONEncode(pay)
            })
        end
    end)
end

function hook:post(h, res, jid, pid)
    if not h.url then return end
    
    local link = string.format("https://fern.wtf/joiner?placeid=%s&gameinstanceid=%s", pid, jid)
    
    local owns = {}
    for _, plt in ipairs(res) do
        local o = plt.own or "Unknown"
        owns[o] = owns[o] or {}
        table.insert(owns[o], plt)
    end
    
    local tot = 0
    local hashl = false
    for _, plt in ipairs(res) do
        tot = tot + plt.val
        if hl[plt.pet.nm] and plt.val >= (hl[plt.pet.nm].Min or 0) then
            hashl = true
        end
    end
    
    local desc = ""
    
    local cnt = 0
    for own, plts in pairs(owns) do
        desc = desc .. string.format("### %s's Base\n\n", own)
        
        for _, plt in ipairs(plts) do
            cnt = cnt + 1
            if cnt > 8 then break end
            
            local p = plt.pet
            
            local hd = hl[p.nm]
            local ic = ""
            if hd and plt.val >= (hd.Min or 0) then
                ic = "⭐ "
            end
            
            local tstr = self:traitStr(p.traits)
            local ms = ""
            if p.mut and p.mut ~= "Normal" and p.mut ~= "" then
                ms = string.format(" • **[%s]**", p.mut)
            end
            
            desc = desc .. string.format(
                "%s**%s** %s\n└ `$%s/s` • *%s*%s\n\n",
                ic, p.nm, tstr, plt.fmt, p.rar, ms
            )
        end
        
        if cnt > 8 then break end
    end
    
    if #res > 8 then
        desc = desc .. string.format("*+%d more pets*\n\n", #res - 8)
    end
    
    local plrs = #game:GetService("Players"):GetPlayers()
    desc = desc .. string.format("### Server Info\n🆔 `%s`\n👥 `%d/8`", jid, plrs)
    
    local pay = {
        content = h.role and string.format("<@&%s>", h.role) or "",
        embeds = {{
            title = string.format("🎯 %d Pets Found • $%s/s Total", #res, val:fmt(tot)),
            description = desc,
            color = 0xF54D4F,
            footer = {
                text = string.format("Cosmic Notifier • $%s - %s", val:fmt(h.min), h.max and ("$" .. val:fmt(h.max)) or "∞"),
                icon_url = brand.Footer
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }
    
    pcall(function()
        local req = request or http_request or (syn and syn.request)
        if req then
            req({
                Url = h.url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = self.http:JSONEncode(pay)
            })
        end
    end)
end

local hop = {}
hop.__index = hop

function hop.new(c, a)
    local s = setmetatable({}, hop)
    s.cfg = c
    s.api = a
    s.http = game:GetService("HttpService")
    s.tp = game:GetService("TeleportService")
    s.plr = game:GetService("Players").LocalPlayer
    s.hopping = false
    s.cur = nil
    s.lastHop = 0
    
    local conn = s.tp.TeleportInitFailed:Connect(function(p, res, err)
        if p == s.plr then
            local fid = s.cur
            s.cur = nil
            s.hopping = false
            task.wait(0.5)
            task.spawn(function()
                s:go(0, fid)
            end)
        end
    end)
    perf:add(conn)
    
    return s
end

function hop:scanCur()
    local sc = scan.new(self.cfg.min, self.cfg.max, self.cfg)
    local res = sc:all()
    
    if #res > 0 then
        local h = hook.new(self.cfg.hooks, self.http)
        h:send(res, game.JobId, game.PlaceId)
        print(string.format("[+] %d", #res))
    end
    
    return res
end

function hop:go(retry)
    retry = retry or 0
    
    if self.hopping and retry == 0 then return end
    
    local since = tick() - self.lastHop
    if since < 3 then
        task.wait(3 - since)
    end
    
    self.hopping = true
    self.lastHop = tick()
    
    perf:clean()
    
    local jid = self.api:job()
    
    if jid then
        self.cur = jid
        
        local ok = pcall(function()
            self.tp:TeleportToPlaceInstance(game.PlaceId, jid, self.plr)
        end)
        
        if not ok then
            self.cur = nil
            self.hopping = false
            task.wait(self.cfg.retryWait)
            self:go(retry + 1)
        else
            local st = tick()
            while self.hopping and self.cur == jid and (tick() - st) < self.cfg.tpTimeout do
                task.wait(0.5)
            end
            
            if self.hopping and self.cur == jid then
                self.cur = nil
                self.hopping = false
                task.wait(self.cfg.retryWait)
                self:go(retry + 1)
            end
        end
    else
        if retry < self.cfg.maxRetries then
            task.wait(self.cfg.retryWait)
            self.hopping = false
            self:go(retry + 1)
        else
            task.wait(5)
            self.hopping = false
            self:go(0)
        end
    end
end

function hop:start()
    perf:init()
    task.wait(self.cfg.scanWait)
    
    self:scanCur()
    
    task.wait(self.cfg.hopWait)
    self:go(0)
end

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.3)

local a = api.new(cfg.api, cfg.usr)
if not a:init() then
    warn("[API] Failed to initialize")
    return
end

local h = hop.new(cfg, a)
h:start()
