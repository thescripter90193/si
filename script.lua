-- HLHUB Premium v1.5
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local VERSION = "Premium v1.5"
local DISCORD_ID = "1515270"
local DISCORD_SERVER = "https://discord.gg/4yr4Br3xU"
local KEY_OK = "HLHUB"
local KEY_FILE = "hlhub_premium_key.txt"
local CFG_FILE = "hlhub_premium_cfg.txt"

local minimized, potatoOn = false, false
local savedFX = nil
local statusLbl, fpsLbl, pingLbl
local fps, frames, fpsT = 0, 0, tick()
local SPEED, speedOn, speedOpen = 16, false, true
local stamOn, stamOpen = false, true
local noCdOn, noCdOpen, lastCd, cdHooked = false, true, 0, false
local afkOn, lastAfk = false, 0
local decreaseRem, stamTick = nil, 0
local gkOn, gkPos, lastGK, cachedBall, ballScan, lastGkSave = false, nil, 0, nil, 0, nil
local lastDive, diveRem = 0, nil
local gkVisionOn, lastVis = false, 0
local hiddenCyl = {}
-- dive CD quitado: rompia el boton de GK
local slideOn, SLIDE, lastSlide, slideRem = false, 10, 0, nil
local dribOn, DRIB, lastDrib, dribRem = false, 10, 0, nil
local POWER, powerOn, shootRem, lastShot = 80, false, nil, 0
local passOn, lastPass, passRem = false, 0, nil
local hubBind, toggleHubFn = "RightShift", nil
local powerBind = "P"
local styleEspOn, enemyEspOn, ballEspOn, lastEsp = false, false, false, 0
-- Hitbox expander del balon
local ballHitboxOn, ballHitboxSize, lastBallHitbox, cupulaVisible = false, 2, 0, true

local C = {
        bg = Color3.fromRGB(12, 16, 24),
        top = Color3.fromRGB(16, 20, 30),
        side = Color3.fromRGB(14, 18, 28),
        btn = Color3.fromRGB(24, 32, 48),
        line = Color3.fromRGB(70, 150, 255),
        text = Color3.fromRGB(230, 236, 255),
        muted = Color3.fromRGB(140, 150, 175),
        on = Color3.fromRGB(36, 90, 58),
        onT = Color3.fromRGB(130, 255, 170),
}

local function keyOk(txt)
        return string.upper(tostring(txt or ""):gsub("%s+", "")) == KEY_OK
end

local function yaEntro()
        -- BYPASS: no leer archivo, siempre devuelve true
        return true
end

local function guardarKey()
        -- BYPASS: no escribir archivo
end

local function getHum()
        local c = player.Character
        return c and c:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
        local c = player.Character
        return c and c:FindFirstChild("HumanoidRootPart")
end

local function clampSpeed(n)
        n = math.floor(tonumber(n) or 16)
        return math.clamp(n, 1, 50)
end

local function applySpeed()
        local hum = getHum()
        if hum then pcall(function() hum.WalkSpeed = speedOn and SPEED or 16 end) end
end

local function saveCfg()
        -- BYPASS: no guardar config en archivo
        return
end

local function loadCfg()
        -- BYPASS: no leer config de archivo
        return
end


local function resetCfg()
        SPEED, speedOn = 16, false
        stamOn = false
        noCdOn = false
        slideOn, SLIDE = false, 10
        dribOn, DRIB = false, 10
        powerOn, POWER, passOn = false, 80, false
        gkOn, gkVisionOn = false, false
        styleEspOn, enemyEspOn, ballEspOn = false, false, false
        ballHitboxOn, ballHitboxSize, cupulaVisible = false, 2, true
        afkOn = false
        if potatoOn then
                pcall(function()
                        if optOff then optOff() end
                end)
                potatoOn = false
        end
        applySpeed()
        applyStyleEsp()
        applyEnemyEsp()
        applyBallHitbox()
        pcall(function()
                if isfile and isfile(CFG_FILE) and delfile then delfile(CFG_FILE) end
        end)
        saveCfg()
end

local function applyAfk()
        if not afkOn then return end
        if tick() - lastAfk < 480 then return end
        lastAfk = tick()
        local hum = getHum()
        if hum then pcall(function() hum.Jump = true end) end
end

-- BYPASS: VirtualUser removido (era bandera roja para el anticheat)
-- El Anti-AFK ahora solo salta cada 8 min (sin VirtualUser)
pcall(function()
        player.Idled:Connect(function()
                if not afkOn then return end
                pcall(function()
                        local hum = getHum()
                        if hum then hum.Jump = true end
                end)
        end)
end)

local function getStyle(plr)
        local stats = plr:FindFirstChild("PlayerStats")
        local s = stats and (stats:FindFirstChild("Style") or stats:FindFirstChild("style"))
        if s then return tostring(s.Value) end
        local char = plr.Character
        local vals = char and char:FindFirstChild("Values")
        local st = vals and (vals:FindFirstChild("Style") or vals:FindFirstChild("style"))
        if st then return tostring(st.Value) end
        return "?"
end

local function clearStyleEsp()
        for _, plr in ipairs(Players:GetPlayers()) do
                local char = plr.Character
                if char then
                        local old = char:FindFirstChild("HLHUBStyleESP", true)
                        if old then old:Destroy() end
                end
        end
end

local function applyStyleEsp()
        if not styleEspOn then
                clearStyleEsp()
                return
        end
        for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                        local head = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
                        if head then
                                local bb = head:FindFirstChild("HLHUBStyleESP")
                                if not bb then
                                        bb = Instance.new("BillboardGui")
                                        bb.Name = "HLHUBStyleESP"
                                        bb.Size = UDim2.new(0, 140, 0, 22)
                                        bb.StudsOffset = Vector3.new(0, 2.6, 0)
                                        bb.AlwaysOnTop = true
                                        bb.Parent = head
                                        local tl = Instance.new("TextLabel")
                                        tl.Name = "Txt"
                                        tl.Size = UDim2.new(1, 0, 1, 0)
                                        tl.BackgroundTransparency = 1
                                        tl.Font = Enum.Font.GothamBold
                                        tl.TextSize = 14
                                        tl.TextColor3 = Color3.fromRGB(180, 220, 255)
                                        tl.TextStrokeTransparency = 0.35
                                        tl.Parent = bb
                                end
                                local tl = bb:FindFirstChild("Txt")
                                if tl then
                                        local enemy = player.Team and plr.Team and plr.Team ~= player.Team
                                        tl.Text = getStyle(plr)
                                        tl.TextColor3 = enemy and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(180, 220, 255)
                                end
                        end
                end
        end
end

local function applyEnemyEsp()
        for _, plr in ipairs(Players:GetPlayers()) do
                local char = plr.Character
                if char then
                        local hl = char:FindFirstChild("HLHUBEnemyESP")
                        local enemy = plr ~= player and player.Team and plr.Team and plr.Team ~= player.Team
                        if enemyEspOn and enemy then
                                if not hl then
                                        hl = Instance.new("Highlight")
                                        hl.Name = "HLHUBEnemyESP"
                                        hl.FillColor = Color3.fromRGB(220, 50, 50)
                                        hl.FillTransparency = 0.72
                                        hl.OutlineColor = Color3.fromRGB(255, 80, 80)
                                        hl.OutlineTransparency = 0
                                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                        hl.Parent = char
                                end
                        elseif hl then
                                hl:Destroy()
                        end
                end
        end
end


local function knitRE(service, name)
        local knit = ReplicatedStorage:FindFirstChild("Packages")
        knit = knit and knit:FindFirstChild("Knit")
        local services = knit and knit:FindFirstChild("Services")
        local s = services and services:FindFirstChild(service)
        local re = s and s:FindFirstChild("RE")
        return re and re:FindFirstChild(name)
end

local function fillStamina()
        if not decreaseRem or not decreaseRem.Parent then
                decreaseRem = knitRE("StaminaService", "DecreaseStamina")
        end
        pcall(function()
                local stats = player:FindFirstChild("PlayerStats")
                local stam = stats and stats:FindFirstChild("Stamina")
                if stam then stam.Value = 99 end
                if decreaseRem then decreaseRem:FireServer(0 / 0) end
        end)
end

local function wrapCd(old)
        return function(s, n, ...)
                if noCdOn then
                        return old(s, n, 0)
                end
                return old(s, n, ...)
        end
end

local function hookAbilityCd()
        if cdHooked then return true end
        pcall(function()
                local C = require(ReplicatedStorage.Controllers.AbilityController)
                if type(C) == "table" and type(C.AbilityCooldown) == "function" then
                        C.AbilityCooldown = wrapCd(C.AbilityCooldown)
                        cdHooked = true
                end
        end)
        if not cdHooked and hookfunction then
                pcall(function()
                        local C = require(ReplicatedStorage.Controllers.AbilityController)
                        if type(C) == "table" and type(C.AbilityCooldown) == "function" then
                                hookfunction(C.AbilityCooldown, wrapCd(C.AbilityCooldown))
                                cdHooked = true
                        end
                end)
        end
        if not cdHooked and getgc then
                pcall(function()
                        for _, v in ipairs(getgc(true)) do
                                if type(v) == "table" then
                                        local fn = rawget(v, "AbilityCooldown")
                                        if type(fn) == "function" then
                                                v.AbilityCooldown = wrapCd(fn)
                                                cdHooked = true
                                                break
                                        end
                                end
                        end
                end)
        end
        return cdHooked
end

local function wipeCd(obj, diveOnly)
        if not obj then return end
        pcall(function()
                for _, v in ipairs(obj:GetDescendants()) do
                        local n = string.lower(v.Name)
                        local hit
                        if diveOnly then
                                hit = (n:find("dive") and n:find("cool")) or n:find("divecd") or n:find("dive_cd")
                        else
                                hit = n:find("cooldown") or n:find("ability") or n:find("skill") or n:find("awakening") or n:find("stylecd")
                        end
                        if hit then
                                if v:IsA("NumberValue") or v:IsA("IntValue") then
                                        v.Value = 0
                                elseif v:IsA("BoolValue") and not n:find("goalie") and n ~= "gk" then
                                        v.Value = false
                                end
                        end
                end
        end)
end

local function fillNoCd()
        hookAbilityCd()
        local char = player.Character
        if char then
                wipeCd(char)
                wipeCd(char:FindFirstChild("Values"))
                wipeCd(char:FindFirstChild("AbilityCooldowns"))
        end
        wipeCd(player:FindFirstChild("PlayerStats"))
        wipeCd(player:FindFirstChild("AbilityCooldowns"))
        local pg = player:FindFirstChild("PlayerGui")
        if pg then
                wipeCd(pg)
                wipeCd(pg:FindFirstChild("Abilities"))
                wipeCd(pg:FindFirstChild("Skills"))
                wipeCd(pg:FindFirstChild("Hotbar"))
        end
        pcall(function()
                for _, v in ipairs(player:GetDescendants()) do
                        local n = string.lower(v.Name)
                        if n:find("abilitycooldown") or n == "abilitycooldowns" then
                                wipeCd(v)
                                if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value = 0 end
                        end
                end
        end)
end

local function findBall()
        if cachedBall and cachedBall.Parent then return cachedBall end
        local names = { "Football", "Ball", "SoccerBall" }
        local function take(obj)
                if not obj then return nil end
                if obj:IsA("Model") then
                        obj = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                end
                if obj and obj:IsA("BasePart") then
                        cachedBall = obj
                        return obj
                end
                return nil
        end
        for _, n in ipairs(names) do
                local b = take(workspace:FindFirstChild(n))
                if b then return b end
        end
        for _, obj in ipairs(workspace:GetChildren()) do
                local n = string.lower(obj.Name)
                if n:find("foot") or n:find("ball") then
                        local b = take(obj)
                        if b then return b end
                end
        end
        return nil
end

local function applyBallEsp()
        local ball = findBall()
        if not ballEspOn then
                if ball then
                        local hl = ball:FindFirstChild("HLHUBBallESP")
                        if hl then hl:Destroy() end
                        local bb = ball:FindFirstChild("HLHUBBallTag")
                        if bb then bb:Destroy() end
                end
                return
        end
        if not ball then return end
        local hl = ball:FindFirstChild("HLHUBBallESP")
        if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "HLHUBBallESP"
                hl.FillColor = Color3.fromRGB(255, 220, 80)
                hl.FillTransparency = 0.45
                hl.OutlineColor = Color3.fromRGB(255, 240, 140)
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = ball
        end
        local bb = ball:FindFirstChild("HLHUBBallTag")
        if not bb then
                bb = Instance.new("BillboardGui")
                bb.Name = "HLHUBBallTag"
                bb.Size = UDim2.new(0, 90, 0, 22)
                bb.StudsOffset = Vector3.new(0, 2.2, 0)
                bb.AlwaysOnTop = true
                bb.Parent = ball
                local tl = Instance.new("TextLabel")
                tl.Name = "Txt"
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamBold
                tl.TextSize = 14
                tl.Text = "BALON"
                tl.TextColor3 = Color3.fromRGB(255, 230, 120)
                tl.TextStrokeTransparency = 0.3
                tl.Parent = bb
        end
end

-- Hitbox expander del balon:
-- - Hace el balon TRANSPARENTE (no se ve el balon grande)
-- - Cambia ball.Size para expandir el hitbox real (netamente, sin firetouchinterest)
-- - La cupula es opcional (visible/invisible) pero el HBE sigue funcionando
-- - SIN firetouchinterest = SIN teleport
local ballOrigSize = nil
local ballOrigTransparency = nil
local function applyBallHitbox()
        local ball = findBall()
        if not ballHitboxOn then
                -- Restaurar balon original + destruir cupula
                if ball then
                        if ballOrigSize then
                                pcall(function() ball.Size = ballOrigSize end)
                        end
                        if ballOrigTransparency then
                                pcall(function() ball.Transparency = ballOrigTransparency end)
                        end
                end
                if ball and ball.Parent then
                        local cupula = ball.Parent:FindFirstChild("HLHUBHitbox")
                        if cupula then cupula:Destroy() end
                end
                ballOrigSize = nil
                ballOrigTransparency = nil
                return
        end
        if not ball or not ball.Parent then return end
        -- Guardar size y transparencia originales la primera vez
        if not ballOrigSize then
                ballOrigSize = ball.Size
                ballOrigTransparency = ball.Transparency
        end
        local mult = math.clamp(ballHitboxSize, 1, 50)
        local newSize = ballOrigSize * mult
        -- 1) Expandir el hitbox REAL del balon (cambiando Size client-side)
        pcall(function() ball.Size = newSize end)
        -- 2) Hacer el balon TRANSPARENTE (invisible) para que no se vea el balon grande
        pcall(function() ball.Transparency = 1 end)
        -- 3) Cupula visual (opcional)
        local cupula = ball.Parent:FindFirstChild("HLHUBHitbox")
        if not cupula then
                cupula = Instance.new("Part")
                cupula.Name = "HLHUBHitbox"
                cupula.Shape = Enum.PartType.Ball
                cupula.Material = Enum.Material.ForceField
                cupula.CanCollide = false
                cupula.CanTouch = false
                cupula.CanQuery = false
                cupula.Anchored = false
                cupula.Massless = true
                cupula.Size = newSize
                cupula.CFrame = ball.CFrame
                cupula.Color = Color3.fromRGB(100, 200, 255)
                cupula.Parent = ball.Parent
                local weld = Instance.new("WeldConstraint")
                weld.Name = "HLHUBHitboxWeld"
                weld.Part0 = ball
                weld.Part1 = cupula
                weld.Parent = cupula
        else
                if (cupula.Size - newSize).Magnitude > 0.1 then
                        cupula.Size = newSize
                end
                local weld = cupula:FindFirstChild("HLHUBHitboxWeld")
                if not weld or not weld.Part0 or weld.Part0 ~= ball then
                        if weld then weld:Destroy() end
                        local nw = Instance.new("WeldConstraint")
                        nw.Name = "HLHUBHitboxWeld"
                        nw.Part0 = ball
                        nw.Part1 = cupula
                        nw.Parent = cupula
                end
        end
        -- Cupula visible o invisible segun la opcion
        cupula.Transparency = cupulaVisible and 0.5 or 1
end

local function lockGoal()
        local hrp = getHRP()
        if hrp then gkPos = hrp.Position end
        lastGkSave = nil
end

local function applyGK()
        if not gkOn then return end
        local waitT = 0.05
        if tick() - lastGK < waitT then return end
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum or hum.Health <= 0 then return end
        if not gkPos then lockGoal() end
        if not gkPos then return end
        if (hrp.Position - gkPos).Magnitude > 28 then return end

        if tick() - ballScan > 0.25 then
                ballScan = tick()
                cachedBall = nil
        end
        local ball = findBall()
        if not ball then return end
        if ball.Parent and ball.Parent:FindFirstChildOfClass("Humanoid") then return end

        local vel = ball.AssemblyLinearVelocity
        local spd = vel.Magnitude
        local minSpd = 20
        if spd < minSpd then return end

        local zGoal = math.abs(gkPos.Z) >= math.abs(gkPos.X)
        local t
        if zGoal then
                if math.abs(vel.Z) < 2 then return end
                t = (gkPos.Z - ball.Position.Z) / vel.Z
        else
                if math.abs(vel.X) < 2 then return end
                t = (gkPos.X - ball.Position.X) / vel.X
        end
        if t < 0.06 or t > 1.6 then return end

        local toGoal = gkPos - ball.Position
        if toGoal.Magnitude < 1 then return end
        local aim = vel.Unit:Dot(toGoal.Unit)
        local minAim = 0.22
        if aim < minAim then return end

        local pred = ball.Position + vel * t
        local reach = 18  -- Aumentado para cubrir todo el arco (era 10)
        local save
        if zGoal then
                save = Vector3.new(
                        math.clamp(pred.X, gkPos.X - reach, gkPos.X + reach),
                        hrp.Position.Y,
                        gkPos.Z
                )
        else
                save = Vector3.new(
                        gkPos.X,
                        hrp.Position.Y,
                        math.clamp(pred.Z, gkPos.Z - reach, gkPos.Z + reach)
                )
        end
        if lastGkSave and (save - lastGkSave).Magnitude < 0.9 then
                save = lastGkSave
        else
                lastGkSave = save
        end
        local cur = hrp.Position
        local delta = save - cur
        if delta.Magnitude < 0.7 then return end
        lastGK = tick()
        local step = 0.35  -- Mas agresivo (era 0.62)
        local maxStep = 2.4  -- Mas rapido para llegar a esquinas (era 3.4)
        local move = delta * step
        if move.Magnitude > maxStep then
                move = move.Unit * maxStep
        end
        local nxt = cur + move
        if zGoal then
                nxt = Vector3.new(nxt.X, hrp.Position.Y, gkPos.Z)
        else
                nxt = Vector3.new(gkPos.X, hrp.Position.Y, nxt.Z)
        end
        local face
        if zGoal then
                face = Vector3.new(nxt.X, nxt.Y, nxt.Z + (gkPos.Z >= 0 and -4 or 4))
        else
                face = Vector3.new(nxt.X + (gkPos.X >= 0 and -4 or 4), nxt.Y, nxt.Z)
        end
        hrp.CFrame = CFrame.new(nxt, face)
        local predY = pred.Y
        -- NUEVO: NO saltar nunca. La dive se ve mas natural que el salto.
        -- El salto causaba que se levantara en tiros rasos y no tapaba.
        -- local high = predY >= 7.0
        -- local raso = predY < 4.0
        -- if t < 0.55 and high and not raso then
        --         pcall(function() hum.Jump = true end)
        -- end
        -- Dive automatica para TODOS los tiros (no solo cercanos), se ve natural
        if t < 1.2 and tick() - lastDive > 0.3 then
                lastDive = tick()
                if not diveRem or not diveRem.Parent then
                        diveRem = knitRE("BallService", "Dive") 
                                or knitRE("BallService", "GKDive") 
                                or knitRE("AbilityService", "Dive")
                                or knitRE("BallService", "GoalkeeperDive")
                                or knitRE("BallService", "DiveLeft")
                                or knitRE("BallService", "DiveRight")
                end
                if diveRem then
                        pcall(function() diveRem:FireServer() end)
                end
        end
end

local function isYellow(c)
        return c.R > 0.65 and c.G > 0.55 and c.B < 0.45
end

local function isPredName(obj)
        local n = string.lower(obj.Name or "")
        local p = obj.Parent and string.lower(obj.Parent.Name) or ""
        return n:find("indicador") or n:find("predic") or n:find("prediction")
                or p:find("indicador") or p:find("predic") or p:find("prediction")
end

local function clearGkVision()
        for obj, old in pairs(hiddenCyl) do
                if obj and obj.Parent then
                        pcall(function()
                                if obj:IsA("BasePart") then
                                        obj.LocalTransparencyModifier = 0
                                        if old and old.t then obj.Transparency = old.t end
                                elseif obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("ParticleEmitter") or obj:IsA("Highlight") or obj:IsA("BillboardGui") then
                                        obj.Enabled = true
                                end
                        end)
                end
        end
        hiddenCyl = {}
end

local function hideYellowCyl(obj)
        if hiddenCyl[obj] then return end
        local old = {}
        pcall(function()
                if obj:IsA("BasePart") then
                        old.t = obj.Transparency
                        obj.LocalTransparencyModifier = 1
                        obj.Transparency = 1
                elseif obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("ParticleEmitter") or obj:IsA("Highlight") then
                        obj.Enabled = false
                elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                        obj.Enabled = false
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                        old.t = obj.Transparency
                        obj.Transparency = 1
                end
        end)
        hiddenCyl[obj] = old
end

local function scanRoot(root)
        if not root then return end
        for _, obj in ipairs(root:GetDescendants()) do
                local named = isPredName(obj)
                if named then
                        hideYellowCyl(obj)
                        if obj:IsA("Model") or obj:IsA("Folder") then
                                for _, d in ipairs(obj:GetDescendants()) do
                                        hideYellowCyl(d)
                                end
                        end
                elseif obj:IsA("BasePart") then
                        local yellow = isYellow(obj.Color)
                        local cyl = obj.Shape == Enum.PartType.Cylinder
                        if cyl and yellow then hideYellowCyl(obj) end
                end
        end
end

local function applyGkVision()
        if not gkVisionOn then
                if next(hiddenCyl) then clearGkVision() end
                return
        end
        scanRoot(workspace)
        scanRoot(workspace.CurrentCamera)
end

pcall(function()
        workspace.DescendantAdded:Connect(function(obj)
                if not gkVisionOn then return end
                if isPredName(obj) then
                        task.defer(function()
                                hideYellowCyl(obj)
                                if obj:IsA("Model") or obj:IsA("Folder") then
                                        for _, d in ipairs(obj:GetDescendants()) do hideYellowCyl(d) end
                                end
                        end)
                end
        end)
end)

local function holderOf(ball)
        local p = ball.Parent
        if p and p:FindFirstChildOfClass("Humanoid") then return p end
        for _, w in ipairs(ball:GetChildren()) do
                if w:IsA("Weld") or w:IsA("WeldConstraint") or w:IsA("Motor6D") then
                        local o = w.Part0 == ball and w.Part1 or w.Part0
                        if o and o.Parent and o.Parent:FindFirstChildOfClass("Humanoid") then
                                return o.Parent
                        end
                end
        end
        return nil
end

local slideAnimCache = nil

local function findSlideAnim()
        if slideAnimCache and slideAnimCache.Parent then return slideAnimCache end
        local function match(inst)
                if not inst then return nil end
                if inst:IsA("Animation") then
                        local n = string.lower(inst.Name)
                        if n:find("slide") or n:find("tackle") or n:find("desliz") or n:find("sweep") then
                                return inst
                        end
                end
                return nil
        end
        local roots = {
                ReplicatedStorage:FindFirstChild("Assets"),
                ReplicatedStorage:FindFirstChild("Animations"),
                ReplicatedStorage,
        }
        for _, root in ipairs(roots) do
                if root then
                        for _, d in ipairs(root:GetDescendants()) do
                                local hit = match(d)
                                if hit then
                                        slideAnimCache = hit
                                        return hit
                                end
                        end
                end
        end
        return nil
end

local function playSlideAnim(lookPos)
        local hum = getHum()
        local hrp = getHRP()
        if not hum or not hrp then return end
        pcall(function()
                if lookPos then
                        local flat = Vector3.new(lookPos.X, hrp.Position.Y, lookPos.Z)
                        hrp.CFrame = CFrame.new(hrp.Position, flat)
                end
                local animator = hum:FindFirstChildOfClass("Animator")
                local anim = findSlideAnim()
                if animator and anim then
                        local t = animator:LoadAnimation(anim)
                        t.Priority = Enum.AnimationPriority.Action4
                        t:Play()
                        task.delay(0.75, function()
                                pcall(function() t:Stop() end)
                        end)
                end
        end)
end

local function applySlide()
        if not slideOn then return end
        if tick() - lastSlide < 0.45 then return end
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum or hum.Health <= 0 then return end
        local ball = findBall()
        if not ball then return end
        local mine = player.Character
        local who = holderOf(ball)
        if who and who == mine then return end
        local dist = (hrp.Position - ball.Position).Magnitude
        if dist > SLIDE then return end
        if not slideRem or not slideRem.Parent then
                slideRem = knitRE("BallService", "Slide")
        end
        if not slideRem then return end
        lastSlide = tick()
        playSlideAnim(ball.Position)
        pcall(function() slideRem:FireServer() end)
end

local function hasBall()
        local char = player.Character
        if not char then return false end
        local vals = char:FindFirstChild("Values")
        local hb = vals and vals:FindFirstChild("HasBall")
        if hb and hb.Value == true then return true end
        local ball = findBall()
        return ball ~= nil and holderOf(ball) == char
end

local function incomingSlide(hrp)
        for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Team and player.Team and p.Team ~= player.Team and p.Character then
                        local ehrp = p.Character:FindFirstChild("HumanoidRootPart")
                        local ehum = p.Character:FindFirstChildOfClass("Humanoid")
                        if ehrp and ehum then
                                local d = (ehrp.Position - hrp.Position).Magnitude
                                if d <= DRIB then
                                        local toward = (hrp.Position - ehrp.Position)
                                        local ev = ehrp.AssemblyLinearVelocity
                                        if toward.Magnitude > 0.2 and ev.Magnitude > 1 then
                                                local coming = ev.Unit:Dot(toward.Unit)
                                                local fast = ev.Magnitude > 14
                                                local sliding = false
                                                for _, t in ipairs(ehum:GetPlayingAnimationTracks()) do
                                                        local n = string.lower(t.Name)
                                                        if n:find("slide") or n:find("tackle") or n:find("desliz") then
                                                                sliding = true
                                                                break
                                                        end
                                                end
                                                if sliding or (fast and coming > 0.35) then
                                                        return true
                                                end
                                        end
                                end
                        end
                end
        end
        return false
end

local function applyDribble()
        if not dribOn then return end
        if tick() - lastDrib < 0.55 then return end
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum or hum.Health <= 0 then return end
        if not hasBall() then return end
        if not incomingSlide(hrp) then return end
        if not dribRem or not dribRem.Parent then
                dribRem = knitRE("BallService", "Dribble")
        end
        if not dribRem then return end
        lastDrib = tick()
        pcall(function() dribRem:FireServer() end)
end


local function nearestMate()
        local hrp = getHRP()
        if not hrp then return nil end
        local best, bd = nil, 70
        for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Team and player.Team and plr.Team == player.Team then
                        local ch = plr.Character
                        local t = ch and ch:FindFirstChild("HumanoidRootPart")
                        if t then
                                local d = (t.Position - hrp.Position).Magnitude
                                if d > 5 and d < bd then
                                        best, bd = t, d
                                end
                        end
                end
        end
        return best
end

local function applyPass()
        if not passOn then return end
        if tick() - lastPass < 0.75 then return end
        if not hasBall() then return end
        local mate = nearestMate()
        if not mate then return end
        if not passRem or not passRem.Parent then
                passRem = knitRE("BallService", "Pass")
        end
        if not passRem then return end
        local hrp = getHRP()
        if not hrp then return end
        lastPass = tick()
        local look = Vector3.new(mate.Position.X, hrp.Position.Y, mate.Position.Z)
        pcall(function() hrp.CFrame = CFrame.new(hrp.Position, look) end)
        pcall(function() passRem:FireServer() end)
end

local function powerShot()
        if tick() - lastShot < 0.28 then return false end
        if not hasBall() then return false end
        if not shootRem or not shootRem.Parent then
                shootRem = knitRE("BallService", "Shoot") or knitRE("BallService", "Kick") or knitRE("BallService", "Shot")
        end
        if not shootRem then return false end
        local cam = workspace.CurrentCamera
        local hrp = getHRP()
        local dir = (cam and cam.CFrame.LookVector) or (hrp and hrp.CFrame.LookVector)
        if not dir then return false end
        lastShot = tick()
        POWER = math.clamp(math.floor(tonumber(POWER) or 80), 1, 200)
        pcall(function() shootRem:FireServer(POWER) end)
        pcall(function() shootRem:FireServer(POWER, dir) end)
        pcall(function() shootRem:FireServer(POWER, nil, nil, dir) end)
        return true
end

local function tapIsHub(pos)
        local pg = player:FindFirstChild("PlayerGui")
        local hub = pg and pg:FindFirstChild("ScreenGui1")
        if not pg or not hub or not pos then return false end
        local ok, objs = pcall(function()
                return pg:GetGuiObjectsAtPosition(pos.X, pos.Y)
        end)
        if not ok or not objs then return false end
        for _, o in ipairs(objs) do
                if o:IsDescendantOf(hub) then return true end
        end
        return false
end

local powerHoldAt = 0
local powerCharging = false
local powerInput = nil

local function isShootGui(pos)
        local pg = player:FindFirstChild("PlayerGui")
        if not pg or not pos then return false end
        local ok, objs = pcall(function()
                return pg:GetGuiObjectsAtPosition(pos.X, pos.Y)
        end)
        if not ok or not objs then return false end
        for _, o in ipairs(objs) do
                local n = string.lower(o.Name)
                local txt = ""
                pcall(function() txt = string.lower(o.Text or "") end)
                if n:find("shoot") or n:find("shot") or n:find("kick") or n:find("tiro") or n:find("strike") or n:find("power") or n:find("charge") then
                        return true
                end
                if txt:find("shoot") or txt:find("tiro") or txt:find("kick") then
                        return true
                end
        end
        return false
end

local function isShootInput(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then return true end
        if i.UserInputType == Enum.UserInputType.Touch then
                if isShootGui(i.Position) then return true end
                local cam = workspace.CurrentCamera
                local vx = cam and cam.ViewportSize.X or 0
                if vx > 0 and i.Position.X > vx * 0.55 and not tapIsHub(i.Position) then
                        return true
                end
        end
        return false
end

UIS.InputBegan:Connect(function(i)
        if not powerOn then return end
        if tapIsHub(i.Position) then return end
        if not isShootInput(i) then return end
        powerCharging = true
        powerInput = i
        powerHoldAt = tick()
end)

UIS.InputEnded:Connect(function(i)
        if not powerOn or not powerCharging then return end
        if powerInput and i ~= powerInput then return end
        powerCharging = false
        powerInput = nil
        if tick() - powerHoldAt < 0.12 then return end
        powerShot()
end)

UIS.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local k = i.KeyCode.Name
        if k == hubBind then
                if toggleHubFn then toggleHubFn() end
                return
        end
        if k == powerBind then
                powerOn = not powerOn
        end
end)

player.CharacterAdded:Connect(function(c)
        local hum = c:WaitForChild("Humanoid")
        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if speedOn and hum.WalkSpeed ~= SPEED then hum.WalkSpeed = SPEED end
        end)
        task.wait(0.15)
        applySpeed()
        if gkOn then lockGoal() end
end)

pcall(function() RunService:UnbindFromRenderStep("HLHUBSpeed") end)
RunService:BindToRenderStep("HLHUBSpeed", Enum.RenderPriority.Camera.Value, function()
        if speedOn then applySpeed() end
        if gkOn then applyGK() end
end)

RunService.Heartbeat:Connect(function()
        frames += 1
        if tick() - fpsT >= 1 then
                fps = frames
                frames = 0
                fpsT = tick()
                if fpsLbl and fpsLbl.Parent then fpsLbl.Text = "FPS: " .. tostring(fps) end
                if pingLbl and pingLbl.Parent then
                        local ping = 0
                        pcall(function() ping = math.floor(player:GetNetworkPing() * 1000 + 0.5) end)
                        pingLbl.Text = "F3  Ping: " .. tostring(ping) .. " ms"
                end
        end
        if stamOn and tick() - stamTick > 0.2 then
                stamTick = tick()
                fillStamina()
        end
        if slideOn then applySlide() end
        if dribOn then applyDribble() end
        if passOn then applyPass() end
        if afkOn then applyAfk() end
        if noCdOn and tick() - lastCd > 0.45 then
                lastCd = tick()
                fillNoCd()
        end
        if tick() - lastEsp > 0.7 then
                lastEsp = tick()
                applyStyleEsp()
                applyEnemyEsp()
                applyBallEsp()
        end
        if tick() - lastBallHitbox > 0.3 then
                lastBallHitbox = tick()
                applyBallHitbox()
        end
        if tick() - lastVis > 0.4 then
                lastVis = tick()
                applyGkVision()
        end
end)



local function startHub()
        local old = player.PlayerGui:FindFirstChild("ScreenGui1")
        if old then old:Destroy() end
        local gui = Instance.new("ScreenGui")
        gui.Name = "ScreenGui1"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = player:WaitForChild("PlayerGui")

        local win = Instance.new("Frame")
        win.Size = UDim2.new(0, 400, 0, 320)
        win.Position = UDim2.new(0.5, -200, 0.14, 0)
        win.BackgroundColor3 = C.bg
        win.BorderSizePixel = 0
        win.Parent = gui
        Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)

        local top = Instance.new("TextButton")
        top.Size = UDim2.new(1, 0, 0, 38)
        top.BackgroundColor3 = C.top
        top.BorderSizePixel = 0
        top.Text = ""
        top.AutoButtonColor = false
        top.Parent = win
        Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)

        local logo = Instance.new("TextLabel")
        logo.Size = UDim2.new(0, 24, 0, 24)
        logo.Position = UDim2.new(0, 10, 0.5, -12)
        logo.BackgroundColor3 = Color3.fromRGB(18, 28, 48)
        logo.BorderSizePixel = 0
        logo.Text = "H"
        logo.TextColor3 = Color3.fromRGB(220, 235, 255)
        logo.Font = Enum.Font.GothamBold
        logo.TextSize = 15
        logo.Parent = top
        Instance.new("UICorner", logo).CornerRadius = UDim.new(1, 0)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -120, 1, 0)
        title.Position = UDim2.new(0, 40, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "HLHUB  -  PREMIUM   v1.5"
        title.TextColor3 = C.text
        title.Font = Enum.Font.GothamBold
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = top

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 22, 0, 20)
        closeBtn.Position = UDim2.new(1, -28, 0.5, -10)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Text = "X"
        closeBtn.TextColor3 = C.text
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.Parent = top
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

        local miniBtn = Instance.new("TextButton")
        miniBtn.Size = UDim2.new(0, 22, 0, 20)
        miniBtn.Position = UDim2.new(1, -50, 0.5, -10)
        miniBtn.BackgroundTransparency = 1
        miniBtn.Text = "-"
        miniBtn.TextColor3 = C.text
        miniBtn.Font = Enum.Font.GothamBold
        miniBtn.TextSize = 16
        miniBtn.Parent = top
        Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1, 0)

        local side = Instance.new("Frame")
        side.Size = UDim2.new(0, 118, 1, -38)
        side.Position = UDim2.new(0, 0, 0, 38)
        side.BackgroundColor3 = C.side
        side.BorderSizePixel = 0
        side.Parent = win

        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -128, 1, -48)
        content.Position = UDim2.new(0, 122, 0, 44)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 4
        content.CanvasSize = UDim2.new(0, 0, 0, 620)
        content.Parent = win

        local hBtn = Instance.new("TextButton")
        hBtn.Size = UDim2.new(0, 44, 0, 44)
        hBtn.Position = UDim2.new(0, 12, 0.55, 0)
        hBtn.BackgroundColor3 = Color3.fromRGB(18, 28, 48)
        hBtn.BorderSizePixel = 0
        hBtn.Text = "H"
        hBtn.TextColor3 = Color3.fromRGB(220, 235, 255)
        hBtn.Font = Enum.Font.GothamBold
        hBtn.TextSize = 20
        hBtn.Visible = false
        hBtn.Active = true
        hBtn.Parent = gui
        Instance.new("UICorner", hBtn).CornerRadius = UDim.new(1, 0)
        Instance.new("UIStroke", hBtn).Color = Color3.fromRGB(70, 150, 255)

        local dragging, startIn, startPos, hDrag, hStart, hPos
        top.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging, startIn, startPos = true, i.Position, win.Position
                end
        end)
        hBtn.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        hDrag, hStart, hPos = true, i.Position, hBtn.Position
                end
        end)
        UIS.InputChanged:Connect(function(i)
                if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
                if dragging then
                        local d = i.Position - startIn
                        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
                elseif hDrag then
                        local d = i.Position - hStart
                        hBtn.Position = UDim2.new(hPos.X.Scale, hPos.X.Offset + d.X, hPos.Y.Scale, hPos.Y.Offset + d.Y)
                end
        end)
        UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging, hDrag = false, false
                end
        end)

        hBtn.Activated:Connect(function()
                win.Visible, hBtn.Visible, minimized = true, false, false
                side.Visible, content.Visible = true, true
                win.Size = UDim2.new(0, 400, 0, 320)
        end)
        closeBtn.Activated:Connect(function()
                win.Visible, hBtn.Visible = false, true
        end)
        toggleHubFn = function()
                if win.Visible then
                        win.Visible, hBtn.Visible = false, true
                else
                        win.Visible, hBtn.Visible, minimized = true, false, false
                        side.Visible, content.Visible = true, true
                        win.Size = UDim2.new(0, 400, 0, 320)
                end
        end

        local function getPing()
                local ping = 0
                pcall(function() ping = math.floor(player:GetNetworkPing() * 1000 + 0.5) end)
                return ping
        end

        local function applyFlags(on)
                local list = {
                        { "FFlagDisablePostFx", on and "true" or "false" },
                        { "FIntRenderShadowIntensity", on and "0" or "1" },
                        { "DFIntTextureQualityOverrideEnabled", on and "1" or "0" },
                        { "DFIntTextureQualityOverride", on and "0" or "3" },
                        { "FIntRenderGrassDetail", on and "0" or "1" },
                        { "FIntFRMMaxGrassDistance", on and "0" or "100" },
                        { "FIntFRMMinGrassDistance", on and "0" or "10" },
                        { "FIntRenderGrassHeight", on and "0" or "1" },
                        { "FIntDebugForceMSAASamples", on and "0" or "4" },
                        { "DFIntDebugFRMQualityLevelOverride", on and "1" or "7" },
                        { "FIntRobloxGuiBlurIntensity", on and "0" or "1" },
                }
                if setfflag then
                        for _, f in ipairs(list) do
                                pcall(function() setfflag(f[1], f[2]) end)
                        end
                end
                pcall(function()
                        if setfpscap then setfpscap(on and 60 or 0) end
                end)
        end

        local function optOn()
                local ter = workspace.Terrain
                if not savedFX then
                        savedFX = {
                                shadows = Lighting.GlobalShadows,
                                fog = Lighting.FogEnd,
                                bright = Lighting.Brightness,
                                diff = Lighting.EnvironmentDiffuseScale,
                                spec = Lighting.EnvironmentSpecularScale,
                                soft = Lighting.ShadowSoftness,
                                tech = Lighting.Technology,
                                fx = {},
                                parts = {},
                                water = {
                                        ws = ter.WaterWaveSize,
                                        sp = ter.WaterWaveSpeed,
                                        rf = ter.WaterReflectance,
                                        tr = ter.WaterTransparency,
                                },
                        }
                        for _, v in ipairs(Lighting:GetChildren()) do
                                if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then
                                        savedFX.fx[v] = v.Enabled
                                end
                        end
                end
                pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
                pcall(function()
                        local gs = UserSettings():GetService("UserGameSettings")
                        gs.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
                end)
                pcall(function()
                        Lighting.GlobalShadows = false
                        Lighting.FogEnd = 9e9
                        Lighting.Brightness = 1
                        Lighting.EnvironmentDiffuseScale = 0
                        Lighting.EnvironmentSpecularScale = 0
                        Lighting.ShadowSoftness = 0
                        Lighting.Technology = Enum.Technology.Compatibility
                end)
                pcall(function()
                        ter.WaterWaveSize = 0
                        ter.WaterWaveSpeed = 0
                        ter.WaterReflectance = 0
                        ter.WaterTransparency = 1
                        ter.Decoration = false
                end)
                for v in pairs(savedFX.fx) do
                        if v and v.Parent then pcall(function() v.Enabled = false end) end
                end
                pcall(function()
                        for _, v in ipairs(workspace:GetDescendants()) do
                                if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                                        if savedFX.parts[v] == nil then savedFX.parts[v] = v.Enabled end
                                        v.Enabled = false
                                end
                        end
                end)
                applyFlags(true)
                potatoOn = true
        end

        local function optOff()
                pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
                pcall(function()
                        UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.Automatic
                end)
                if savedFX then
                        pcall(function()
                                Lighting.GlobalShadows = savedFX.shadows
                                Lighting.FogEnd = savedFX.fog
                                Lighting.Brightness = savedFX.bright
                                Lighting.EnvironmentDiffuseScale = savedFX.diff
                                Lighting.EnvironmentSpecularScale = savedFX.spec
                                Lighting.ShadowSoftness = savedFX.soft
                                Lighting.Technology = savedFX.tech
                        end)
                        pcall(function()
                                local ter = workspace.Terrain
                                if savedFX.water then
                                        ter.WaterWaveSize = savedFX.water.ws
                                        ter.WaterWaveSpeed = savedFX.water.sp
                                        ter.WaterReflectance = savedFX.water.rf
                                        ter.WaterTransparency = savedFX.water.tr
                                end
                        end)
                        for v, on in pairs(savedFX.fx) do
                                if v and v.Parent then pcall(function() v.Enabled = on end) end
                        end
                        for v, on in pairs(savedFX.parts) do
                                if v and v.Parent then pcall(function() v.Enabled = on end) end
                        end
                end
                applyFlags(false)
                potatoOn = false
        end

        local function setStatus(t, col)
                if statusLbl then
                        statusLbl.Text = t
                        statusLbl.TextColor3 = col or C.muted
                end
        end

        local function copyText(txt, msg)
                local ok = pcall(function()
                        if setclipboard then setclipboard(txt) end
                end)
                setStatus(ok and msg or txt, ok and C.onT or Color3.fromRGB(255, 210, 120))
        end

        local function lab(parent, text, y, h, col, wrapOn)
                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1, -16, 0, h)
                l.Position = UDim2.new(0, 8, 0, y)
                l.BackgroundTransparency = 1
                l.Text = text
                l.TextColor3 = col or C.muted
                l.Font = Enum.Font.Gotham
                l.TextSize = 12
                l.TextWrapped = wrapOn or false
                l.TextXAlignment = Enum.TextXAlignment.Left
                l.TextYAlignment = Enum.TextYAlignment.Top
                l.Parent = parent
                return l
        end

        local function btn(y, text, color, fn)
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, -16, 0, 32)
                b.Position = UDim2.new(0, 8, 0, y)
                b.BackgroundColor3 = color or C.btn
                b.BorderSizePixel = 0
                b.Text = text
                b.TextColor3 = C.text
                b.Font = Enum.Font.GothamBold
                b.TextSize = 12
                b.Parent = content
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
                if fn then b.Activated:Connect(fn) end
                return b
        end

        local function clearContent()
                for _, c in ipairs(content:GetChildren()) do c:Destroy() end
                fpsLbl, pingLbl = nil, nil
        end

        local function soon(name, extra)
                lab(content, name, 4, 18, C.text)
                lab(content, "Proximamente", 28, 18, C.muted)
                if extra then lab(content, extra, 52, 48, C.muted, true) end
        end

        local renderTab
        renderTab = function(name)
                clearContent()
                statusLbl = nil
                if name == "Main" then
                        local function card(y, title, desc, fn)
                                local b = Instance.new("TextButton")
                                b.Size = UDim2.new(1, -16, 0, 72)
                                b.Position = UDim2.new(0, 8, 0, y)
                                b.BackgroundColor3 = C.glass
                                b.BackgroundTransparency = 0.35
                                b.BorderSizePixel = 0
                                b.Text = ""
                                b.AutoButtonColor = false
                                b.Parent = content
                                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
                                local t = Instance.new("TextLabel")
                                t.Size = UDim2.new(1, -20, 0, 22)
                                t.Position = UDim2.new(0, 14, 0, 12)
                                t.BackgroundTransparency = 1
                                t.Text = title
                                t.TextColor3 = C.text
                                t.Font = Enum.Font.GothamBold
                                t.TextSize = 16
                                t.TextXAlignment = Enum.TextXAlignment.Left
                                t.Parent = b
                                local d = Instance.new("TextLabel")
                                d.Size = UDim2.new(1, -20, 0, 28)
                                d.Position = UDim2.new(0, 14, 0, 36)
                                d.BackgroundTransparency = 1
                                d.Text = desc
                                d.TextColor3 = C.muted
                                d.Font = Enum.Font.Gotham
                                d.TextSize = 12
                                d.TextXAlignment = Enum.TextXAlignment.Left
                                d.TextWrapped = true
                                d.Parent = b
                                b.Activated:Connect(fn)
                        end
                        card(8, "Combat", "GK, CF / Winger y CM", function() renderTab("Combat") end)
                        card(92, "Player", "Speed, stamina, CD, AFK", function() renderTab("Multi Tools") end)
                        card(176, "Visual", "ESP style, enemigo y balon", function() renderTab("ESP") end)
                        return
                end
                if name == "Combat" then
                        btn(8, "Tool Gk", C.btn, function() renderTab("Tool Gk") end)
                        btn(48, "Tool Cf/Winger", C.btn, function() renderTab("Tool Cf/Winger") end)
                        btn(88, "Tool Cm", C.btn, function() renderTab("Tool Cm") end)
                        btn(140, "Volver", C.glass, function() renderTab("Principal") end)
                        return
                end
                if name == "Misc" then
                        btn(8, "Info", C.btn, function() renderTab("Principal") end)
                        btn(48, "Ajuste", C.btn, function() renderTab("Ajuste") end)
                        btn(100, "Volver", C.glass, function() renderTab("Principal") end)
                        return
                end
                if name == "Principal" then
                        lab(content, "User de Roblox / Discord:", 4, 16, C.text)
                        lab(content, "Bilgamesh_91 / 1515270", 22, 18, Color3.fromRGB(180, 210, 255))
                        lab(content, "Objetivo / Meta del script:", 48, 16, C.text)
                        lab(content, "HLHUB Premium. Hub de tools para Blue Lock Rivals.", 66, 40, C.muted, true)
                        lab(content, "Asociados:", 130, 16, C.text)
                        lab(content, "Proximamente", 148, 16)
                        btn(184, "Copiar Discord", C.btn, function()
                                copyText(DISCORD_ID, "Copiado: " .. DISCORD_ID)
                        end)
                        statusLbl = lab(content, "Toca para copiar 1515270", 222, 16)
                        return
                end
                if name == "Ajuste" then
                        lab(content, "Rendimiento", 4, 16, C.text)
                        fpsLbl = lab(content, "FPS: " .. tostring(fps), 24, 16, C.text)
                        pingLbl = lab(content, "F3  Ping: " .. tostring(getPing()) .. " ms", 42, 16, C.text)
                        lab(content, "Version: " .. VERSION, 68, 16, C.text)
                        local opt = btn(92, potatoOn and "Optimizar graficos  ON" or "Optimizar graficos  OFF", potatoOn and C.on or C.btn, function()
                                if potatoOn then optOff() else optOn() end
                                renderTab("Ajuste")
                        end)
                        if potatoOn then opt.TextColor3 = C.onT end
                        lab(content, "Baja calidad, sombras, pasto, agua, bloom y particulas para ganar FPS.", 130, 40, C.muted, true)
                        lab(content, "Server Discord:", 168, 16, C.text)
                        lab(content, DISCORD_SERVER, 186, 18, Color3.fromRGB(180, 210, 255))
                        btn(210, "Copiar server Discord", C.btn, function()
                                copyText(DISCORD_SERVER, "Server copiado")
                        end)
                        btn(250, "Guardar config", C.btn, function()
                                saveCfg()
                                setStatus("Config guardada", C.onT)
                        end)
                        lab(content, "Keybind ocultar hub", 290, 16, C.muted)
                        local kbox = Instance.new("TextBox")
                        kbox.Size = UDim2.new(1, -16, 0, 34)
                        kbox.Position = UDim2.new(0, 8, 0, 310)
                        kbox.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
                        kbox.BorderSizePixel = 0
                        kbox.Text = hubBind
                        kbox.PlaceholderText = "RightShift"
                        kbox.TextColor3 = C.text
                        kbox.Font = Enum.Font.GothamBold
                        kbox.TextSize = 16
                        kbox.ClearTextOnFocus = false
                        kbox.Parent = content
                        Instance.new("UICorner", kbox).CornerRadius = UDim.new(0, 7)
                        kbox.FocusLost:Connect(function()
                                local name = kbox.Text:gsub("%s+", "")
                                local ok = false
                                pcall(function()
                                        ok = Enum.KeyCode[name] ~= nil
                                end)
                                if ok then
                                        hubBind = name
                                        kbox.Text = hubBind
                                else
                                        kbox.Text = hubBind
                                end
                        end)
                        statusLbl = lab(content, "Esa tecla abre y cierra la hub. En celular usa la H.", 352, 32, C.muted, true)
                        return
                end
                if name == "Multi Tools" then
                        lab(content, "Multi Tools", 4, 18, C.text)
                        btn(28, (speedOpen and "v  " or ">  ") .. "Speed Hack", C.btn, function()
                                speedOpen = not speedOpen
                                renderTab("Multi Tools")
                        end)
                        local y = 68
                        if speedOpen then
                                lab(content, "Escribe un valor de 1 a 50", y, 16, C.muted)
                                local box = Instance.new("TextBox")
                                box.Size = UDim2.new(1, -16, 0, 34)
                                box.Position = UDim2.new(0, 8, 0, y + 22)
                                box.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
                                box.BorderSizePixel = 0
                                box.Text = tostring(SPEED)
                                box.PlaceholderText = "16"
                                box.TextColor3 = C.text
                                box.Font = Enum.Font.GothamBold
                                box.TextSize = 16
                                box.ClearTextOnFocus = false
                                box.Parent = content
                                Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)
                                box.FocusLost:Connect(function()
                                        SPEED = clampSpeed(box.Text)
                                        box.Text = tostring(SPEED)
                                        applySpeed()
                                end)
                                local sw = btn(y + 64, speedOn and "Speed Hack  ON" or "Speed Hack  OFF", speedOn and C.on or C.btn, function()
                                        SPEED = clampSpeed(box.Text)
                                        speedOn = not speedOn
                                        applySpeed()
                                        renderTab("Multi Tools")
                                end)
                                if speedOn then sw.TextColor3 = C.onT end
                                btn(y + 102, "Aplicar velocidad", C.btn, function()
                                        SPEED = clampSpeed(box.Text)
                                        applySpeed()
                                        renderTab("Multi Tools")
                                end)
                                y = y + 148
                        end
                        btn(y, (stamOpen and "v  " or ">  ") .. "Inf Stamina", C.btn, function()
                                stamOpen = not stamOpen
                                renderTab("Multi Tools")
                        end)
                        local y2 = y + 40
                        if stamOpen then
                                local st = btn(y + 40, stamOn and "Inf Stamina  ON" or "Inf Stamina  OFF", stamOn and C.on or C.btn, function()
                                        stamOn = not stamOn
                                        renderTab("Multi Tools")
                                end)
                                if stamOn then st.TextColor3 = C.onT end
                                y2 = y + 80
                        end
                        btn(y2, (noCdOpen and "v  " or ">  ") .. "No CD Habilidades", C.btn, function()
                                noCdOpen = not noCdOpen
                                renderTab("Multi Tools")
                        end)
                        if noCdOpen then
                                local nc = btn(y2 + 40, noCdOn and "No CD Habilidades  ON" or "No CD Habilidades  OFF", noCdOn and C.on or C.btn, function()
                                        noCdOn = not noCdOn
                                        if noCdOn then
                                                cdHooked = false
                                                hookAbilityCd()
                                                fillNoCd()
                                        end
                                        renderTab("Multi Tools")
                                end)
                                if noCdOn then nc.TextColor3 = C.onT end
                        end
                        local y3 = y2 + (noCdOpen and 80 or 40)
                        local af = btn(y3, afkOn and "Anti AFK  ON" or "Anti AFK  OFF", afkOn and C.on or C.btn, function()
                                afkOn = not afkOn
                                lastAfk = tick()
                                renderTab("Multi Tools")
                        end)
                        if afkOn then af.TextColor3 = C.onT end
                        btn(y3 + 40, "Reset config", C.btn, function()
                                resetCfg()
                                renderTab("Multi Tools")
                        end)
                        return
                end
                if name == "Tool Gk" then
                        lab(content, "Tool Gk", 4, 18, C.text)
                        lab(content, "Cubre tiros al arco. Activalo parado en la linea y no te alejes.", 26, 40, C.muted, true)
                        local g = btn(72, gkOn and "Auto GK  ON" or "Auto GK  OFF", gkOn and C.on or C.btn, function()
                                gkOn = not gkOn
                                if gkOn then lockGoal() end
                                renderTab("Tool Gk")
                        end)
                        if gkOn then g.TextColor3 = C.onT end
                        btn(112, "Fijar linea de gol", C.btn, function()
                                lockGoal()
                                setStatus("Linea de gol guardada", C.onT)
                        end)
                        local vis = btn(154, gkVisionOn and "Ocultar cilindro  ON" or "Ocultar cilindro  OFF", gkVisionOn and C.on or C.btn, function()
                                gkVisionOn = not gkVisionOn
                                if not gkVisionOn then clearGkVision() end
                                renderTab("Tool Gk")
                        end)
                        if gkVisionOn then vis.TextColor3 = C.onT end
                        statusLbl = lab(content, "Te mueve al tiro. Tu das Dive.", 196, 32, C.muted, true)
                        return
                end
                if name == "Tool Cf/Winger" then
                        lab(content, "Tool Cf/Winger", 4, 18, C.text)
                        lab(content, "Si un rival te barre y tienes el balon, hace el regate. Solo enemigos.", 26, 40, C.muted, true)
                        lab(content, "Rango  6 - 16", 70, 16, C.muted)
                        local box = Instance.new("TextBox")
                        box.Size = UDim2.new(1, -16, 0, 34)
                        box.Position = UDim2.new(0, 8, 0, 90)
                        box.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
                        box.BorderSizePixel = 0
                        box.Text = tostring(DRIB)
                        box.PlaceholderText = "10"
                        box.TextColor3 = C.text
                        box.Font = Enum.Font.GothamBold
                        box.TextSize = 16
                        box.ClearTextOnFocus = false
                        box.Parent = content
                        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)
                        box.FocusLost:Connect(function()
                                DRIB = math.clamp(math.floor(tonumber(box.Text) or 10), 6, 16)
                                box.Text = tostring(DRIB)
                        end)
                        local dw = btn(132, dribOn and "Auto Dribble  ON" or "Auto Dribble  OFF", dribOn and C.on or C.btn, function()
                                DRIB = math.clamp(math.floor(tonumber(box.Text) or 10), 6, 16)
                                dribOn = not dribOn
                                renderTab("Tool Cf/Winger")
                        end)
                        if dribOn then dw.TextColor3 = C.onT end
                        lab(content, "Power Shot  1 - 200", 204, 16, C.muted)
                        local pbox = Instance.new("TextBox")
                        pbox.Size = UDim2.new(1, -16, 0, 34)
                        pbox.Position = UDim2.new(0, 8, 0, 224)
                        pbox.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
                        pbox.BorderSizePixel = 0
                        pbox.Text = tostring(POWER)
                        pbox.PlaceholderText = "80"
                        pbox.TextColor3 = C.text
                        pbox.Font = Enum.Font.GothamBold
                        pbox.TextSize = 16
                        pbox.ClearTextOnFocus = false
                        pbox.Parent = content
                        Instance.new("UICorner", pbox).CornerRadius = UDim.new(0, 7)
                        pbox.FocusLost:Connect(function()
                                POWER = math.clamp(math.floor(tonumber(pbox.Text) or 80), 1, 200)
                                pbox.Text = tostring(POWER)
                        end)
                        local pw = btn(266, powerOn and "Power Shot  ON" or "Power Shot  OFF", powerOn and C.on or C.btn, function()
                                POWER = math.clamp(math.floor(tonumber(pbox.Text) or 80), 1, 200)
                                pbox.Text = tostring(POWER)
                                powerOn = not powerOn
                                renderTab("Tool Cf/Winger")
                        end)
                        if powerOn then pw.TextColor3 = C.onT end
                        btn(306, "Tirar ahora", C.btn, function()
                                local ok = powerShot()
                                setStatus(ok and "Tiro enviado" or "Sin balon o sin remote Shoot", ok and C.onT or Color3.fromRGB(255, 180, 120))
                        end)
                        lab(content, "Tecla Power Shot  (ahora: " .. powerBind .. ")", 430, 16, C.muted)
                        local pk = Instance.new("TextBox")
                        pk.Size = UDim2.new(1, -16, 0, 34)
                        pk.Position = UDim2.new(0, 8, 0, 450)
                        pk.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
                        pk.BorderSizePixel = 0
                        pk.Text = powerBind
                        pk.PlaceholderText = "P"
                        pk.TextColor3 = C.text
                        pk.Font = Enum.Font.GothamBold
                        pk.TextSize = 16
                        pk.ClearTextOnFocus = false
                        pk.Parent = content
                        Instance.new("UICorner", pk).CornerRadius = UDim.new(0, 7)
                        pk.FocusLost:Connect(function()
                                local name = pk.Text:gsub("%s+", "")
                                local ok = false
                                pcall(function() ok = Enum.KeyCode[name] ~= nil end)
                                if ok then powerBind = name end
                                pk.Text = powerBind
                        end)
                        lab(content, "ON: carga y suelta. O usa Tirar ahora si tienes el balon.", 346, 32, C.muted, true)
                        local pp = btn(494, passOn and "Auto Pase  ON" or "Auto Pase  OFF", passOn and C.on or C.btn, function()
                                passOn = not passOn
                                renderTab("Tool Cf/Winger")
                        end)
                        if passOn then pp.TextColor3 = C.onT end
                        statusLbl = lab(content, "Pase del juego (M2 / Pase) al compaÃ±ero mas cercano.", 536, 32, C.muted, true)
                        return
                end
                if name == "ESP" then
                        lab(content, "ESP", 4, 18, C.text)
                        lab(content, "Style en la cabeza. Enemigo: highlight rojo del otro equipo.", 26, 36, C.muted, true)
                        local se = btn(72, styleEspOn and "ESP Style  ON" or "ESP Style  OFF", styleEspOn and C.on or C.btn, function()
                                styleEspOn = not styleEspOn
                                applyStyleEsp()
                                saveCfg()
                                renderTab("ESP")
                        end)
                        if styleEspOn then se.TextColor3 = C.onT end
                        local ee = btn(112, enemyEspOn and "ESP Enemigo  ON" or "ESP Enemigo  OFF", enemyEspOn and C.on or C.btn, function()
                                enemyEspOn = not enemyEspOn
                                applyEnemyEsp()
                                saveCfg()
                                renderTab("ESP")
                        end)
                        if enemyEspOn then ee.TextColor3 = C.onT end
                        local be = btn(152, ballEspOn and "ESP Balon  ON" or "ESP Balon  OFF", ballEspOn and C.on or C.btn, function()
                                ballEspOn = not ballEspOn
                                applyBallEsp()
                                saveCfg()
                                renderTab("ESP")
                        end)
                        if ballEspOn then be.TextColor3 = C.onT end
                        lab(content, "Balon en amarillo aunque este atras de paredes.", 192, 32, C.muted, true)
                        -- Hitbox Expander del Balon (balon transparente + cupula opcional)
                        lab(content, "Hitbox Balon", 230, 18, C.text)
                        lab(content, "Balon invisible + hitbox expandido. Cupula opcional. 1x - 50x. SIN teleport.", 250, 36, C.muted, true)
                        lab(content, "Tamano cupula (1 - 50)", 286, 16, C.muted)
                        local hbox = Instance.new("TextBox")
                        hbox.Size = UDim2.new(1, -16, 0, 34)
                        hbox.Position = UDim2.new(0, 8, 0, 306)
                        hbox.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
                        hbox.BorderSizePixel = 0
                        hbox.Text = tostring(ballHitboxSize)
                        hbox.PlaceholderText = "2"
                        hbox.TextColor3 = C.text
                        hbox.Font = Enum.Font.GothamBold
                        hbox.TextSize = 16
                        hbox.ClearTextOnFocus = false
                        hbox.Parent = content
                        Instance.new("UICorner", hbox).CornerRadius = UDim.new(0, 7)
                        hbox.FocusLost:Connect(function()
                                ballHitboxSize = math.clamp(tonumber(hbox.Text) or 2, 1, 50)
                                hbox.Text = tostring(ballHitboxSize)
                                applyBallHitbox()
                        end)
                        local hb = btn(348, ballHitboxOn and "Hitbox Balon  ON" or "Hitbox Balon  OFF", ballHitboxOn and C.on or C.btn, function()
                                ballHitboxSize = math.clamp(tonumber(hbox.Text) or 2, 1, 50)
                                hbox.Text = tostring(ballHitboxSize)
                                ballHitboxOn = not ballHitboxOn
                                if not ballHitboxOn then applyBallHitbox() end
                                renderTab("ESP")
                        end)
                        if ballHitboxOn then hb.TextColor3 = C.onT end
                        local cv = btn(428, cupulaVisible and "Cupula Visible  ON" or "Cupula Visible  OFF", cupulaVisible and C.on or C.btn, function()
                                cupulaVisible = not cupulaVisible
                                applyBallHitbox()
                                renderTab("ESP")
                        end)
                        if cupulaVisible then cv.TextColor3 = C.onT end
                        statusLbl = lab(content, ballHitboxOn and ("Hitbox x" .. tostring(ballHitboxSize)) or "Hitbox apagado", 468, 20, C.muted)
                        return
                end
                if name == "Tool Cm" then
                        lab(content, "Tool Cm", 4, 18, C.text)
                        lab(content, "Barre cerca del balon y reproduce la animacion de slide del juego.", 26, 40, C.muted, true)
                        lab(content, "Rango  4 - 18", 70, 16, C.muted)
                        local box = Instance.new("TextBox")
                        box.Size = UDim2.new(1, -16, 0, 34)
                        box.Position = UDim2.new(0, 8, 0, 90)
                        box.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
                        box.BorderSizePixel = 0
                        box.Text = tostring(SLIDE)
                        box.PlaceholderText = "10"
                        box.TextColor3 = C.text
                        box.Font = Enum.Font.GothamBold
                        box.TextSize = 16
                        box.ClearTextOnFocus = false
                        box.Parent = content
                        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)
                        box.FocusLost:Connect(function()
                                SLIDE = math.clamp(math.floor(tonumber(box.Text) or 10), 4, 18)
                                box.Text = tostring(SLIDE)
                        end)
                        local sw = btn(132, slideOn and "Aura Slide  ON" or "Aura Slide  OFF", slideOn and C.on or C.btn, function()
                                SLIDE = math.clamp(math.floor(tonumber(box.Text) or 10), 4, 18)
                                slideOn = not slideOn
                                renderTab("Tool Cm")
                        end)
                        if slideOn then sw.TextColor3 = C.onT end
                        statusLbl = lab(content, slideOn and ("Rango " .. tostring(SLIDE)) or "Aura Slide apagado", 172, 20, C.muted)
                        return
                end
                soon(name)
        end

        local tabBtns = {}
        local function makeTab(name, y)
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, -8, 0, 28)
                b.Position = UDim2.new(0, 4, 0, y)
                b.BackgroundColor3 = Color3.fromRGB(18, 24, 36)
                b.BorderSizePixel = 0
                b.Text = "  " .. name
                b.TextColor3 = C.muted
                b.Font = Enum.Font.Gotham
                b.TextSize = 11
                b.TextXAlignment = Enum.TextXAlignment.Left
                b.Parent = side
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
                local mark = Instance.new("Frame")
                mark.Name = "Mark"
                mark.Size = UDim2.new(0, 3, 0.7, 0)
                mark.Position = UDim2.new(0, 0, 0.15, 0)
                mark.BackgroundColor3 = C.line
                mark.BorderSizePixel = 0
                mark.Visible = false
                mark.Parent = b
                tabBtns[name] = b
                b.Activated:Connect(function()
                        for n, btnx in pairs(tabBtns) do
                                btnx.TextColor3 = (n == name) and C.text or C.muted
                                btnx.Mark.Visible = (n == name)
                        end
                        renderTab(name)
                end)
        end

        makeTab("Principal", 8)
        makeTab("Tool Gk", 40)
        makeTab("Tool Cf/Winger", 72)
        makeTab("Tool Cm", 104)
        makeTab("Multi Tools", 136)
        makeTab("ESP", 168)
        makeTab("Ajuste", 200)
        tabBtns.Principal.TextColor3 = C.text
        tabBtns.Principal.Mark.Visible = true

        miniBtn.Activated:Connect(function()
                minimized = not minimized
                side.Visible = not minimized
                content.Visible = not minimized
                win.Size = minimized and UDim2.new(0, 400, 0, 38) or UDim2.new(0, 400, 0, 320)
        end)

        renderTab("Principal")
        if potatoOn then optOn() end
        if noCdOn then hookAbilityCd() end
end

local function showKey()
        local old = player.PlayerGui:FindFirstChild("ScreenGui2")
        if old then old:Destroy() end
        local lock = Instance.new("ScreenGui")
        lock.Name = "ScreenGui2"
        lock.ResetOnSpawn = false
        lock.IgnoreGuiInset = true
        lock.Parent = player:WaitForChild("PlayerGui")
        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 260, 0, 150)
        box.Position = UDim2.new(0.5, -130, 0.38, 0)
        box.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
        box.BorderSizePixel = 0
        box.Parent = lock
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -16, 0, 24)
        t.Position = UDim2.new(0, 8, 0, 10)
        t.BackgroundTransparency = 1
        t.Text = "HLHUB Premium  â¢  Key"
        t.TextColor3 = Color3.fromRGB(230, 236, 255)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 14
        t.Parent = box
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.86, 0, 0, 32)
        input.Position = UDim2.new(0.07, 0, 0.38, 0)
        input.PlaceholderText = "Ingresa la key"
        input.Text = ""
        input.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
        input.TextColor3 = Color3.fromRGB(230, 236, 255)
        input.Font = Enum.Font.Gotham
        input.TextSize = 14
        input.ClearTextOnFocus = false
        input.Parent = box
        Instance.new("UICorner", input).CornerRadius = UDim.new(0, 7)
        local go = Instance.new("TextButton")
        go.Size = UDim2.new(0.86, 0, 0, 32)
        go.Position = UDim2.new(0.07, 0, 0.68, 0)
        go.Text = "Entrar"
        go.BackgroundColor3 = Color3.fromRGB(40, 70, 120)
        go.TextColor3 = Color3.fromRGB(255, 255, 255)
        go.Font = Enum.Font.GothamBold
        go.TextSize = 14
        go.Parent = box
        Instance.new("UICorner", go).CornerRadius = UDim.new(0, 7)
        local function tryKey()
                if keyOk(input.Text) then
                        guardarKey()
                        lock:Destroy()
                        startHub()
                else
                        go.Text = "Key mala"
                        task.delay(1, function()
                                if go and go.Parent then go.Text = "Entrar" end
                        end)
                end
        end
        go.Activated:Connect(tryKey)
        input.FocusLost:Connect(function(enter)
                if enter then tryKey() end
        end)
end

pcall(loadCfg)

if yaEntro() then
        startHub()
else
        showKey()
end
