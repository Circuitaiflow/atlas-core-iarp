pcall(function() if setfflag then setfflag("GameDisablePauseOnFocusLost","True") end end)
local GuiService=game:GetService("GuiService")
local StarterGui=game:GetService("StarterGui")
pcall(function() StarterGui:SetCore("ResetButtonCallback",false) end)
pcall(function() GuiService.MenuIsOpen=false end)
GuiService.MenuOpened:Connect(function() GuiService.MenuIsOpen=false end)
pcall(function() StarterGui:SetCore("TopbarEnabled",false) end)
local Fluent=loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local Workspace=game:GetService("Workspace")
local LocalPlayer=Players.LocalPlayer
local Window=Fluent:CreateWindow({Title="KSR - Troll Hug",SubTitle="enjoy papi",TabWidth=160,Size=UDim2.fromOffset(580,460),Acrylic=true,Theme="Dark",MinimizeKey=Enum.KeyCode.LeftControl})
local Tabs={Teleports=Window:AddTab({Title="Teleports",Icon="map-pin"}),Hitbox=Window:AddTab({Title="Hitbox",Icon="box"}),ESP=Window:AddTab({Title="ESP",Icon="eye"}),Misc=Window:AddTab({Title="Misc",Icon="settings"}),Settings=Window:AddTab({Title="Settings",Icon="palette"})}
local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getHRP() local char=LocalPlayer.Character return char and char:FindFirstChild("HumanoidRootPart") end
local function firePrompt(prompt) if not prompt then return end pcall(function() if fireproximityprompt then fireproximityprompt(prompt) else prompt:InputHoldBegin() task.wait(prompt.HoldDuration>0 and prompt.HoldDuration or 0.1) prompt:InputHoldEnd() end end) end
local function getNearestPrompt(maxDist) maxDist=maxDist or 60 local hrp=getHRP() if not hrp then return nil end local nearest,nearestDist=nil,maxDist for _,obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("ProximityPrompt") and obj.Enabled then local parent=obj.Parent if parent and parent:IsA("BasePart") then local dist=(parent.Position-hrp.Position).Magnitude if dist<nearestDist then nearestDist=dist nearest=obj end end end end return nearest end
local function teleportAndReturn(pos,maxDist) local hrp=getHRP() if not hrp then return end local originalCFrame=hrp.CFrame hrp.CFrame=CFrame.new(pos) task.wait(0.7) local prompt=getNearestPrompt(maxDist or 80) if prompt then firePrompt(prompt) end task.wait(0.5) local hrp2=getHRP() if hrp2 then hrp2.CFrame=originalCFrame end end
Tabs.Teleports:AddSection("Magic Carpets")
Tabs.Teleports:AddButton({Title="Get rainbow carpet",Callback=function() teleportAndReturn(Vector3.new(1,399,-105),80) end})
Tabs.Teleports:AddButton({Title="Get golden magic carpet",Callback=function() teleportAndReturn(Vector3.new(99,6,535),80) end})
Tabs.Teleports:AddSection("Outfits")
Tabs.Teleports:AddButton({Title="Teleport to outfits",Callback=function() local hrp=getHRP() if hrp then hrp.CFrame=CFrame.new(1,-21,43) end end})
Tabs.Hitbox:AddSection("Hitbox Expander")
local HitboxEnabled=false
local HitboxSize=15
local HitboxTransparency=0.7
local HitboxColor=Color3.fromRGB(255,0,0)
local hitboxConn
local originalSizes={}
local function applyHitbox(plr) if plr==LocalPlayer then return end if not HitboxEnabled then return end if plr.Character==LocalPlayer.Character then return end local char=plr.Character if not char then return end local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end if not originalSizes[plr] then originalSizes[plr]=hrp.Size end hrp.Size=Vector3.new(HitboxSize,HitboxSize,HitboxSize) hrp.Transparency=HitboxTransparency hrp.Color=HitboxColor hrp.Material=Enum.Material.ForceField end
local function resetHitbox(plr) local char=plr.Character if not char then return end local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end hrp.Size=originalSizes[plr] or Vector3.new(2,2,1) hrp.Transparency=1 originalSizes[plr]=nil end
Tabs.Hitbox:AddToggle("HitboxEnabled",{Title="Enable Hitbox Expander",Default=false,Callback=function(state) HitboxEnabled=state if state then for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer then applyHitbox(plr) end end hitboxConn=RunService.Heartbeat:Connect(function() for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer then applyHitbox(plr) end end end) else if hitboxConn then hitboxConn:Disconnect() hitboxConn=nil end for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer then resetHitbox(plr) end end end end})
Tabs.Hitbox:AddSlider("HitboxSize",{Title="Hitbox Size",Default=15,Min=1,Max=100,Rounding=1,Callback=function(val) HitboxSize=val end})
Tabs.Hitbox:AddSlider("HitboxTransparency",{Title="Hitbox Transparency",Default=0.7,Min=0,Max=1,Rounding=2,Callback=function(val) HitboxTransparency=val end})
Tabs.Hitbox:AddColorpicker("HitboxColor",{Title="Hitbox Color",Default=Color3.fromRGB(255,0,0),Callback=function(color) HitboxColor=color end})
Tabs.ESP:AddSection("Player ESP")
local ESPEnabled=false
local ESPFillColor=Color3.fromRGB(255,0,0)
local ESPOutlineColor=Color3.fromRGB(255,255,255)
local ESPFillTransparency=0.5
local ESPOutlineTransparency=0
local ESPTeamCheck=false
local espConn
local espHighlights={}
local function clearESP() for _,hl in pairs(espHighlights) do if hl and hl.Parent then hl:Destroy() end end espHighlights={} end
local function applyESP(plr) if not ESPEnabled or plr==LocalPlayer then return end if ESPTeamCheck and plr.Team==LocalPlayer.Team then return end local char=plr.Character if not char then return end local hl=espHighlights[plr] if not hl or not hl.Parent then hl=Instance.new("Highlight") hl.Name="KSR_ESP" hl.Adornee=char hl.Parent=char espHighlights[plr]=hl end hl.FillColor=ESPFillColor hl.OutlineColor=ESPOutlineColor hl.FillTransparency=ESPFillTransparency hl.OutlineTransparency=ESPOutlineTransparency hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop end
Tabs.ESP:AddToggle("ESPEnabled",{Title="Enable ESP",Default=false,Callback=function(state) ESPEnabled=state if state then for _,plr in ipairs(Players:GetPlayers()) do applyESP(plr) end espConn=RunService.Heartbeat:Connect(function() for _,plr in ipairs(Players:GetPlayers()) do applyESP(plr) end end) else if espConn then espConn:Disconnect() espConn=nil end clearESP() end end})
Tabs.ESP:AddColorpicker("ESPFillColor",{Title="Fill Color",Default=Color3.fromRGB(255,0,0),Callback=function(c) ESPFillColor=c end})
Tabs.ESP:AddColorpicker("ESPOutlineColor",{Title="Outline Color",Default=Color3.fromRGB(255,255,255),Callback=function(c) ESPOutlineColor=c end})
Tabs.ESP:AddSlider("ESPFillTransparency",{Title="Fill Transparency",Default=0.5,Min=0,Max=1,Rounding=2,Callback=function(v) ESPFillTransparency=v end})
Tabs.ESP:AddSlider("ESPOutlineTransparency",{Title="Outline Transparency",Default=0,Min=0,Max=1,Rounding=2,Callback=function(v) ESPOutlineTransparency=v end})
Tabs.ESP:AddToggle("ESPTeamCheck",{Title="Team Check",Default=false,Callback=function(s) ESPTeamCheck=s end})
Tabs.Misc:AddSection("Movement")
local WalkSpeed=16
local JumpPower=50
local function applySpeed() local char=getChar() local hum=char and char:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=WalkSpeed end end
local function applyJump() local char=getChar() local hum=char and char:FindFirstChildOfClass("Humanoid") if hum then hum.UseJumpPower=true hum.JumpPower=JumpPower end end
Tabs.Misc:AddSlider("WalkSpeed",{Title="WalkSpeed",Default=16,Min=16,Max=500,Rounding=0,Callback=function(v) WalkSpeed=v applySpeed() end})
Tabs.Misc:AddSlider("JumpPower",{Title="JumpPower",Default=50,Min=50,Max=500,Rounding=0,Callback=function(v) JumpPower=v applyJump() end})
Tabs.Misc:AddButton({Title="Reset WalkSpeed",Callback=function() WalkSpeed=16 applySpeed() end})
Tabs.Misc:AddButton({Title="Reset JumpPower",Callback=function() JumpPower=50 applyJump() end})
local InfiniteJumpEnabled=false
UserInputService.JumpRequest:Connect(function() if InfiniteJumpEnabled then local char=getChar() local hum=char and char:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
Tabs.Misc:AddToggle("InfiniteJump",{Title="Infinite Jump",Default=false,Callback=function(s) InfiniteJumpEnabled=s end})
Tabs.Misc:AddSection("Fly")
local FlyEnabled=false
local FlySpeed=50
local flyConn
local flyBV
local flyBG
local function startFly() local char=getChar() local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return end flyBV=Instance.new("BodyVelocity") flyBV.MaxForce=Vector3.new(math.huge,math.huge,math.huge) flyBV.Velocity=Vector3.zero flyBV.Parent=hrp flyBG=Instance.new("BodyGyro") flyBG.MaxTorque=Vector3.new(math.huge,math.huge,math.huge) flyBG.P=100000 flyBG.Parent=hrp local hum=char:FindFirstChildOfClass("Humanoid") if hum then hum.PlatformStand=true end flyConn=RunService.RenderStepped:Connect(function() if not FlyEnabled then return end local cam=Workspace.CurrentCamera if not cam then return end local moveDir=Vector3.zero if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir=moveDir+cam.CFrame.LookVector end if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir=moveDir-cam.CFrame.LookVector end if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir=moveDir-cam.CFrame.RightVector end if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir=moveDir+cam.CFrame.RightVector end if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir=moveDir+Vector3.new(0,1,0) end if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir=moveDir-Vector3.new(0,1,0) end if moveDir.Magnitude>0 then moveDir=moveDir.Unit*FlySpeed end if flyBV and flyBV.Parent then flyBV.Velocity=moveDir end if flyBG and flyBG.Parent then flyBG.CFrame=cam.CFrame end end) end
local function stopFly() FlyEnabled=false if flyConn then flyConn:Disconnect() flyConn=nil end if flyBV then flyBV:Destroy() flyBV=nil end if flyBG then flyBG:Destroy() flyBG=nil end local char=getChar() local hum=char and char:FindFirstChildOfClass("Humanoid") if hum then hum.PlatformStand=false end end
Tabs.Misc:AddToggle("FlyEnabled",{Title="Enable Fly",Default=false,Callback=function(state) FlyEnabled=state if state then startFly() else stopFly() end end})
Tabs.Misc:AddSlider("FlySpeed",{Title="Fly Speed",Default=50,Min=10,Max=500,Rounding=0,Callback=function(v) FlySpeed=v end})
Tabs.Misc:AddSection("Server")
Tabs.Misc:AddButton({Title="Rejoin Server",Callback=function() game:GetService("TeleportService"):Teleport(game.PlaceId,LocalPlayer) end})
Tabs.Misc:AddButton({Title="Server Hop",Callback=function() local TS=game:GetService("TeleportService") local Http=game:GetService("HttpService") local url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100" local ok,res=pcall(function() return Http:JSONDecode(game:HttpGet(url)) end) if ok and res and res.data then for _,srv in ipairs(res.data) do if srv.playing<srv.maxPlayers and srv.id~=game.JobId then pcall(function() TS:TeleportToPlaceInstance(game.PlaceId,srv.id,LocalPlayer) end) return end end end end})
Tabs.Settings:AddSection("Appearance")
Tabs.Settings:AddDropdown("ThemeDropdown",{Title="Color Theme",Values={"Dark","Darker","Light","Aqua","Amethyst","Rose","Cloud","Cloudy"},Default="Dark",Callback=function(value) Window:SetTheme(value) end})
Tabs.Settings:AddToggle("AcrylicToggle",{Title="Acrylic Blur",Default=true,Callback=function(state) Fluent:ToggleAcrylic(state) end})
Tabs.Settings:AddToggle("TransparencyToggle",{Title="Transparent Background",Default=false,Callback=function(state) Fluent:ToggleTransparency(state) end})
Fluent:Notify({Title="KSR - Troll Hug",Content="Menu loaded.",Duration=3})
