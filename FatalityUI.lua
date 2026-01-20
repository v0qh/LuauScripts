loadstring(game:HttpGet("https://raw.githubusercontent.com/ScrimzyW/games/refs/heads/main/Hub"))()

local RS,Run,Plrs,LP,UIS,Cam,Light,WS,HTTP,DebrisSvc,SoundService=game:GetService("ReplicatedStorage"),game:GetService("RunService"),game:GetService("Players"),game:GetService("Players").LocalPlayer,game:GetService("UserInputService"),workspace.CurrentCamera,game:GetService("Lighting"),workspace,game:GetService("HttpService"),game:GetService("Debris"),game:GetService("SoundService")
local defaultCameraFov=Cam and Cam.FieldOfView or 70
local Flags={
	espOn=false,
	hlOn=false,
	wepOn=false,
	invOn=false,
	dropOn=false,
	tpEnabled=false,
	debugMode=false,
	spinbotEnabled=false,
	autoShootEnabled=false,
	bhopEnabled=false,
	skelOn=false,
	freecamEnabled=false,
	hitSfxEnabled=true,
	noFlashEnabled=false,
	noSmokeEnabled=false,
	instantCrouchEnabled=false,
	walkSpeedEnabled=false,
	fastClimbEnabled=false,
	meleeRangeEnabled=false,
	fastReloadEnabled=false,
	customFovEnabled=false,
	statsBarEnabled=false,
	boxFillEnabled=false
}
local Values={
	walkSpeedValue=20,
	climbSpeedMultiplier=1,
	meleeRangeMultiplier=1,
	reloadEquipMultiplier=1,
	customFovValue=defaultCameraFov,
	boxType="2D"
}
local defaultHitSfxId="rbxassetid://8578195318"
local hitSfxId=defaultHitSfxId
local hitSfxIsCustom=false
local hitSfxCustomPath=nil
local hitSfxCustomLabel="Custom File"
local Runtime={
	tpDist=10,
	spinbotSpeed=20,
	autoShootDelay=0.15,
	autoShootFOV=20,
	lastAutoShootTime=0,
	spinbotConnection=nil,
	spinbotAutoRotate=nil,
	spinbotAlign=nil,
	spinbotAlignState=nil,
	spinbotAngle=0,
	characterController=nil,
	autoShootConnection=nil,
	bhopConnection=nil,
	collisionCapsuleHandler=nil,
	targetBox=nil,
	freecamController=nil,
	freecamRestoreTP=false,
	noSmokeConn=nil,
	flashModule=nil,
	flashOriginal=nil,
	voxelSmokeModule=nil,
	voxelSmokeOriginal=nil
}
local SA={Range=100,FOV=false,Enabled=false,ShowESP=false,ShowTracers=false,SnaplineEnabled=false,SnaplinePosition="Bottom",TeamCheck=false,NoSpread=false,NoRecoil=false,HitChance=100,TargetPart="Head",WallbangCheck=false,WallbangPower=99999}
local tracerStyleOptions={"Rainbow Flow","Prism Pulse","Split Neon","Zigzag","Sine Wave"}
local tracerStyle=tracerStyleOptions[1]
local hitSfxCacheFolder="BloxStrikeSFX"
local hitSfxPresets={
	{Name="Orb",File="orb.wav",Url="https://files.catbox.moe/5xbedm.wav"},
	{Name="Ka-Ching",File="ka-ching.wav",Url="https://files.catbox.moe/ygx4xk.wav"},
	{Name="Ding",File="flick.wav",Url="https://files.catbox.moe/hmkzek.wav"},
	{Name="Bell",File="bell.wav",Url="https://files.catbox.moe/rivy9k.wav"},
	{Name="Bass",File="basshit.wav",Url="https://files.catbox.moe/xbs73f.wav"}
}
local hitSfxPresetOptions={}
for _,preset in ipairs(hitSfxPresets)do
	table.insert(hitSfxPresetOptions,preset.Name)
end
table.insert(hitSfxPresetOptions,hitSfxCustomLabel)
pcall(function()
	local constants=require(RS.Database.Custom.Constants)
	if constants and constants.DEFAULT_CAMERA_FOV then
		defaultCameraFov=constants.DEFAULT_CAMERA_FOV
		if not Values.customFovValue or Values.customFovValue<=0 then
			Values.customFovValue=defaultCameraFov
		end
	end
end)
local themeDark=Color3.fromRGB(44,28,76)
local themeMid=Color3.fromRGB(88,56,140)
local themeLight=Color3.fromRGB(184,164,255)
local statsText=nil
local selectedWeaponName=nil
local selectedSkinName=nil
local selectedKnifeName=nil
local skinSelections={}
local knifePage=1
local KNIFE_PAGE_SIZE=8
local skinControls={}
local refreshingSkins=false
local UI={}
local IconUtil={}
local WeaponUtil={}
local SkinUtil={}
local ConfigUtil={}
local DrawObjs,DroppedWeps,SATracers,SATarget={},{},{},nil
local weaponIconCache={}
local weaponIconDataCache={}
local imageDrawingSupported=nil
local imageDrawMode=nil
local playerWeaponCache={}
local playerInventoryCache={}
local weaponTweaks=setmetatable({},{__mode="k"})
local movementHooksInstalled=false
local animHooksInstalled=false
local weaponHooksConnected=false
SAGUI,origCamSub,origCamType,tpSpringPos,tpSpringRot,tpUpdateConn,originalAlignOrientation=nil,nil,nil,nil,nil,nil,nil

local FOV=Drawing.new("Circle")
FOV.Thickness,FOV.NumSides,FOV.Radius,FOV.Filled,FOV.Color,FOV.Transparency,FOV.Visible=2,64,SA.Range,false,Color3.fromRGB(255,255,255),0.5,false

local function getTeam(p)
	local s,r=pcall(function()
		if not p.Character or not p.Character.Parent then return nil end
		local par=p.Character.Parent
		return par and par:IsA("Folder")and par.Name or nil
	end)
	return s and r or nil
end

local function isTeam(p1,p2)
	if not SA.TeamCheck then return false end
	local t1,t2=getTeam(p1),getTeam(p2)
	if not t1 or not t2 or t1==t2 then return t1==t2 end
	if(t1=="Terrorists"and t2=="Hostages")or(t1=="Hostages"and t2=="Terrorists")then return false end
	if(t1=="Counter-Terrorists"and t2=="Terrorists")or(t1=="Terrorists"and t2=="Counter-Terrorists")then return false end
	if(t1=="Counter-Terrorists"and t2=="Hostages")or(t1=="Hostages"and t2=="Counter-Terrorists")then return true end
	return false
end

local function getTeamCol(p)
	local t=getTeam(p)
	if t=="Terrorists"then return Color3.fromRGB(255,150,50)
	elseif t=="Counter-Terrorists"then return Color3.fromRGB(50,150,255)
	elseif t=="Hostages"then return Color3.fromRGB(150,255,150)end
	return Color3.fromRGB(255,255,255)
end

local slotAttributeKeys={"Slot1","Slot2","Slot3","Slot4","Slot5","Slot6"}

local function decodeJsonValue(raw)
	if type(raw)~="string"or raw==""then return nil end
	local ok,decoded=pcall(function()return HTTP:JSONDecode(raw)end)
	if ok and type(decoded)=="table"then return decoded end
	return nil
end

local function getWeaponNameFromData(data)
	if type(data)~="table"then return nil end
	local name=data.Name or data.Weapon or data.Identifier or data.Item or data.Id or data.WeaponName or data.TypeName
	if type(name)=="string"and name~=""then return name end
	return nil
end

local function getEquippedWeaponFromAttr(p)
	if not p then return nil end
	local raw=p:GetAttribute("CurrentEquipped")
	local cache=playerWeaponCache[p]
	if cache and cache.raw==raw then
		return cache.name
	end
	local name=getWeaponNameFromData(decodeJsonValue(raw))
	playerWeaponCache[p]={raw=raw,name=name}
	return name
end

local function getInventoryWeaponsFromAttr(p,excludeName)
	if not p then return {} end
	local cache=playerInventoryCache[p]
	local changed=false
	if not cache then
		cache={slots={}}
		playerInventoryCache[p]=cache
		changed=true
	end
	local equipped=getEquippedWeaponFromAttr(p)
	if cache.equipped~=equipped then
		cache.equipped=equipped
		changed=true
	end
	for _,key in ipairs(slotAttributeKeys)do
		local raw=p:GetAttribute(key)
		if cache.slots[key]~=raw then
			cache.slots[key]=raw
			changed=true
		end
	end
	if not changed and cache.list then
		if excludeName then
			local filtered={}
			for _,name in ipairs(cache.list)do
				if name~=excludeName then table.insert(filtered,name)end
			end
			return filtered
		end
		return cache.list
	end
	local namesSet={}
	if equipped then namesSet[equipped]=true end
	for _,key in ipairs(slotAttributeKeys)do
		local name=getWeaponNameFromData(decodeJsonValue(cache.slots[key]))
		if name then namesSet[name]=true end
	end
	if next(namesSet)==nil and p.Character then
		for _,tool in ipairs(p.Character:GetChildren())do
			if tool:IsA("Tool")then namesSet[tool.Name]=true end
		end
	end
	local list={}
	for name,_ in pairs(namesSet)do
		table.insert(list,name)
	end
	table.sort(list)
	cache.list=list
	if excludeName then
		local filtered={}
		for _,name in ipairs(list)do
			if name~=excludeName then table.insert(filtered,name)end
		end
		return filtered
	end
	return list
end

local function getPlayerWeaponName(p)
	local name=getEquippedWeaponFromAttr(p)
	if name then return name end
	if p.Character then
		for _,tool in ipairs(p.Character:GetChildren())do
			if tool:IsA("Tool")then return tool.Name end
		end
	end
	return"No Weapon"
end




local function createESP(p)
	if DrawObjs[p]then return end
	pcall(function()
		DrawObjs[p]={
			Box=Drawing.new("Square"),BoxFillTop=Drawing.new("Square"),BoxFillBottom=Drawing.new("Square"),
			HP=Drawing.new("Square"),HPO=Drawing.new("Square"),
			Name=Drawing.new("Text"),Dist=Drawing.new("Text"),Wep=Drawing.new("Text"),InvText=Drawing.new("Text"),WepIcon=IconUtil.newDrawingImage(),InvIcons={},InvIconData={},
			Snap=Drawing.new("Line"),BoxO=Drawing.new("Square"),SkelLines={},CornerLines={},Box3DLines={}
		}
		local d=DrawObjs[p]
		d.BoxO.Thickness,d.BoxO.Filled,d.BoxO.Color,d.BoxO.Visible=3,false,themeDark,false
		d.Box.Thickness,d.Box.Filled,d.Box.Color,d.Box.Visible=1,false,themeLight,false
		d.BoxFillTop.Thickness,d.BoxFillTop.Filled,d.BoxFillTop.Color,d.BoxFillTop.Transparency,d.BoxFillTop.Visible=1,true,themeMid,0.35,false
		d.BoxFillBottom.Thickness,d.BoxFillBottom.Filled,d.BoxFillBottom.Color,d.BoxFillBottom.Transparency,d.BoxFillBottom.Visible=1,true,themeLight,0.45,false
		d.HPO.Thickness,d.HPO.Filled,d.HPO.Color,d.HPO.Visible=1,false,Color3.fromRGB(0,0,0),false
		d.HP.Thickness,d.HP.Filled,d.HP.Color,d.HP.Visible=1,true,Color3.fromRGB(0,255,0),false
		d.Name.Center,d.Name.Outline,d.Name.Font,d.Name.Size,d.Name.Color,d.Name.Visible=true,true,2,13,themeLight,false
		d.Dist.Center,d.Dist.Outline,d.Dist.Font,d.Dist.Size,d.Dist.Color,d.Dist.Visible=true,true,2,13,themeLight,false
		d.Wep.Center,d.Wep.Outline,d.Wep.Font,d.Wep.Size,d.Wep.Color,d.Wep.Visible=true,true,2,12,themeMid,false
		d.InvText.Center,d.InvText.Outline,d.InvText.Font,d.InvText.Size,d.InvText.Color,d.InvText.Visible=true,true,2,11,themeLight,false
		d.Snap.Thickness,d.Snap.Color,d.Snap.Transparency,d.Snap.Visible=1,themeLight,0.7,false
		for i=1,6 do
			local ln=Drawing.new("Line")
			ln.Thickness,ln.Color,ln.Transparency,ln.Visible=2,Color3.fromRGB(255,255,255),1,false
			table.insert(d.SkelLines,ln)
		end
		for i=1,8 do
			local ln=Drawing.new("Line")
			ln.Thickness,ln.Color,ln.Transparency,ln.Visible=2,themeLight,1,false
			table.insert(d.CornerLines,ln)
		end
		for i=1,12 do
			local ln=Drawing.new("Line")
			ln.Thickness,ln.Color,ln.Transparency,ln.Visible=1,themeMid,1,false
			table.insert(d.Box3DLines,ln)
		end
	end)
end

local function clearSkelLines(d)
	if d and d.SkelLines then
		for _,ln in pairs(d.SkelLines)do 
			if ln then ln.Visible=false end 
		end
	end
end

local function clearCornerLines(d)
	if d and d.CornerLines then
		for _,ln in pairs(d.CornerLines)do 
			if ln then ln.Visible=false end 
		end
	end
end

local function clearBox3DLines(d)
	if d and d.Box3DLines then
		for _,ln in pairs(d.Box3DLines)do 
			if ln then ln.Visible=false end 
		end
	end
end

local function hideInvIcons(d)
	if d and d.InvIcons then
		for _,icon in pairs(d.InvIcons)do
			if icon then icon.Visible=false end
		end
	end
	if d and d.InvText then
		d.InvText.Visible=false
	end
end

local function removeESP(p)
	pcall(function()
		if DrawObjs[p]then
			clearSkelLines(DrawObjs[p])
			clearCornerLines(DrawObjs[p])
			clearBox3DLines(DrawObjs[p])
			if DrawObjs[p].InvIcons then
				for _,icon in pairs(DrawObjs[p].InvIcons)do
					if icon and icon.Remove then icon:Remove()end
				end
			end
			for k,d in pairs(DrawObjs[p])do
				if k~="SkelLines"and k~="CornerLines"and k~="Box3DLines"and d and d.Remove then d:Remove()end
			end
			DrawObjs[p]=nil
		end
		playerWeaponCache[p]=nil
		playerInventoryCache[p]=nil
	end)
end

local function hideESP(d)
	if not d then return end
	hideInvIcons(d)
	for k,v in pairs(d)do
		if k~="SkelLines"and k~="CornerLines"and k~="Box3DLines"then
			if v and v.Visible~=nil then v.Visible=false end
		end
	end
	clearSkelLines(d)
	clearCornerLines(d)
	clearBox3DLines(d)
end

local function getBoxCorners(cf,size)
	local sx,sy,sz=size.X/2,size.Y/2,size.Z/2
	return {
		cf:PointToWorldSpace(Vector3.new(-sx,-sy,-sz)),
		cf:PointToWorldSpace(Vector3.new(-sx,-sy,sz)),
		cf:PointToWorldSpace(Vector3.new(-sx,sy,-sz)),
		cf:PointToWorldSpace(Vector3.new(-sx,sy,sz)),
		cf:PointToWorldSpace(Vector3.new(sx,-sy,-sz)),
		cf:PointToWorldSpace(Vector3.new(sx,-sy,sz)),
		cf:PointToWorldSpace(Vector3.new(sx,sy,-sz)),
		cf:PointToWorldSpace(Vector3.new(sx,sy,sz))
	}
end

local box3dEdges={
	{1,2},{2,4},{4,3},{3,1},
	{5,6},{6,8},{8,7},{7,5},
	{1,5},{2,6},{3,7},{4,8}
}

local function updateESP(p)
	pcall(function()
		if not p or not p.Parent or p.Parent~=Plrs then
			if DrawObjs[p]then hideESP(DrawObjs[p])end
			return
		end
		
	if not Flags.espOn and not SA.SnaplineEnabled then
		if DrawObjs[p]then hideESP(DrawObjs[p])end
		return
	end
		
		if isTeam(LP,p)then
			if DrawObjs[p]then hideESP(DrawObjs[p])end
			return
		end
		
		local c=p.Character
		if not c or not c.Parent or not c:FindFirstChild("HumanoidRootPart")or not c:FindFirstChild("Humanoid")then
			if DrawObjs[p]then hideESP(DrawObjs[p])end
			return
		end
		
		if c.Parent.Name=="Dead"or c.Humanoid.Health<=0 then
			if DrawObjs[p]then hideESP(DrawObjs[p])end
			return
		end
		
		if not DrawObjs[p]then createESP(p)end
		
		local d=DrawObjs[p]
		local r=c.HumanoidRootPart
		local h=c.Humanoid
		local rPos,rOn=Cam:WorldToViewportPoint(r.Position)
		local hdPos=c:FindFirstChild("Head")and Cam:WorldToViewportPoint(c.Head.Position+Vector3.new(0,0.5,0))or rPos
		local lgPos=Cam:WorldToViewportPoint(r.Position-Vector3.new(0,3,0))
		
		if not rOn or rPos.Z<=0 then
			hideESP(d)
			return
		end
		
		local ht,wd=math.abs(hdPos.Y-lgPos.Y),math.abs(hdPos.Y-lgPos.Y)/2
		local bx,by=rPos.X-wd/2,hdPos.Y
		local boxColor=themeLight
		local textColor=themeLight
		local skelColor=themeMid
		local snapColor=themeMid
		
		d.Box.Visible=false
		d.BoxO.Visible=false
		d.BoxFillTop.Visible=false
		d.BoxFillBottom.Visible=false
		clearCornerLines(d)
		clearBox3DLines(d)

		if Flags.espOn then
			if Values.boxType=="2D" then
				d.BoxO.Size,d.BoxO.Position,d.BoxO.Visible=Vector2.new(wd,ht),Vector2.new(bx,by),true
				d.Box.Size,d.Box.Position,d.Box.Color,d.Box.Visible=Vector2.new(wd,ht),Vector2.new(bx,by),boxColor,true
				if Flags.boxFillEnabled then
					local halfH=ht/2
					d.BoxFillTop.Size,d.BoxFillTop.Position=Vector2.new(wd-2,halfH-1),Vector2.new(bx+1,by+1)
					d.BoxFillBottom.Size,d.BoxFillBottom.Position=Vector2.new(wd-2,halfH-1),Vector2.new(bx+1,by+halfH)
					d.BoxFillTop.Visible=true
					d.BoxFillBottom.Visible=true
				end
			elseif Values.boxType=="Corner" then
				local len=math.clamp(wd*0.25,6,20)
				local x1,y1=bx,by
				local x2,y2=bx+wd,by+ht
				local lines=d.CornerLines
				lines[1].From,lines[1].To=Vector2.new(x1,y1),Vector2.new(x1+len,y1)
				lines[2].From,lines[2].To=Vector2.new(x1,y1),Vector2.new(x1,y1+len)
				lines[3].From,lines[3].To=Vector2.new(x2-len,y1),Vector2.new(x2,y1)
				lines[4].From,lines[4].To=Vector2.new(x2,y1),Vector2.new(x2,y1+len)
				lines[5].From,lines[5].To=Vector2.new(x1,y2),Vector2.new(x1+len,y2)
				lines[6].From,lines[6].To=Vector2.new(x1,y2-len),Vector2.new(x1,y2)
				lines[7].From,lines[7].To=Vector2.new(x2-len,y2),Vector2.new(x2,y2)
				lines[8].From,lines[8].To=Vector2.new(x2,y2-len),Vector2.new(x2,y2)
				for _,ln in ipairs(lines)do
					ln.Color=boxColor
					ln.Visible=true
				end
			elseif Values.boxType=="3D" then
				local cf,size=c:GetBoundingBox()
				local corners=getBoxCorners(cf,size)
				local screen={}
				local anyOn=false
				for i=1,8 do
					local v,on=Cam:WorldToViewportPoint(corners[i])
					screen[i]={v,on}
					if on and v.Z>0 then anyOn=true end
				end
			if anyOn then
				for i,edge in ipairs(box3dEdges)do
					local a,b=edge[1],edge[2]
					local ln=d.Box3DLines[i]
					local sa,sb=screen[a],screen[b]
					if sa and sb then
						local va,oa=sa[1],sa[2]
						local vb,ob=sb[1],sb[2]
						if va and vb and oa and ob and va.Z>0 and vb.Z>0 then
							ln.From=Vector2.new(va.X,va.Y)
							ln.To=Vector2.new(vb.X,vb.Y)
							ln.Color=boxColor
							ln.Visible=true
						else
							ln.Visible=false
						end
					else
						ln.Visible=false
					end
				end
			end
			end
		end
		
		local hp=h.Health/h.MaxHealth
		local hpH=ht*hp
		if Flags.espOn then
			d.HPO.Size,d.HPO.Position,d.HPO.Visible=Vector2.new(4,ht+2),Vector2.new(bx-7,by-1),true
			d.HP.Size,d.HP.Position=Vector2.new(2,hpH),Vector2.new(bx-6,by+ht-hpH)
			d.HP.Color=hp>0.6 and Color3.fromRGB(0,255,0)or(hp>0.3 and Color3.fromRGB(255,165,0)or Color3.fromRGB(255,0,0))
			d.HP.Visible=true
		else
			d.HP.Visible=false
			d.HPO.Visible=false
		end
		
		if Flags.espOn then
			d.Name.Text,d.Name.Position,d.Name.Color,d.Name.Visible=p.Name,Vector2.new(rPos.X,by-16),textColor,true
		else
			d.Name.Visible=false
		end
		local ds=(LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))and math.floor((LP.Character.HumanoidRootPart.Position-r.Position).Magnitude)or 0
		if Flags.espOn then
			d.Dist.Text,d.Dist.Position,d.Dist.Color,d.Dist.Visible=ds.." studs",Vector2.new(rPos.X,by+ht+2),textColor,true
		else
			d.Dist.Visible=false
		end
		
		local wepName=nil
		if Flags.espOn and Flags.wepOn then
			wepName=getEquippedWeaponFromAttr(p)
			if not wepName and c then
				for _,ch in ipairs(c:GetChildren())do
					if ch:IsA("Tool")then wepName=ch.Name break end
				end
			end
			if wepName then
				local iconApplied=false
				if d.WepIcon then
					local iconSize=Vector2.new(22,22)
					local iconPos=Vector2.new(rPos.X-iconSize.X/2,by+ht+12)
					local ok,data=IconUtil.applyWeaponIcon(d.WepIcon,wepName,iconPos,iconSize,d.WepIconData)
					if ok then
						d.WepIconData=data
						iconApplied=true
					end
				end
				if iconApplied then
					d.Wep.Visible=false
				else
					if d.WepIcon then d.WepIcon.Visible=false end
					d.Wep.Text,d.Wep.Position,d.Wep.Visible=wepName,Vector2.new(rPos.X,by+ht+16),true
				end
			else
				d.Wep.Visible=false
				if d.WepIcon then d.WepIcon.Visible=false end
			end
		else
			d.Wep.Visible=false
			if d.WepIcon then d.WepIcon.Visible=false end
		end

		if Flags.espOn and Flags.invOn then
			local invList=getInventoryWeaponsFromAttr(p,wepName)
			if #invList>0 then
				local invY=by+ht+32
				hideInvIcons(d)
				if d.InvText then
					d.InvText.Text="Inv: "..table.concat(invList,", ")
					d.InvText.Position=Vector2.new(rPos.X,invY)
					d.InvText.Visible=true
				end
			else
				hideInvIcons(d)
			end
		else
			hideInvIcons(d)
		end
		
		if Flags.espOn and Flags.skelOn and d.SkelLines then
			local parts={Head="UpperTorso",UpperTorso="LowerTorso",UpperTorso="LeftUpperArm",UpperTorso="RightUpperArm",LowerTorso="LeftUpperLeg",LowerTorso="RightUpperLeg"}
			local lineIdx=1
			for pName,connTo in pairs(parts)do
				local p1,p2=c:FindFirstChild(pName),c:FindFirstChild(connTo)
				if p1 and p2 and d.SkelLines[lineIdx]then
					local pos1,on1=Cam:WorldToViewportPoint(p1.Position)
					local pos2,on2=Cam:WorldToViewportPoint(p2.Position)
					if on1 and on2 and pos1.Z>0 and pos2.Z>0 then
						d.SkelLines[lineIdx].From=Vector2.new(pos1.X,pos1.Y)
						d.SkelLines[lineIdx].To=Vector2.new(pos2.X,pos2.Y)
						d.SkelLines[lineIdx].Color=skelColor
						d.SkelLines[lineIdx].Visible=true
					else
						d.SkelLines[lineIdx].Visible=false
					end
					lineIdx=lineIdx+1
				end
			end
		else
			clearSkelLines(d)
		end
		
		if SA.SnaplineEnabled then
			local vs=Cam.ViewportSize
			local st=SA.SnaplinePosition=="Top"and Vector2.new(vs.X/2,0)or(SA.SnaplinePosition=="Middle"and Vector2.new(vs.X/2,vs.Y/2)or Vector2.new(vs.X/2,vs.Y))
			d.Snap.From,d.Snap.To,d.Snap.Color,d.Snap.Visible=st,Vector2.new(rPos.X,rPos.Y),snapColor,true
		else
			d.Snap.Visible=false
		end
	end)
end

local function createDropESP(model)
	pcall(function()
	if DroppedWeps[model]then return end
	local wepName=model:GetAttribute("Weapon")or model.Name
	DroppedWeps[model]={Box=Drawing.new("Square"),BoxO=Drawing.new("Square"),Name=Drawing.new("Text"),Dist=Drawing.new("Text"),Icon=IconUtil.newDrawingImage(),WepName=wepName}
		local d=DroppedWeps[model]
		d.BoxO.Thickness,d.BoxO.Filled,d.BoxO.Color,d.BoxO.Visible=2,false,themeDark,false
		d.Box.Thickness,d.Box.Filled,d.Box.Color,d.Box.Visible=1,false,themeLight,false
		d.Name.Center,d.Name.Outline,d.Name.Font,d.Name.Size,d.Name.Color,d.Name.Visible=true,true,2,12,themeLight,false
		d.Dist.Center,d.Dist.Outline,d.Dist.Font,d.Dist.Size,d.Dist.Color,d.Dist.Visible=true,true,2,11,themeMid,false
	end)
end

local function removeDropESP(model)
	pcall(function()
		if DroppedWeps[model]then
			for _,d in pairs(DroppedWeps[model])do if d and d.Remove then d:Remove()end end
			DroppedWeps[model]=nil
		end
	end)
end

local function updateDropESP(model)
	pcall(function()
		if not Flags.dropOn or not model or not model.Parent then
			if DroppedWeps[model]then
				for _,d in pairs(DroppedWeps[model])do if d.Visible~=nil then d.Visible=false end end
			end
			return
		end
		if not DroppedWeps[model]then createDropESP(model)end
		local d=DroppedWeps[model]
		local pos=model:GetPivot().Position
		local sPos,sOn=Cam:WorldToViewportPoint(pos)
		if not sOn or sPos.Z<=0 then
			for _,dr in pairs(d)do if dr.Visible~=nil then dr.Visible=false end end
			return
		end
		local sz=30
		d.BoxO.Size,d.BoxO.Position,d.BoxO.Visible=Vector2.new(sz+2,sz+2),Vector2.new(sPos.X-sz/2-1,sPos.Y-sz/2-1),true
		d.Box.Size,d.Box.Position,d.Box.Visible=Vector2.new(sz,sz),Vector2.new(sPos.X-sz/2,sPos.Y-sz/2),true
		local iconApplied=false
		if d.Icon then
			local iconSize=Vector2.new(24,24)
			local iconPos=Vector2.new(sPos.X-iconSize.X/2,sPos.Y-iconSize.Y/2)
			local ok,data=IconUtil.applyWeaponIcon(d.Icon,d.WepName,iconPos,iconSize,d.IconData)
			if ok then
				d.IconData=data
				iconApplied=true
			end
		end
		if iconApplied then
			d.Name.Visible=false
		else
			if d.Icon then d.Icon.Visible=false end
			d.Name.Text,d.Name.Position,d.Name.Visible=d.WepName,Vector2.new(sPos.X,sPos.Y-sz/2-12),true
		end
		local ds=(LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))and math.floor((LP.Character.HumanoidRootPart.Position-pos).Magnitude)or 0
		d.Dist.Text,d.Dist.Position,d.Dist.Visible=ds.." studs",Vector2.new(sPos.X,sPos.Y+sz/2+2),true
	end)
end

local function createSAGUI()
	if Runtime.targetBox then return {TargetBox=Runtime.targetBox} end
	Runtime.targetBox=Drawing.new("Square")
	Runtime.targetBox.Thickness=2
	Runtime.targetBox.Filled=false
	Runtime.targetBox.Color=Color3.fromRGB(255,60,60)
	Runtime.targetBox.Visible=false
	return{TargetBox=Runtime.targetBox}
end

local function getTracerParent()
	local debrisFolder=WS:FindFirstChild("Debris")
	if debrisFolder then return debrisFolder end
	return WS
end

local function destroyTracer(tr)
	if tr.Line and tr.Line.Remove then tr.Line:Remove()end
	if tr.PlusLines then
		for _,ln in ipairs(tr.PlusLines)do
			if ln and ln.Remove then ln:Remove()end
		end
	end
	if tr.Folder then tr.Folder:Destroy()end
end

local function clearSATracers()
	for i=#SATracers,1,-1 do
		destroyTracer(SATracers[i])
		table.remove(SATracers,i)
	end
end

local function normalizeSoundId(raw)
	if not raw then return "" end
	local str=tostring(raw):gsub("%s","")
	if str=="" then return "" end
	if str:find("rbxassetid://") then return str end
	if str:match("^%d+$") then return "rbxassetid://"..str end
	return str
end

local function normalizePath(path)
	return tostring(path or ""):gsub("\\","/"):lower()
end

local function getPresetFilePath(preset)
	if not preset or not preset.File then return nil end
	return hitSfxCacheFolder.."/"..preset.File
end

local function ensureHitSfxFolder()
	if type(makefolder)~="function" then return end
	if type(isfolder)=="function" and isfolder(hitSfxCacheFolder)then return end
	pcall(function() makefolder(hitSfxCacheFolder) end)
end

local function fetchUrl(url)
	if not url or url=="" then return nil end
	local ok,res
	if type(syn)=="table" and type(syn.request)=="function" then
		ok,res=pcall(function()
			return syn.request({Url=url,Method="GET"})
		end)
		if ok and res and res.Body then return res.Body end
	end
	if type(http_request)=="function" then
		ok,res=pcall(function()
			return http_request({Url=url,Method="GET"})
		end)
		if ok and res and res.Body then return res.Body end
	end
	if type(request)=="function" then
		ok,res=pcall(function()
			return request({Url=url,Method="GET"})
		end)
		if ok and res and res.Body then return res.Body end
	end
	if HTTP and type(HTTP.GetAsync)=="function" then
		ok,res=pcall(function()
			return HTTP:GetAsync(url)
		end)
		if ok and res then return res end
	end
	ok,res=pcall(function() return game:HttpGet(url) end)
	if ok and res then return res end
	return nil
end

function IconUtil.normalizeAssetId(raw)
	if not raw then return nil end
	local str=tostring(raw):gsub("%s","")
	if str=="" then return nil end
	if str:find("rbxassetid://") then return str end
	if str:match("^%d+$") then return "rbxassetid://"..str end
	return str
end

function IconUtil.extractAssetId(raw)
	if not raw then return nil end
	local num=tostring(raw):match("%d+")
	return num and tonumber(num) or nil
end

function IconUtil.canUseDrawingImage()
	if imageDrawingSupported~=nil then return imageDrawingSupported end
	if not Drawing or type(Drawing.new)~="function" then
		imageDrawingSupported=false
		return false
	end
	local ok,obj=pcall(function()return Drawing.new("Image")end)
	if ok and obj then
		pcall(function()obj.Visible=false end)
		if obj.Remove then pcall(function()obj:Remove()end)end
		imageDrawingSupported=true
		return true
	end
	imageDrawingSupported=false
	return false
end

function IconUtil.newDrawingImage()
	if not IconUtil.canUseDrawingImage() then return nil end
	local ok,obj=pcall(function()return Drawing.new("Image")end)
	if ok and obj then
		obj.Visible=false
		obj.Transparency=1
		return obj
	end
	return nil
end

function IconUtil.isAssetIdString(value)
	return type(value)=="string" and value:find("^rbxassetid://")~=nil
end

function IconUtil.setDrawingImageData(img,data,assetId)
	if not img then return false end
	if imageDrawMode==false then return false end
	local useAsset=assetId
	if not useAsset and IconUtil.isAssetIdString(data) then
		useAsset=data
		data=nil
	end
	local ok=false
	if imageDrawMode==nil then
		if data then
			ok=pcall(function()img.Data=data end)
			if ok then imageDrawMode="Data" return true end
		end
		if data then
			ok=pcall(function()img.Image=data end)
			if ok then imageDrawMode="Image" return true end
			ok=pcall(function()img.Texture=data end)
			if ok then imageDrawMode="Texture" return true end
		end
		if useAsset then
			ok=pcall(function()img.Image=useAsset end)
			if ok then imageDrawMode="Image" return true end
			ok=pcall(function()img.Texture=useAsset end)
			if ok then imageDrawMode="Texture" return true end
		end
		imageDrawMode=false
		return false
	end
	if imageDrawMode=="Data" then
		if data then
			ok=pcall(function()img.Data=data end)
		elseif useAsset then
			ok=pcall(function()img.Image=useAsset end)
			if ok then imageDrawMode="Image" return true end
			ok=pcall(function()img.Texture=useAsset end)
			if ok then imageDrawMode="Texture" return true end
		else
			return false
		end
	elseif imageDrawMode=="Image" then
		ok=pcall(function()img.Image=data or useAsset end)
	elseif imageDrawMode=="Texture" then
		ok=pcall(function()img.Texture=data or useAsset end)
	end
	if not ok and useAsset and imageDrawMode~="Data" then
		ok=pcall(function()
			if imageDrawMode=="Image" then
				img.Image=useAsset
			else
				img.Texture=useAsset
			end
		end)
	end
	return ok
end

function IconUtil.getWeaponIconAssetId(weaponName)
	if not weaponName or weaponName=="" then return nil end
	local cached=weaponIconCache[weaponName]
	if cached~=nil then
		return cached or nil
	end
	local id=nil
	local ok,props=pcall(function()
		local database=RS:FindFirstChild("Database")
		local custom=database and database:FindFirstChild("Custom")
		local weapons=custom and custom:FindFirstChild("Weapons")
		if weapons then
			local mod=weapons:FindFirstChild(weaponName)
			if mod and mod:IsA("ModuleScript") then
				return require(mod)
			end
		end
		return nil
	end)
	if ok and type(props)=="table" then
		id=props.Icon or props.ReverseIcon or props.IconId or props.Image or props.ImageId
	end
	if id then
		id=IconUtil.normalizeAssetId(id)
		weaponIconCache[weaponName]=id
		return id
	end
	weaponIconCache[weaponName]=false
	return nil
end

function IconUtil.fetchWeaponIconData(weaponName)
	if not IconUtil.canUseDrawingImage() then return nil end
	local assetId=IconUtil.getWeaponIconAssetId(weaponName)
	if not assetId then return nil end
	return assetId
end

function IconUtil.applyWeaponIcon(img,weaponName,pos,size,cachedData)
	if not img then return false,nil end
	local data=IconUtil.fetchWeaponIconData(weaponName)
	if not data then
		img.Visible=false
		return false,nil
	end
	if cachedData~=data then
		local assetId=IconUtil.getWeaponIconAssetId(weaponName)
		if not IconUtil.setDrawingImageData(img,data,assetId) then
			img.Visible=false
			return false,nil
		end
	end
	if size then img.Size=size end
	if pos then img.Position=pos end
	img.Visible=true
	return true,data
end

local function ensureLocalHitSfx(preset)
	if not preset or not preset.Url or not preset.File then return nil end
	local path=getPresetFilePath(preset)
	if not path then return nil end
	if type(isfile)=="function" and isfile(path) then return path end
	if type(writefile)~="function" then return nil end
	ensureHitSfxFolder()
	local data=fetchUrl(preset.Url)
	if not data or data=="" then return nil end
	local ok=pcall(function()
		writefile(path,data)
	end)
	if ok then return path end
	return nil
end

local function getHitSfxPresetByName(name)
	for _,preset in ipairs(hitSfxPresets)do
		if preset.Name==name then return preset end
	end
	return nil
end

local function getHitSfxPresetByPath(path)
	if not path then return nil end
	local normalized=normalizePath(path)
	for _,preset in ipairs(hitSfxPresets)do
		local filePath=getPresetFilePath(preset)
		if filePath and normalizePath(filePath)==normalized then
			return preset
		end
		if preset.File and normalizePath(preset.File)==normalized then
			return preset
		end
	end
	return nil
end

local function getHitSfxPresetNameById(id)
	local preset=getHitSfxPresetByPath(id)
	if preset then return preset.Name end
	local normalized=normalizeSoundId(id)
	for _,preset in ipairs(hitSfxPresets)do
		if preset.Id and normalizeSoundId(preset.Id)==normalized then
			return preset.Name
		end
	end
	return nil
end

local function getHitSfxPresetIdByName(name)
	local preset=getHitSfxPresetByName(name)
	if not preset then return nil end
	return ensureLocalHitSfx(preset)
end

local function setHitSfxId(raw)
	local str=tostring(raw or ""):gsub("%s","")
	local normalized=normalizeSoundId(str)
	if normalized=="" then
		hitSfxId=defaultHitSfxId
		hitSfxIsCustom=false
		hitSfxCustomPath=nil
	else
		if normalized:find("rbxassetid://") then
			hitSfxId=normalized
			hitSfxIsCustom=false
			hitSfxCustomPath=nil
		else
			hitSfxId=str
			hitSfxIsCustom=true
			hitSfxCustomPath=str
		end
	end
	if UI.hitSfxTextBox then
		local tb=UI.hitSfxTextBox:FindFirstChildOfClass("TextBox")
		if tb then tb.Text=hitSfxId end
	end
	if UI.hitSfxPresetDropdown then
		local presetName=getHitSfxPresetNameById(hitSfxId)
		if hitSfxIsCustom and not presetName then
			presetName=hitSfxCustomLabel
		end
		if presetName then UI.hitSfxPresetDropdown:SetValue(presetName)end
	end
end

local function resolveHitSfxAsset()
	local id=hitSfxId or defaultHitSfxId
	if id=="" then return defaultHitSfxId end
	if not hitSfxIsCustom then return id end
	if type(getcustomasset)~="function" then return defaultHitSfxId end
	local path=hitSfxCustomPath or id
	local preset=getHitSfxPresetByPath(path)
	if preset then
		local ensured=ensureLocalHitSfx(preset)
		if ensured then path=ensured end
	end
	local ok,asset=pcall(function()
		return getcustomasset(path)
	end)
	if ok and asset and asset~="" then return asset end
	return defaultHitSfxId
end

local function playHitSfx()
	if not Flags.hitSfxEnabled then return end
	local id=resolveHitSfxAsset()
	local s=Instance.new("Sound")
	s.SoundId=id
	s.Volume=4
	s.Parent=SoundService
	s:Play()
	local endedConn
	endedConn=s.Ended:Connect(function()
		if endedConn then endedConn:Disconnect()end
		if s.Parent then s:Destroy()end
	end)
	local ttl=12
	if s.TimeLength and s.TimeLength>0 then
		ttl=math.max(2,s.TimeLength+1)
	end
	DebrisSvc:AddItem(s,ttl)
end

function WeaponUtil.applyCameraFov(forceDefault)
	if not Cam then return end
	local value=tonumber(Values.customFovValue) or defaultCameraFov
	if Flags.customFovEnabled then
		if Cam.FieldOfView~=value then
			Cam.FieldOfView=value
		end
	elseif forceDefault and Cam.FieldOfView~=defaultCameraFov then
		Cam.FieldOfView=defaultCameraFov
	end
end

function WeaponUtil.getTimingKeyMode(key)
	if type(key)~="string" then return nil end
	local lk=key:lower()
	if not (lk:find("reload") or lk:find("equip") or lk:find("draw") or lk:find("holster") or lk:find("raise") or lk:find("lower")) then
		return nil
	end
	if lk:find("speed") then return "speed" end
	if lk:find("time") or lk:find("duration") or lk:find("delay") then return "time" end
	return nil
end

function WeaponUtil.updateTimingBackup(target,tbl)
	if type(tbl)~="table" then return end
	for k,v in pairs(tbl)do
		if target[k]==nil and type(v)=="number"then
			local mode=WeaponUtil.getTimingKeyMode(k)
			if mode then
				target[k]={mode=mode,value=v}
			end
		end
	end
end

function WeaponUtil.ensureMutableProperties(weapon)
	if not weapon then return nil end
	local props=weapon.Properties
	if type(props)~="table" then return props end
	if table.isfrozen and table.isfrozen(props) then
		local clone=table.clone(props)
		weapon.Properties=clone
		return clone
	end
	local ok=pcall(function()
		props.__bstest=props.__bstest
	end)
	if not ok then
		local clone=table.clone(props)
		weapon.Properties=clone
		return clone
	end
	if props.__bstest~=nil then
		props.__bstest=nil
	end
	return props
end

function WeaponUtil.isMeleeWeapon(props)
	if type(props)~="table" then return false end
	local class=props.Class or props.Type or props.Slot
	return class=="Melee" or class=="Knife"
end

function WeaponUtil.ensureWeaponBackup(weapon,props)
	local backup=weaponTweaks[weapon]
	if backup then return backup end
	backup={propRange=nil,fieldRange=nil,propTiming={},fieldTiming={}}
	if type(props)=="table" then
		if type(props.Range)=="number" then backup.propRange=props.Range end
		WeaponUtil.updateTimingBackup(backup.propTiming,props)
	end
	if type(weapon)=="table" then
		if type(weapon.Range)=="number" then backup.fieldRange=weapon.Range end
		WeaponUtil.updateTimingBackup(backup.fieldTiming,weapon)
	end
	weaponTweaks[weapon]=backup
	return backup
end

function WeaponUtil.applyWeaponTweaks(weapon)
	if type(weapon)~="table" then return end
	local props=weapon.Properties
	if type(props)=="table" then
		props=WeaponUtil.ensureMutableProperties(weapon)
	end
	local backup=WeaponUtil.ensureWeaponBackup(weapon,props)
	if type(props)=="table" then
		if backup.propRange==nil and type(props.Range)=="number" then
			backup.propRange=props.Range
		end
		WeaponUtil.updateTimingBackup(backup.propTiming,props)
		if backup.propRange then
			if Flags.meleeRangeEnabled and Values.meleeRangeMultiplier and Values.meleeRangeMultiplier>1 and WeaponUtil.isMeleeWeapon(props) then
				props.Range=backup.propRange*Values.meleeRangeMultiplier
			else
				props.Range=backup.propRange
			end
		end
		for k,info in pairs(backup.propTiming)do
			if Flags.fastReloadEnabled and Values.reloadEquipMultiplier and Values.reloadEquipMultiplier>1 then
				if info.mode=="time" then
					props[k]=math.max(info.value/Values.reloadEquipMultiplier,0.01)
				else
					props[k]=info.value*Values.reloadEquipMultiplier
				end
			else
				props[k]=info.value
			end
		end
	end
	WeaponUtil.updateTimingBackup(backup.fieldTiming,weapon)
	if backup.fieldRange==nil and type(weapon.Range)=="number" then
		backup.fieldRange=weapon.Range
	end
	if backup.fieldRange then
		if Flags.meleeRangeEnabled and Values.meleeRangeMultiplier and Values.meleeRangeMultiplier>1 and WeaponUtil.isMeleeWeapon(props) then
			weapon.Range=backup.fieldRange*Values.meleeRangeMultiplier
		else
			weapon.Range=backup.fieldRange
		end
	end
	for k,info in pairs(backup.fieldTiming)do
		if Flags.fastReloadEnabled and Values.reloadEquipMultiplier and Values.reloadEquipMultiplier>1 then
			if info.mode=="time" then
				weapon[k]=math.max(info.value/Values.reloadEquipMultiplier,0.01)
			else
				weapon[k]=info.value*Values.reloadEquipMultiplier
			end
		else
			weapon[k]=info.value
		end
	end
end

function WeaponUtil.applyWeaponTweaksToInventory()
	local okInv,InventoryController=pcall(function()
		return require(RS.Controllers.InventoryController)
	end)
	if not okInv or not InventoryController then return end
	local inv=InventoryController.getCurrentInventory()
	if type(inv)=="table"then
		for _,slot in pairs(inv)do
			if type(slot)=="table"and type(slot._items)=="table"then
				for _,item in pairs(slot._items)do
					if type(item)=="table"and item.Properties then
						WeaponUtil.applyWeaponTweaks(item)
					end
				end
			end
		end
	end
	local equipped=InventoryController.getCurrentEquipped()
	if equipped and equipped.Properties then
		WeaponUtil.applyWeaponTweaks(equipped)
	end
end

function WeaponUtil.setupMovementHooks()
	if movementHooksInstalled then return end
	local ok,Character=pcall(function()
		return require(RS.Classes.Character)
	end)
	if not ok or not Character then return end
	movementHooksInstalled=true
	local origGetMaxSpeed=Character.GetMaxSpeed
	if origGetMaxSpeed then
		Character.GetMaxSpeed=function(self,...)
			local speed=origGetMaxSpeed(self,...)
			if Flags.walkSpeedEnabled and Values.walkSpeedValue and Values.walkSpeedValue>0 then
				speed=speed*(Values.walkSpeedValue/20)
			end
			return speed
		end
	end
	local origToggleCrouchState=Character.ToggleCrouchState
	if origToggleCrouchState then
		Character.ToggleCrouchState=function(self,state)
			local res=origToggleCrouchState(self,state)
			if Flags.instantCrouchEnabled and self and self.Humanoid then
				if self.CrouchTween then
					pcall(function()self.CrouchTween:Cancel()end)
					self.CrouchTween=nil
				end
				local offset=self.DefaultCameraOffset or Vector3.new(0,0,0)
				if self.IsCrouching then
					offset=(self.CrouchCameraOffset or Vector3.new(0,-1.4,0))+offset
				end
				pcall(function()self.Humanoid.CameraOffset=offset end)
			end
			return res
		end
	end
	local origMoveFunction=Character.MoveFunction
	if origMoveFunction then
		Character.MoveFunction=function(self,...)
			local res=origMoveFunction(self,...)
			if Flags.fastClimbEnabled and self and self.IsClimbing and not self.JumpedOffLadder and self.Character and self.Character.PrimaryPart then
				local mult=tonumber(Values.climbSpeedMultiplier) or 1
				if mult>1 then
					local hrp=self.Character.PrimaryPart
					local vel=hrp.AssemblyLinearVelocity
					local newVel=Vector3.new(vel.X*mult,vel.Y*mult,vel.Z*mult)
					if newVel==newVel and newVel.Magnitude<10000 then
						hrp.AssemblyLinearVelocity=newVel
					end
				end
			end
			return res
		end
	end
end

function WeaponUtil.setupWeaponHooks()
	if not animHooksInstalled then
		local okAnim,Anim=pcall(function()
			return require(RS.Classes.WeaponComponent.Classes.Viewmodel.Classes.Animation)
		end)
		if okAnim and Anim then
			animHooksInstalled=true
			local origPlay=Anim.play
			Anim.play=function(self,name,...)
				local track=origPlay(self,name,...)
				if Flags.fastReloadEnabled and Values.reloadEquipMultiplier and Values.reloadEquipMultiplier>1 and track and type(name)=="string" then
					local lower=name:lower()
					if lower:find("reload") or lower:find("equip") or lower:find("draw") or lower:find("holster") or lower:find("raise") or lower:find("lower") then
						pcall(function()track:AdjustSpeed(Values.reloadEquipMultiplier)end)
					end
				end
				return track
			end
			local origAdjust=Anim.adjustAnimationSpeed
			Anim.adjustAnimationSpeed=function(self,name,time,...)
				if Flags.fastReloadEnabled and Values.reloadEquipMultiplier and Values.reloadEquipMultiplier>1 and type(name)=="string" and type(time)=="number" then
					local lower=name:lower()
					if lower:find("reload") or lower:find("equip") or lower:find("draw") or lower:find("holster") or lower:find("raise") or lower:find("lower") then
						time=time/Values.reloadEquipMultiplier
					end
				end
				return origAdjust(self,name,time,...)
			end
		end
	end
	if not weaponHooksConnected then
		local okInv,InventoryController=pcall(function()
			return require(RS.Controllers.InventoryController)
		end)
		if okInv and InventoryController then
			weaponHooksConnected=true
			if InventoryController.OnInventoryItemEquipped then
				InventoryController.OnInventoryItemEquipped:Connect(function(_,weapon)
					WeaponUtil.applyWeaponTweaks(weapon)
				end)
			end
			WeaponUtil.applyWeaponTweaksToInventory()
		end
	end
end

task.spawn(function()
	for _=1,5 do
		WeaponUtil.setupMovementHooks()
		WeaponUtil.setupWeaponHooks()
		if movementHooksInstalled and weaponHooksConnected and animHooksInstalled then
			break
		end
		task.wait(1)
	end
end)

local function hueColor(h)
	return Color3.fromHSV((h%1+1)%1,1,1)
end

local function makeRainbowSequence(h)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0,hueColor(h)),
		ColorSequenceKeypoint.new(0.5,hueColor(h+0.33)),
		ColorSequenceKeypoint.new(1,hueColor(h+0.66))
	})
end

local function newTracerFolder()
	local folder=Instance.new("Folder")
	folder.Name="TracerFX"
	folder.Parent=getTracerParent()
	return folder
end

local function newTracerPart(parent,pos)
	local part=Instance.new("Part")
	part.Anchored=true
	part.CanCollide=false
	part.CanQuery=false
	part.CanTouch=false
	part.Transparency=1
	part.Size=Vector3.new(0.12,0.12,0.12)
	part.CFrame=CFrame.new(pos)
	part.Parent=parent
	return part
end

local function newBeam(parent,att0,att1,color,width0,width1)
	local beam=Instance.new("Beam")
	beam.Attachment0=att0
	beam.Attachment1=att1
	beam.FaceCamera=true
	beam.LightEmission=1
	beam.LightInfluence=0
	beam.Width0=width0
	beam.Width1=width1 or width0
	beam.Color=color
	beam.Transparency=NumberSequence.new(0)
	beam.Parent=parent
	return beam
end

local function getTracerAxes(dir)
	local right=dir:Cross(Vector3.new(0,1,0))
	if right.Magnitude<0.1 then
		right=dir:Cross(Cam.CFrame.RightVector)
	end
	if right.Magnitude<0.1 then
		right=Vector3.new(1,0,0)
	end
	right=right.Unit
	local up=right:Cross(dir).Unit
	return right,up
end

local function addTracerPlus(folder,endPos,dir,color,width)
	if not folder or not endPos or not dir then return nil end
	local right,up=getTracerAxes(dir)
	local size=math.clamp(width*1.8,0.08,0.3)
	local p=newTracerPart(folder,endPos)
	p.Size=Vector3.new(0.05,0.05,0.05)
	local a0=Instance.new("Attachment",p)
	local a1=Instance.new("Attachment",p)
	local a2=Instance.new("Attachment",p)
	local a3=Instance.new("Attachment",p)
	a0.Position=right*size
	a1.Position=-right*size
	a2.Position=up*size
	a3.Position=-up*size
	local beamA=newBeam(folder,a0,a1,color,width*0.55,width*0.2)
	local beamB=newBeam(folder,a2,a3,color,width*0.55,width*0.2)
	return {beamA,beamB}
end

local function createTracer(sp,ep)
	if not sp or not ep then return end
	local delta=ep-sp
	local dist=delta.Magnitude
	if dist<0.1 then return end
	playHitSfx()
	local now=tick()
	if tracerStyle=="Rainbow Flow" then
		local folder=newTracerFolder()
		local p0=newTracerPart(folder,sp)
		local p1=newTracerPart(folder,ep)
		local a0=Instance.new("Attachment",p0)
		local a1=Instance.new("Attachment",p1)
		local hue=math.random()
		local beam=newBeam(folder,a0,a1,makeRainbowSequence(hue),0.2,0.05)
		local plus=addTracerPlus(folder,ep,delta.Unit,makeRainbowSequence(hue),0.2)
		local tr={Type="beam",Style="Rainbow Flow",Folder=folder,Beam=beam,PlusBeams=plus,CreatedTime=now,Duration=1.25,HueOffset=hue,BaseWidth=0.2}
		table.insert(SATracers,tr)
		DebrisSvc:AddItem(folder,tr.Duration+0.2)
		return
	elseif tracerStyle=="Prism Pulse" then
		local folder=newTracerFolder()
		local p0=newTracerPart(folder,sp)
		local p1=newTracerPart(folder,ep)
		local a0=Instance.new("Attachment",p0)
		local a1=Instance.new("Attachment",p1)
		local prism=ColorSequence.new({
			ColorSequenceKeypoint.new(0,Color3.fromRGB(0,255,255)),
			ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,80,200)),
			ColorSequenceKeypoint.new(1,Color3.fromRGB(255,220,60))
		})
		local beam=newBeam(folder,a0,a1,prism,0.22,0.06)
		local core=ColorSequence.new({
			ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
			ColorSequenceKeypoint.new(1,Color3.fromRGB(255,210,140))
		})
		local coreBeam=newBeam(folder,a0,a1,core,0.1,0.03)
		local plus=addTracerPlus(folder,ep,delta.Unit,prism,0.22)
		local tr={Type="beam",Style="Prism Pulse",Folder=folder,Beam=beam,Core=coreBeam,PlusBeams=plus,CreatedTime=now,Duration=1.15,BaseWidth=0.22,PulseSpeed=12}
		table.insert(SATracers,tr)
		DebrisSvc:AddItem(folder,tr.Duration+0.2)
		return
	elseif tracerStyle=="Split Neon" then
		local folder=newTracerFolder()
		local p0=newTracerPart(folder,sp)
		local p1=newTracerPart(folder,ep)
		local dir=delta.Unit
		local offset=dir:Cross(Vector3.new(0,1,0))
		if offset.Magnitude<0.1 then
			offset=dir:Cross(Cam.CFrame.RightVector)
		end
		if offset.Magnitude<0.1 then
			offset=Vector3.new(1,0,0)
		end
		offset=offset.Unit*0.12
		local a0a=Instance.new("Attachment",p0)
		local a1a=Instance.new("Attachment",p1)
		local a0b=Instance.new("Attachment",p0)
		local a1b=Instance.new("Attachment",p1)
		a0a.Position,a1a.Position=offset,offset
		a0b.Position,a1b.Position=-offset,-offset
		local hue=math.random()
		local c1=hueColor(hue)
		local c2=hueColor(hue+0.5)
		local beamA=newBeam(folder,a0a,a1a,ColorSequence.new(c1,c2),0.18,0.05)
		local beamB=newBeam(folder,a0b,a1b,ColorSequence.new(c2,c1),0.14,0.04)
		local plus=addTracerPlus(folder,ep,delta.Unit,ColorSequence.new(c1,c2),0.18)
		local tr={Type="beam",Style="Split Neon",Folder=folder,Beams={beamA,beamB},PlusBeams=plus,CreatedTime=now,Duration=1.1,BaseWidth=0.18,HueOffset=hue}
		table.insert(SATracers,tr)
		DebrisSvc:AddItem(folder,tr.Duration+0.2)
		return
	elseif tracerStyle=="Zigzag" then
		local folder=newTracerFolder()
		local dir=delta.Unit
		local right,up=getTracerAxes(dir)
		local segments=math.clamp(math.floor(dist/8),4,9)
		local amp=math.clamp(dist*0.02,0.15,0.6)
		local points={}
		for i=0,segments do
			local t=i/segments
			local base=sp+dir*dist*t
			local offset=Vector3.new(0,0,0)
			if i>0 and i<segments then
				offset=right*amp*((i%2==0) and 1 or -1)
				offset=offset+up*(amp*0.35)
			end
			points[i+1]=base+offset
		end
		local beams={}
		local seq=ColorSequence.new(Color3.fromRGB(80,220,255),Color3.fromRGB(255,90,200))
		for i=1,#points-1 do
			local p0=newTracerPart(folder,points[i])
			local p1=newTracerPart(folder,points[i+1])
			local a0=Instance.new("Attachment",p0)
			local a1=Instance.new("Attachment",p1)
			table.insert(beams,newBeam(folder,a0,a1,seq,0.18,0.05))
		end
		local plus=addTracerPlus(folder,ep,dir,seq,0.18)
		local tr={Type="beam",Style="Zigzag",Folder=folder,Beams=beams,PlusBeams=plus,CreatedTime=now,Duration=1.2,BaseWidth=0.18}
		table.insert(SATracers,tr)
		DebrisSvc:AddItem(folder,tr.Duration+0.2)
		return
	elseif tracerStyle=="Sine Wave" then
		local folder=newTracerFolder()
		local dir=delta.Unit
		local right,up=getTracerAxes(dir)
		local segments=math.clamp(math.floor(dist/7),5,10)
		local amp=math.clamp(dist*0.018,0.12,0.5)
		local waves=2
		local points={}
		for i=0,segments do
			local t=i/segments
			local base=sp+dir*dist*t
			local phase=math.sin(t*math.pi*2*waves)
			local offset=right*amp*phase+up*(amp*0.4*math.cos(t*math.pi*2*waves))
			points[i+1]=base+offset
		end
		local beams={}
		local seq=ColorSequence.new(Color3.fromRGB(140,255,170),Color3.fromRGB(60,140,255))
		for i=1,#points-1 do
			local p0=newTracerPart(folder,points[i])
			local p1=newTracerPart(folder,points[i+1])
			local a0=Instance.new("Attachment",p0)
			local a1=Instance.new("Attachment",p1)
			table.insert(beams,newBeam(folder,a0,a1,seq,0.16,0.045))
		end
		local plus=addTracerPlus(folder,ep,dir,seq,0.16)
		local tr={Type="beam",Style="Sine Wave",Folder=folder,Beams=beams,PlusBeams=plus,CreatedTime=now,Duration=1.2,BaseWidth=0.16}
		table.insert(SATracers,tr)
		DebrisSvc:AddItem(folder,tr.Duration+0.2)
		return
	end
	local ln=Drawing.new("Line")
	ln.Visible,ln.Color,ln.Thickness,ln.Transparency=true,Color3.fromRGB(255,255,0),2,1
	local plusA=Drawing.new("Line")
	local plusB=Drawing.new("Line")
	plusA.Visible,plusA.Color,plusA.Thickness,plusA.Transparency=false,ln.Color,2,1
	plusB.Visible,plusB.Color,plusB.Thickness,plusB.Transparency=false,ln.Color,2,1
	table.insert(SATracers,{Line=ln,PlusLines={plusA,plusB},StartPos=sp,EndPos=ep,CreatedTime=now,Duration=3,HueOffset=math.random()})
end

local function updateTracers()
	local ct=tick()
	for i=#SATracers,1,-1 do
		local tr=SATracers[i]
		local el=ct-tr.CreatedTime
		if el>=tr.Duration then
			destroyTracer(tr)
			table.remove(SATracers,i)
		else
			if tr.Line then
				local ss,sv=Cam:WorldToViewportPoint(tr.StartPos)
				local es,ev=Cam:WorldToViewportPoint(tr.EndPos)
				if sv and ev then
					tr.Line.From,tr.Line.To,tr.Line.Visible=Vector2.new(ss.X,ss.Y),Vector2.new(es.X,es.Y),true
					tr.Line.Transparency=1-(el/tr.Duration)
					tr.Line.Color=hueColor((tr.HueOffset or 0)+el*0.6)
					if tr.PlusLines then
						local size=6
						local c=tr.Line.Color
						local t=tr.Line.Transparency
						local a=tr.PlusLines[1]
						local b=tr.PlusLines[2]
						if a and b then
							a.From,a.To=Vector2.new(es.X-size,es.Y),Vector2.new(es.X+size,es.Y)
							b.From,b.To=Vector2.new(es.X,es.Y-size),Vector2.new(es.X,es.Y+size)
							a.Color,a.Transparency,a.Visible=c,t,true
							b.Color,b.Transparency,b.Visible=c,t,true
						end
					end
				else
					tr.Line.Visible=false
					if tr.PlusLines then
						for _,ln in ipairs(tr.PlusLines)do
							if ln then ln.Visible=false end
						end
					end
				end
			else
				local fade=math.clamp(el/tr.Duration,0,1)
				local trans=NumberSequence.new(fade)
				if tr.Beam then tr.Beam.Transparency=trans end
				if tr.Core then tr.Core.Transparency=NumberSequence.new(math.min(1,fade+0.15))end
				if tr.Beams then
					for _,beam in ipairs(tr.Beams)do
						beam.Transparency=trans
					end
				end
				if tr.PlusBeams then
					for _,beam in ipairs(tr.PlusBeams)do
						beam.Transparency=trans
					end
				end
				if tr.Style=="Rainbow Flow"and tr.Beam then
					local hue=(tr.HueOffset or 0)+el*0.6
					tr.Beam.Color=makeRainbowSequence(hue)
					if tr.PlusBeams then
						for _,beam in ipairs(tr.PlusBeams)do
							beam.Color=makeRainbowSequence(hue)
						end
					end
					local w=(tr.BaseWidth or 0.2)*(1-(fade*0.35))
					tr.Beam.Width0=w
					tr.Beam.Width1=w*0.25
				elseif tr.Style=="Prism Pulse"then
					local pulse=0.7+0.3*math.sin(el*(tr.PulseSpeed or 10))
					local w=(tr.BaseWidth or 0.22)*pulse
					if tr.Beam then
						tr.Beam.Width0=w
						tr.Beam.Width1=w*0.3
					end
					if tr.Core then
						tr.Core.Width0=w*0.45
						tr.Core.Width1=w*0.18
					end
				elseif tr.Style=="Split Neon"and tr.Beams then
					local pulse=0.7+0.3*math.sin(el*11)
					local w=(tr.BaseWidth or 0.18)*pulse
					tr.Beams[1].Width0=w
					tr.Beams[1].Width1=w*0.28
					tr.Beams[2].Width0=w*0.8
					tr.Beams[2].Width1=w*0.22
					local hue=(tr.HueOffset or 0)+el*0.3
					local c1=hueColor(hue)
					local c2=hueColor(hue+0.5)
					tr.Beams[1].Color=ColorSequence.new(c1,c2)
					tr.Beams[2].Color=ColorSequence.new(c2,c1)
					if tr.PlusBeams then
						for _,beam in ipairs(tr.PlusBeams)do
							beam.Color=ColorSequence.new(c1,c2)
						end
					end
				end
			end
		end
	end
end

local function getTargetPart(c,mp)
	if not c then return nil end
	if SA.TargetPart=="Head"then return c:FindFirstChild("Head")end
	if SA.TargetPart=="Torso"then return c:FindFirstChild("UpperTorso")or c:FindFirstChild("Torso")or c:FindFirstChild("HumanoidRootPart")end
	if SA.TargetPart=="HumanoidRootPart"then return c:FindFirstChild("HumanoidRootPart")end
	if SA.TargetPart=="Closest Part"then
		local parts={c:FindFirstChild("Head"),c:FindFirstChild("UpperTorso"),c:FindFirstChild("Torso"),c:FindFirstChild("HumanoidRootPart")}
		local bestPart,bestDist=nil,math.huge
		for _,pt in ipairs(parts)do
			if pt then
				local sp,os=Cam:WorldToViewportPoint(pt.Position)
				if os and sp.Z>0 then
					local d=(Vector2.new(sp.X,sp.Y)-mp).Magnitude
					if d<bestDist then bestPart,bestDist=pt,d end
				end
			end
		end
		return bestPart
	end
	return c:FindFirstChild("Head")
end

local function getSATarget()
	local cp,sd,mp=nil,SA.Range,UIS:GetMouseLocation()
	for _,p in ipairs(Plrs:GetPlayers())do
		if p~=LP and not isTeam(LP,p)then
			local c=p.Character
			if c and c:FindFirstChild("Humanoid")and c.Humanoid.Health>0 then
				local tp=getTargetPart(c,mp)
				if tp then
					local sp,os=Cam:WorldToViewportPoint(tp.Position)
					if os then
						local d=(Vector2.new(sp.X,sp.Y)-mp).Magnitude
						if d<sd then cp,sd=p,d end
					end
				end
			end
		end
	end
	return cp
end

local function getSAPos()
	local t=getSATarget()
	if t and t.Character then
		local tp=getTargetPart(t.Character,UIS:GetMouseLocation())
		if tp then return tp.Position,t,tp end
	end
	return nil,nil,nil
end

local function getPartBox(part)
	if not part then return nil end
	local cf=part.CFrame
	local size=part.Size*0.5
	local corners={
		cf:PointToWorldSpace(Vector3.new(-size.X,-size.Y,-size.Z)),
		cf:PointToWorldSpace(Vector3.new(-size.X,-size.Y,size.Z)),
		cf:PointToWorldSpace(Vector3.new(-size.X,size.Y,-size.Z)),
		cf:PointToWorldSpace(Vector3.new(-size.X,size.Y,size.Z)),
		cf:PointToWorldSpace(Vector3.new(size.X,-size.Y,-size.Z)),
		cf:PointToWorldSpace(Vector3.new(size.X,-size.Y,size.Z)),
		cf:PointToWorldSpace(Vector3.new(size.X,size.Y,-size.Z)),
		cf:PointToWorldSpace(Vector3.new(size.X,size.Y,size.Z))
	}
	local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
	local anyOn=false
	for _,pt in ipairs(corners)do
		local v,on=Cam:WorldToViewportPoint(pt)
		if on and v.Z>0 then
			anyOn=true
			minX=math.min(minX,v.X)
			minY=math.min(minY,v.Y)
			maxX=math.max(maxX,v.X)
			maxY=math.max(maxY,v.Y)
		end
	end
	if not anyOn then return nil end
	return Vector2.new(minX,minY),Vector2.new(maxX-minX,maxY-minY)
end

local function updateSAVis()
	if not SAGUI then return end
	pcall(function()
		if SA.FOV then
			FOV.Position,FOV.Radius,FOV.Visible=UIS:GetMouseLocation(),SA.Range,true
		else
			FOV.Visible=false
		end
		local tp,t,part=getSAPos()
		SATarget=t
		if part and SA.ShowESP and SAGUI.TargetBox then
			local pos,size=getPartBox(part)
			if pos and size then
				SAGUI.TargetBox.Position=pos
				SAGUI.TargetBox.Size=size
				SAGUI.TargetBox.Visible=true
			else
				SAGUI.TargetBox.Visible=false
			end
		elseif SAGUI.TargetBox then
			SAGUI.TargetBox.Visible=false
		end
	end)
end

local function Spring()
	local self={p=0,v=0,g=0}
	function self:update(dt,d,s)
		local o=self.p-self.g
		local a=-s*o-d*self.v
		self.v=self.v+a*dt
		self.p=self.p+self.v*dt
	end
	function self:setGoal(g)self.g=g end
	function self:getPos()return self.p end
	function self:setPos(p)self.p=p end
	return self
end

local function setupCollisionCapsuleHandler()
	if Runtime.collisionCapsuleHandler then Runtime.collisionCapsuleHandler:Disconnect() end
	if not LP.Character then return end
	local existingCapsule = LP.Character:FindFirstChild("CollisionCapsule", true)
	if existingCapsule and existingCapsule:IsA("BasePart") then
		existingCapsule.Transparency = 1
		existingCapsule.CanCollide = false
		existingCapsule.CastShadow = false
		existingCapsule.Size = Vector3.new(0.1, 0.1, 0.1)
	end
	local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
	if hrp and hrp:IsA("BasePart") then
		hrp.Transparency = 1
		hrp.CanCollide = false
		hrp.CastShadow = false
	end
	Runtime.collisionCapsuleHandler = LP.Character.DescendantAdded:Connect(function(desc)
		task.wait()

		if desc.Name == "CollisionCapsule" and desc:IsA("BasePart") then
			desc.Transparency = 1
			desc.CanCollide = false
			desc.CastShadow = false
			desc.Size = Vector3.new(0.1, 0.1, 0.1)
		elseif desc.Name == "HumanoidRootPart" and desc:IsA("BasePart") then
			desc.Transparency = 1
			desc.CanCollide = false
			desc.CastShadow = false
		end
	end)
end


local function isTargetInFOV(targetPlayer,fov)
	if not targetPlayer or not targetPlayer.Character then return false end
	local tp=getTargetPart(targetPlayer.Character,UIS:GetMouseLocation())
	if not tp then return false end
	local screenPos,onScreen=Cam:WorldToViewportPoint(tp.Position)
	if not onScreen then return false end
	local mousePos=UIS:GetMouseLocation()
	local distance=math.sqrt((screenPos.X-mousePos.X)^2+(screenPos.Y-mousePos.Y)^2)
	local fovPixels=(Cam.ViewportSize.Y/2)*math.tan(math.rad(fov))
	return distance<=fovPixels
end

local function canShootTarget(targetPlayer,weapon)
	if not targetPlayer or targetPlayer==LP then return false end
	if isTeam(LP,targetPlayer)then return false end
	local targetChar=targetPlayer.Character
	if not targetChar then return false end
	local targetHum=targetChar:FindFirstChild("Humanoid")
	if not targetHum or targetHum.Health<=0 then return false end
	local targetPart=getTargetPart(targetChar,UIS:GetMouseLocation())
	if not targetPart then return false end
	if targetChar.Parent and targetChar.Parent.Name=="Dead"then return false end
	if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")then
		local dist=(LP.Character.HumanoidRootPart.Position-targetPart.Position).Magnitude
		if dist>500 then return false end
	end
	local origin=LP.Character.HumanoidRootPart.Position
	local direction=(targetPart.Position-origin).Unit
	local distance=(targetPart.Position-origin).Magnitude
	local rayParams=RaycastParams.new()
	rayParams.FilterType,rayParams.FilterDescendantsInstances,rayParams.IgnoreWater=Enum.RaycastFilterType.Exclude,{LP.Character,Cam},true
	local result=workspace:Raycast(origin,direction*distance,rayParams)
	if result then
		local hitModel=result.Instance:FindFirstAncestorOfClass("Model")
		if hitModel~=targetPlayer.Character then return false end
	end
	return true
end

local function findShootableTarget(weapon)
	local bestTarget,closestDist,bestPart=nil,math.huge,nil
	for _,player in ipairs(Plrs:GetPlayers())do
		if canShootTarget(player,weapon)and isTargetInFOV(player,Runtime.autoShootFOV)then
			local targetChar=player.Character
			local targetPart=getTargetPart(targetChar,UIS:GetMouseLocation())
			if targetPart and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")then
				local dist=(LP.Character.HumanoidRootPart.Position-targetPart.Position).Magnitude
				if dist<closestDist then closestDist,bestTarget,bestPart=dist,player,targetPart end
			end
		end
	end
	return bestTarget,bestPart
end

local function getEquippedWeapon()
	local success,result=pcall(function()
		local InventoryController=require(RS.Controllers.InventoryController)
		return InventoryController.getCurrentEquipped()
	end)
	if success and result then return result end
	return nil
end

local function fireWeaponRemote(weapon,targetPos)
	if not weapon or weapon.Rounds<=0 then return false end
	local muzzlePos=nil
	local weaponModel=WS.Debris:FindFirstChild(LP.Name.."_Weapon")
	if weaponModel then
		local interactables=weaponModel:FindFirstChild("Interactables")
		if interactables then
			local muzzlePart=interactables:FindFirstChild("MuzzlePart")
			if muzzlePart then muzzlePos=muzzlePart.Position end
		end
	end
	if not muzzlePos then
		if LP.Character and LP.Character:FindFirstChild("Head")then muzzlePos=LP.Character.Head.Position else return false end
	end
	local direction=(targetPos-muzzlePos).Unit
	local rayParams=RaycastParams.new()
	local debris=WS:FindFirstChild("Debris")
	local filter={LP.Character,Cam}
	if debris then table.insert(filter,debris)end
	rayParams.FilterType,rayParams.FilterDescendantsInstances,rayParams.IgnoreWater=Enum.RaycastFilterType.Exclude,filter,true
	local maxDistance=weapon.Properties.Range or 500
	local rayResult=WS:Raycast(muzzlePos,direction*maxDistance,rayParams)
	local hits,endPos={},muzzlePos+direction*maxDistance
	if rayResult then
		local hitDistance=(rayResult.Position-muzzlePos).Magnitude
		endPos=rayResult.Position
		table.insert(hits,{Distance=hitDistance,Instance=rayResult.Instance,Position=rayResult.Position,Normal=rayResult.Normal,Material=rayResult.Material.Name,Exit=false})
	else
		table.insert(hits,{Distance=maxDistance,Instance=nil,Position=endPos,Normal=Vector3.new(0,1,0),Material="Air",Exit=false})
	end
	if SA.ShowTracers then createTracer(muzzlePos,targetPos)end
	local bulletData={Origin=muzzlePos,Direction=direction,Hits=hits}
	local success,err=pcall(function()
		local Remotes=require(RS.Database.Security.Remotes)
		Remotes.Inventory.ShootWeapon.Send({IsSniperScoped=weapon.IsSniperScoped or false,ShootingHand=weapon.ShootingHand or"Right",Identifier=weapon.Identifier,Capacity=weapon.Capacity,Bullets={bulletData},Rounds=weapon.Rounds-1})
		weapon.Rounds=weapon.Rounds-1
	end)
	if not success and Flags.debugMode then print("[Auto Shoot] Error:",err)end
	return success
end

local function toggleAutoShoot(enabled)
	Flags.autoShootEnabled=enabled
	if enabled then
		if Runtime.autoShootConnection then Runtime.autoShootConnection:Disconnect()end
		Runtime.autoShootConnection=Run.Heartbeat:Connect(function()
			if not Flags.autoShootEnabled then return end
			pcall(function()
				local currentTime=tick()
				if currentTime-Runtime.lastAutoShootTime<Runtime.autoShootDelay then return end
				local weapon=getEquippedWeapon()
				if not weapon or weapon.IsReloading or weapon.IsShooting or weapon.Rounds<=0 then return end
				local target,targetPart=findShootableTarget(weapon)
				if not target or not targetPart then return end
				if fireWeaponRemote(weapon,targetPart.Position)then
					Runtime.lastAutoShootTime=currentTime
					if Flags.debugMode then print("[Auto Shoot] Fired at:",target.Name,"Ammo:",weapon.Rounds)end
				end
			end)
		end)
		print("[Auto Shoot] Enabled - Direct remote firing (FOV:",Runtime.autoShootFOV,"Delay:",Runtime.autoShootDelay.."s)")
	else
		if Runtime.autoShootConnection then Runtime.autoShootConnection:Disconnect()Runtime.autoShootConnection=nil end
		print("[Auto Shoot] Disabled")
	end
end

local function toggleBhop(enabled)
	Flags.bhopEnabled=enabled
	if enabled then
		if Runtime.bhopConnection then Runtime.bhopConnection:Disconnect()end
		Runtime.bhopConnection=Run.Heartbeat:Connect(function()
			if not Flags.bhopEnabled then return end
			pcall(function()
				if LP.Character and LP.Character:FindFirstChild("Humanoid")then
					local hum=LP.Character.Humanoid
					local state=hum:GetState()
					if hum.MoveDirection.Magnitude>0.1 then
						if state==Enum.HumanoidStateType.Running or state==Enum.HumanoidStateType.RunningNoPhysics then hum.Jump=true end
					end
				end
			end)
		end)
		print("[Bhop] Enabled")
	else
		if Runtime.bhopConnection then Runtime.bhopConnection:Disconnect()Runtime.bhopConnection=nil end
		print("[Bhop] Disabled")
	end
end

local function isFirstPerson()
	if Flags.tpEnabled then return false end
	if LP.CameraMode==Enum.CameraMode.LockFirstPerson then return true end
	local char=LP.Character
	local head=char and char:FindFirstChild("Head")
	if head and (Cam.CFrame.Position-head.Position).Magnitude<1 then return true end
	return false
end

local function toggleSpinbot(enabled)
	Flags.spinbotEnabled=enabled
	if enabled then
		Runtime.spinbotAngle=0
		if Runtime.spinbotConnection then Runtime.spinbotConnection:Disconnect()Runtime.spinbotConnection=nil end
		Runtime.spinbotConnection=Run.Stepped:Connect(function(_,dt)
			if not Flags.spinbotEnabled then return end
			local cc=Runtime.characterController
			if not cc then
				local ok,mod=pcall(function()
					return require(RS.Controllers.CharacterController)
				end)
				if ok and mod then
					Runtime.characterController=mod
					cc=mod
				end
			end
			local charObj=cc and cc.getCurrentCharacter and cc.getCurrentCharacter()
			if not charObj or charObj.IsDestroyed then return end
			local align=charObj.AlignOrientation
			if not align or not align.Parent then return end
			local state=Runtime.spinbotAlignState
			if not state or state.obj~=align then
				Runtime.spinbotAlignState={obj=align,Enabled=align.Enabled,RigidityEnabled=align.RigidityEnabled,MaxTorque=align.MaxTorque,Responsiveness=align.Responsiveness}
			end
			Runtime.spinbotAngle=(Runtime.spinbotAngle+(Runtime.spinbotSpeed*dt))%(math.pi*2)
			charObj.TargetYRotation=Runtime.spinbotAngle
			charObj.CurrentYRotation=Runtime.spinbotAngle
			align.Enabled=true
			align.RigidityEnabled=true
			align.MaxTorque=math.huge
			align.Responsiveness=200
			align.CFrame=CFrame.Angles(0,Runtime.spinbotAngle,0)
		end)
		print("[Spinbot] Enabled at speed:",Runtime.spinbotSpeed)
	else
		if Runtime.spinbotConnection then
			Runtime.spinbotConnection:Disconnect()
			Runtime.spinbotConnection=nil
		end
		local state=Runtime.spinbotAlignState
		if state and state.obj then
			local align=state.obj
			pcall(function()
				align.Enabled=state.Enabled
				align.RigidityEnabled=state.RigidityEnabled
				align.MaxTorque=state.MaxTorque
				align.Responsiveness=state.Responsiveness
			end)
		end
		Runtime.spinbotAlign=nil
		Runtime.spinbotAlignState=nil
		Runtime.spinbotAngle=0
		print("[Spinbot] Disabled")
	end
end

local function forceCharacterVisible()
	if not LP.Character then return end
	pcall(function()
		for _,v in pairs(LP.Character:GetDescendants())do
			if v:IsA("BasePart")then
				if v.Name=="CollisionCapsule"then
					v.Transparency,v.CanCollide,v.CastShadow,v.Size=1,false,false,Vector3.new(0.1,0.1,0.1)
					continue
				end
				if Flags.tpEnabled and v.Name=="HumanoidRootPart"then
					v.LocalTransparencyModifier,v.Transparency=1,1
					v.CanCollide=false
					v.CastShadow=false
				else
					v.LocalTransparencyModifier,v.Transparency=0,0
				end
			elseif v:IsA("Decal")then v.Transparency=0 end
		end
		local charModel=LP.Character:FindFirstChild("WeaponModel")
		if charModel then
			for _,v in pairs(charModel:GetDescendants())do
				if v:IsA("BasePart")then
					v.LocalTransparencyModifier,v.Transparency=0,0
					if v.Name=="CollisionCapsule"then v.Transparency=1 end
				end
			end
		end
		local charAttach=LP.Character:FindFirstChild("WeaponAttachments")
		if charAttach then
			for _,v in pairs(charAttach:GetDescendants())do
				if v:IsA("BasePart")then v.LocalTransparencyModifier,v.Transparency=0,0 end
			end
		end
		local debris=WS:FindFirstChild("Debris")
		if debris then
			local wepModel=debris:FindFirstChild(LP.Name.."_Weapon")
			if wepModel then
				for _,v in pairs(wepModel:GetDescendants())do
					if v:IsA("BasePart")then v.LocalTransparencyModifier,v.Transparency=0,0 end
				end
			end
			local wepAttach=debris:FindFirstChild(LP.Name.."_WeaponAttachments")
			if wepAttach then
				for _,v in pairs(wepAttach:GetDescendants())do
					if v:IsA("BasePart")then v.LocalTransparencyModifier,v.Transparency=0,0 end
				end
			end
		end
	end)
end

local tpVisLoop,tpDescendantConn=nil,nil
local toggleFreecam

local function toggleTP(enabled)
	if enabled and Flags.freecamEnabled then
		Runtime.freecamRestoreTP=false
		toggleFreecam(false)
	end
	Flags.tpEnabled=enabled
	if enabled then
		if not origCamSub then origCamSub,origCamType=Cam.CameraSubject,Cam.CameraType end
		Cam.CameraType=Enum.CameraType.Scriptable
		if LP.Character then
			forceCharacterVisible()
			setupCollisionCapsuleHandler()
			if LP.Character:FindFirstChild("Humanoid")then LP.Character.Humanoid.AutoRotate=true end
			local hrp=LP.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local offset=Cam.CFrame.LookVector*-Runtime.tpDist+Vector3.new(0,2,0)
				local startPos=hrp.Position+offset
				tpSpringPos=tpSpringPos or{x=Spring(),y=Spring(),z=Spring()}
				tpSpringRot=tpSpringRot or{x=Spring(),y=Spring(),z=Spring()}
				tpSpringPos.x:setPos(startPos.X)
				tpSpringPos.y:setPos(startPos.Y)
				tpSpringPos.z:setPos(startPos.Z)
				tpSpringRot.x:setPos(hrp.Position.X)
				tpSpringRot.y:setPos(hrp.Position.Y)
				tpSpringRot.z:setPos(hrp.Position.Z)
			end
		end
		if tpUpdateConn then tpUpdateConn:Disconnect()end
		if tpVisLoop then tpVisLoop:Disconnect()end
		if tpDescendantConn then tpDescendantConn:Disconnect()end
		tpVisLoop=Run.RenderStepped:Connect(function()
			if not Flags.tpEnabled then return end
			forceCharacterVisible()
		end)
		if LP.Character then
			tpDescendantConn=LP.Character.DescendantAdded:Connect(function(desc)
				if not Flags.tpEnabled then return end
				task.wait()
				if desc:IsA("BasePart")then
					if desc.Name=="CollisionCapsule"then desc.Transparency,desc.CanCollide,desc.CastShadow,desc.Size=1,false,false,Vector3.new(0.1,0.1,0.1)
					elseif desc.Name=="HumanoidRootPart"then
						desc.LocalTransparencyModifier,desc.Transparency=1,1
						desc.CanCollide=false
						desc.CastShadow=false
					else desc.LocalTransparencyModifier,desc.Transparency=0,0 end
				elseif desc:IsA("Decal")then desc.Transparency=0 end
			end)
		end
		tpUpdateConn=Run.RenderStepped:Connect(function(dt)
			if not Flags.tpEnabled then return end
			pcall(function()
				if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")then
					local hrp=LP.Character.HumanoidRootPart
					local offset=Cam.CFrame.LookVector*-Runtime.tpDist+Vector3.new(0,2,0)
					local targetPos=hrp.Position+offset
					local targetLook=hrp.Position
					if not tpSpringPos then
						tpSpringPos={x=Spring(),y=Spring(),z=Spring()}
						tpSpringPos.x:setPos(targetPos.X)
						tpSpringPos.y:setPos(targetPos.Y)
						tpSpringPos.z:setPos(targetPos.Z)
					end
					if not tpSpringRot then
						tpSpringRot={x=Spring(),y=Spring(),z=Spring()}
						tpSpringRot.x:setPos(targetLook.X)
						tpSpringRot.y:setPos(targetLook.Y)
						tpSpringRot.z:setPos(targetLook.Z)
					end
					tpSpringPos.x:setGoal(targetPos.X)
					tpSpringPos.y:setGoal(targetPos.Y)
					tpSpringPos.z:setGoal(targetPos.Z)
					tpSpringRot.x:setGoal(targetLook.X)
					tpSpringRot.y:setGoal(targetLook.Y)
					tpSpringRot.z:setGoal(targetLook.Z)
					tpSpringPos.x:update(dt,20,200)
					tpSpringPos.y:update(dt,20,200)
					tpSpringPos.z:update(dt,20,200)
					tpSpringRot.x:update(dt,20,200)
					tpSpringRot.y:update(dt,20,200)
					tpSpringRot.z:update(dt,20,200)
					local finalPos=Vector3.new(tpSpringPos.x:getPos(),tpSpringPos.y:getPos(),tpSpringPos.z:getPos())
					local finalLook=Vector3.new(tpSpringRot.x:getPos(),tpSpringRot.y:getPos(),tpSpringRot.z:getPos())
					Cam.CFrame=CFrame.lookAt(finalPos,finalLook)
				end
			end)
		end)
	else
		if tpUpdateConn then tpUpdateConn:Disconnect()tpUpdateConn=nil end
		if tpVisLoop then tpVisLoop:Disconnect()tpVisLoop=nil end
		if tpDescendantConn then tpDescendantConn:Disconnect()tpDescendantConn=nil end
		if Runtime.collisionCapsuleHandler then Runtime.collisionCapsuleHandler:Disconnect()Runtime.collisionCapsuleHandler=nil end
	if origCamSub then Cam.CameraSubject,Cam.CameraType=origCamSub,origCamType or Enum.CameraType.Custom end
	if LP.Character and LP.Character:FindFirstChild("Humanoid")then LP.Character.Humanoid.AutoRotate=true end
	end
end

toggleFreecam=function(enabled)
	Flags.freecamEnabled=enabled
	if enabled then
		Runtime.freecamRestoreTP=Flags.tpEnabled
		if Flags.tpEnabled then toggleTP(false)end
		if not Runtime.freecamController then
			local ok,mod=pcall(function()
				local classes=RS:FindFirstChild("Classes")
				if not classes then return nil end
				return require(classes:WaitForChild("Freecam"))
			end)
			if ok and mod and mod.new then
				Runtime.freecamController=mod.new()
			else
				Flags.freecamEnabled=false
				if Runtime.freecamRestoreTP then
					Runtime.freecamRestoreTP=false
					toggleTP(true)
				end
				if Flags.debugMode then warn("[Freecam] Module not available")end
				return
			end
		end
		Runtime.freecamController:Start()
	else
		if Runtime.freecamController then
			Runtime.freecamController:Stop()
			local ok,camCtrl=pcall(function()
				return require(RS.Controllers.CameraController)
			end)
			if ok and camCtrl and camCtrl.setMouseEnabled then
				camCtrl.setMouseEnabled(true)
			end
		end
		if Runtime.freecamRestoreTP then
			Runtime.freecamRestoreTP=false
			toggleTP(true)
		end
	end
end

local function getFlashModule()
	if Runtime.flashModule then return Runtime.flashModule end
	local ok,mod=pcall(function()
		return require(RS.Components.Common.VFXLibary.FlashEffect)
	end)
	if ok and mod then Runtime.flashModule=mod end
	return Runtime.flashModule
end

local function clearFlashEffects()
	local pg=LP:FindFirstChild("PlayerGui")
	if pg then
		local fx=pg:FindFirstChild("FlashbangEffect")
		if fx then fx:Destroy()end
		local ss=pg:FindFirstChild("FlashScreenshot")
		if ss then ss:Destroy()end
	end
	local cc=Light:FindFirstChild("FlashbangColorCorrection")
	if cc then cc:Destroy()end
	for _,parent in ipairs({Cam,SoundService})do
		if parent then
			for _,s in ipairs(parent:GetChildren())do
				if s:IsA("Sound")and s.Name=="Flashed"then
					s:Stop()
					s:Destroy()
				end
			end
		end
	end
end

local function toggleNoFlash(enabled)
	Flags.noFlashEnabled=enabled
	local mod=getFlashModule()
	if not mod or type(mod)~="table"then
		Flags.noFlashEnabled=false
		return
	end
	if not Runtime.flashOriginal and mod.Flash then Runtime.flashOriginal=mod.Flash end
	if enabled then
		mod.Flash=function()end
		clearFlashEffects()
	elseif Runtime.flashOriginal then
		mod.Flash=Runtime.flashOriginal
	end
end

local function getVoxelSmokeModule()
	if Runtime.voxelSmokeModule then return Runtime.voxelSmokeModule end
	local ok,mod=pcall(function()
		return require(RS.Components.Common.VFXLibary.CreateVoxelSmoke)
	end)
	if ok and mod then
		Runtime.voxelSmokeModule=mod
		if not Runtime.voxelSmokeOriginal then
			Runtime.voxelSmokeOriginal={
				Create=mod.Create,
				Destroy=mod.Destroy,
				DestroyAll=mod.DestroyAll,
				Disrupt=mod.Disrupt
			}
		end
	end
	return Runtime.voxelSmokeModule
end

local function removeAllSmoke()
	local mod=getVoxelSmokeModule()
	if Runtime.voxelSmokeOriginal and Runtime.voxelSmokeOriginal.DestroyAll then
		pcall(function()Runtime.voxelSmokeOriginal.DestroyAll()end)
	elseif mod and mod.DestroyAll then
		pcall(function()mod.DestroyAll()end)
	end
	local debris=WS:FindFirstChild("Debris")
	if debris then
		for _,child in ipairs(debris:GetChildren())do
			if child:IsA("Folder")and child.Name:match("^VoxelSmoke_")then
				child:Destroy()
			end
		end
	end
end

local function toggleNoSmoke(enabled)
	Flags.noSmokeEnabled=enabled
	local mod=getVoxelSmokeModule()
	if not mod or type(mod)~="table"then
		if enabled then
			removeAllSmoke()
			if Runtime.noSmokeConn then Runtime.noSmokeConn:Disconnect()Runtime.noSmokeConn=nil end
			local debris=WS:FindFirstChild("Debris")
			if debris then
				Runtime.noSmokeConn=debris.ChildAdded:Connect(function(child)
					if not Flags.noSmokeEnabled then return end
					if child:IsA("Folder")and child.Name:match("^VoxelSmoke_")then
						child:Destroy()
					end
				end)
			end
		else
			if Runtime.noSmokeConn then Runtime.noSmokeConn:Disconnect()Runtime.noSmokeConn=nil end
		end
		return
	end
	if not Runtime.voxelSmokeOriginal then
		Runtime.voxelSmokeOriginal={
			Create=mod.Create,
			Destroy=mod.Destroy,
			DestroyAll=mod.DestroyAll,
			Disrupt=mod.Disrupt
		}
	end
	if enabled then
		mod.Create=function(...)
			if Runtime.voxelSmokeOriginal and Runtime.voxelSmokeOriginal.DestroyAll then
				pcall(function()Runtime.voxelSmokeOriginal.DestroyAll()end)
			end
			return nil
		end
		mod.Destroy=function(...)
			if Runtime.voxelSmokeOriginal and Runtime.voxelSmokeOriginal.DestroyAll then
				pcall(function()Runtime.voxelSmokeOriginal.DestroyAll()end)
			end
		end
		mod.DestroyAll=function(...)
			if Runtime.voxelSmokeOriginal and Runtime.voxelSmokeOriginal.DestroyAll then
				pcall(function()Runtime.voxelSmokeOriginal.DestroyAll()end)
			end
		end
		mod.Disrupt=function()end
		removeAllSmoke()
		if Runtime.noSmokeConn then Runtime.noSmokeConn:Disconnect()Runtime.noSmokeConn=nil end
		local debris=WS:FindFirstChild("Debris")
		if debris then
			Runtime.noSmokeConn=debris.ChildAdded:Connect(function(child)
				if not Flags.noSmokeEnabled then return end
				if child:IsA("Folder")and child.Name:match("^VoxelSmoke_")then
					child:Destroy()
				end
			end)
		end
	else
		if Runtime.noSmokeConn then Runtime.noSmokeConn:Disconnect()Runtime.noSmokeConn=nil end
		if Runtime.voxelSmokeOriginal then
			mod.Create=Runtime.voxelSmokeOriginal.Create
			mod.Destroy=Runtime.voxelSmokeOriginal.Destroy
			mod.DestroyAll=Runtime.voxelSmokeOriginal.DestroyAll
			mod.Disrupt=Runtime.voxelSmokeOriginal.Disrupt
		end
	end
end

local function ensureStatsBar()
	if statsText then return end
	statsText=Drawing.new("Text")
	statsText.Size=14
	statsText.Font=2
	statsText.Outline=true
	statsText.Color=themeLight
	statsText.Visible=false
end

local function updateStatsBar()
	if not Flags.statsBarEnabled then
		if statsText then statsText.Visible=false end
		return
	end
	ensureStatsBar()
	local team=getTeam(LP)or"Unknown"
	local hp=0
	if LP.Character and LP.Character:FindFirstChild("Humanoid")then
		hp=math.floor(LP.Character.Humanoid.Health)
	end
	local weapon=getPlayerWeaponName(LP)
	statsText.Text="Team: "..team.." | HP: "..hp.." | Weapon: "..weapon
	statsText.Position=Vector2.new(12,12)
	statsText.Visible=true
end

local function getWeaponNamesFromSkins()
	local raw=RS:GetAttribute("AvaiableSkins")
	if raw and raw~=""then
		local ok,decoded=pcall(function()return HTTP:JSONDecode(raw)end)
		if ok and type(decoded)=="table"then
			local names={}
			for weaponName,_ in pairs(decoded)do
				table.insert(names,weaponName)
			end
			table.sort(names)
			return names
		end
	end
	return {}
end

local function normalizeWeaponName(name)
	if not name or name==""then return "" end
	return tostring(name):lower():gsub("[%s%-%_]", "")
end

local function getWeaponPropertiesName(name)
	if not name or name==""then return nil end
	local db=RS:FindFirstChild("Database")
	if not db then return nil end
	local custom=db:FindFirstChild("Custom")
	if not custom then return nil end
	local weapons=custom:FindFirstChild("Weapons")
	if not weapons then return nil end
	local needle=normalizeWeaponName(name)
	for _,child in ipairs(weapons:GetChildren())do
		if child:IsA("ModuleScript")then
			if normalizeWeaponName(child.Name)==needle then
				return child.Name
			end
		end
	end
	return nil
end

local function getCameraAnimationsFolder(weaponName)
	local assets=RS:FindFirstChild("Assets")
	if not assets then return nil end
	local anims=assets:FindFirstChild("WeaponAnimations")
	if anims then
		local entry=anims:FindFirstChild(weaponName)
		if entry and entry:IsA("Folder")then
			local folder=entry:FindFirstChild("CameraAnimations")
			if folder and folder:IsA("Folder")then return folder end
		end
	end
	local weapons=assets:FindFirstChild("Weapons")
	if weapons then
		local weapon=weapons:FindFirstChild(weaponName)
		if weapon then
			local folder=weapon:FindFirstChild("CameraAnimations",true)
			if folder and folder:IsA("Folder")then return folder end
		end
	end
	return nil
end

local function attachSleevesToModel(model, sleeveKey)
	if not model or not sleeveKey then return end
	local assets=RS:FindFirstChild("Assets")
	if not assets then return end
	local sleeves=assets:FindFirstChild("Sleeves")
	if not sleeves then return end
	local src=sleeves:FindFirstChild(sleeveKey)
	if not src then return end
	for _,part in ipairs(model:GetDescendants())do
		if part:IsA("BasePart")then
			local existing=part:FindFirstChild("Sleeve")
			if existing then existing:Destroy()end
		end
	end
	for _,sleevePart in ipairs(src:GetChildren())do
		local target=model:FindFirstChild(sleevePart.Name, true)
		if target and target:IsA("BasePart")then
			local clone=sleevePart:Clone()
			clone.CastShadow=false
			clone.CanCollide=false
			clone.CanTouch=false
			clone.Anchored=false
			clone.CanQuery=false
			clone.Name="Sleeve"
			local sx=target.Size.X*1.3
			local sy=target.Size.Y*1.4
			local sz=target.Size.Z*0.79
			clone.Size=Vector3.new(sx,sy,sz)
			local zoff=target.Size.Z/2-clone.Size.Z/2
			local c1=CFrame.new(0,-0.02,-zoff)
			clone.Parent=target
			local weld=Instance.new("Motor6D")
			weld.Part0=target
			weld.Part1=clone
			weld.C0=CFrame.identity
			weld.C1=c1
			weld.Parent=clone
		end
	end
end

local function attachGlovesToModel(model, glovesModel)
	if not model or not glovesModel then return end
	for _,g in ipairs(glovesModel:GetChildren())do
		if g:IsA("BasePart")then
			local target=model:FindFirstChild(g.Name, true)
			if target and target:IsA("BasePart")then
				local clone=g:Clone()
				clone.CastShadow=false
				clone.CanCollide=false
				clone.CanTouch=false
				clone.Anchored=true
				clone.CanQuery=false
				clone.Name="Glove"
				local sx=target.Size.X*1.15
				local sy=target.Size.Y*1.18
				local sz=target.Size.Z*0.245
				clone.Size=Vector3.new(sx,sy,sz)
				local zoff=target.Size.Z/2-clone.Size.Z/2
				local c1=CFrame.new(0,0,-zoff*1.035)*clone.PivotOffset
				clone.Parent=target
				local weld=Instance.new("WeldConstraint",clone)
				weld.Part0=target
				weld.Part1=clone
				clone.CFrame=target.CFrame*c1
				clone.Anchored=false
			end
		end
	end
end

local function applyArmColors(model, character)
	if not model or not character then return end
	local bodyColors=character:FindFirstChild("Body Colors")
	if not bodyColors then return end
	local torsoColor=bodyColors.TorsoColor3
	for _,name in ipairs({"Right Arm","Left Arm"})do
		local part=model:FindFirstChild(name, true)
		if part and part:IsA("BasePart")then
			part.Color=torsoColor
		end
	end
end

local function getLightingEffect(className)
	local inst=Light:FindFirstChild(className)
	if not inst then
		inst=Instance.new(className)
	end
	inst.Name=className
	inst.Parent=Light
	return inst
end

local function applyWorldPreset(preset)
	local atmosphere=getLightingEffect("Atmosphere")
	local cc=getLightingEffect("ColorCorrectionEffect")
	local bloom=getLightingEffect("BloomEffect")
	local rays=getLightingEffect("SunRaysEffect")
	if preset=="Sakura" then
		Light.ClockTime=18.5
		Light.Brightness=2.2
		Light.Ambient=Color3.fromRGB(120,80,120)
		Light.OutdoorAmbient=Color3.fromRGB(170,120,190)
		atmosphere.Color=Color3.fromRGB(255,190,230)
		atmosphere.Decay=Color3.fromRGB(120,90,140)
		atmosphere.Density=0.35
		atmosphere.Haze=1.1
		cc.TintColor=Color3.fromRGB(255,210,235)
		cc.Contrast=0.08
		cc.Saturation=0.2
		bloom.Intensity=0.35
		bloom.Size=48
		bloom.Threshold=1.6
		rays.Intensity=0.08
		rays.Spread=0.9
	elseif preset=="Sunset" then
		Light.ClockTime=19.2
		Light.Brightness=2
		Light.Ambient=Color3.fromRGB(140,90,70)
		Light.OutdoorAmbient=Color3.fromRGB(200,140,90)
		atmosphere.Color=Color3.fromRGB(255,180,120)
		atmosphere.Decay=Color3.fromRGB(120,80,60)
		atmosphere.Density=0.32
		atmosphere.Haze=1
		cc.TintColor=Color3.fromRGB(255,210,170)
		cc.Contrast=0.12
		cc.Saturation=0.18
		bloom.Intensity=0.3
		bloom.Size=40
		bloom.Threshold=1.7
		rays.Intensity=0.07
		rays.Spread=0.85
	end
end
local function copySleevesFromModel(oldModel,newModel)
	if not oldModel or not newModel then return end
	for _,oldPart in ipairs(oldModel:GetDescendants())do
		if oldPart:IsA("BasePart")then
			local oldSleeve=oldPart:FindFirstChild("Sleeve")
			if oldSleeve and oldSleeve:IsA("BasePart")then
				local target=newModel:FindFirstChild(oldPart.Name,true)
				if target and target:IsA("BasePart")then
					local clone=oldSleeve:Clone()
					for _,d in ipairs(clone:GetDescendants())do
						if d:IsA("Motor6D")or d:IsA("Weld")or d:IsA("WeldConstraint")then
							d:Destroy()
						end
					end
					clone.Parent=target
					local c0,c1=CFrame.identity,CFrame.identity
					local oldMotor=oldSleeve:FindFirstChildWhichIsA("Motor6D")
					if oldMotor then
						c0=oldMotor.C0
						c1=oldMotor.C1
					end
					local weld=Instance.new("Motor6D")
					weld.Part0=target
					weld.Part1=clone
					weld.C0=c0
					weld.C1=c1
					weld.Parent=clone
				end
			end
		end
	end
end

local function copyGlovesFromModel(oldModel,newModel)
	if not oldModel or not newModel then return end
	for _,oldPart in ipairs(oldModel:GetDescendants())do
		if oldPart:IsA("BasePart")then
			local oldGlove=oldPart:FindFirstChild("Glove")
			if oldGlove and oldGlove:IsA("BasePart")then
				local target=newModel:FindFirstChild(oldPart.Name,true)
				if target and target:IsA("BasePart")then
					local clone=oldGlove:Clone()
					for _,d in ipairs(clone:GetDescendants())do
						if d:IsA("Motor6D")or d:IsA("Weld")or d:IsA("WeldConstraint")then
							d:Destroy()
						end
					end
					clone.Parent=target
					local c0,c1=CFrame.identity,CFrame.identity
					local oldMotor=oldGlove:FindFirstChildWhichIsA("Motor6D")
					if oldMotor then
						c0=oldMotor.C0
						c1=oldMotor.C1
					end
					local weld=Instance.new("WeldConstraint")
					weld.Part0=target
					weld.Part1=clone
					weld.Parent=clone
					clone.CFrame=target.CFrame*c1
				end
			end
		end
	end
end

local function resolveWeaponNameFromSkins(name)
	if not name or name==""then return name end
	local names=getWeaponNamesFromSkins()
	local needle=normalizeWeaponName(name)
	for _,n in ipairs(names)do
		if normalizeWeaponName(n)==needle then
			return n
		end
	end
	return name
end

local function getInventoryWeaponNames()
	local available=getWeaponNamesFromSkins()
	local availableSet={}
	for _,name in ipairs(available)do
		availableSet[name]=true
	end
	local namesSet={}
	local okInv,InventoryController=pcall(function()
		return require(RS.Controllers.InventoryController)
	end)
	if okInv and InventoryController then
		local inv=InventoryController.getCurrentInventory()
		if type(inv)=="table"then
			for _,slot in pairs(inv)do
				if type(slot)=="table"and type(slot._items)=="table"then
					for _,item in pairs(slot._items)do
						if type(item)=="table"then
							local cand=item.Weapon or item.Name or item.Identifier or item.Item or item.Id or item.WeaponName or item.TypeName
							if cand then
								local resolved=resolveWeaponNameFromSkins(cand)
								local isKnife=item.Type=="Knife"or item.Type=="Melee"or item.Class=="Melee"
								if availableSet[resolved]or isKnife then
									namesSet[resolved]=true
								end
							end
						end
					end
				end
			end
		end
	end
	if next(namesSet)==nil then
		local ok,DataController=pcall(function()
			return require(RS.Controllers.DataController)
		end)
		if ok and DataController then
			local inv=DataController.Get(LP,"Inventory")
			if type(inv)=="table"then
				for _,item in ipairs(inv)do
					if type(item)=="table"then
						local cand=item.Weapon or item.Name or item.Identifier or item.Item or item.Id or item.WeaponName or item.TypeName
						if item.Type=="Weapon"or item.Type=="Melee"or item.Type=="Knife"then
							cand=cand or item.TypeName
						end
						if cand then
							local resolved=resolveWeaponNameFromSkins(cand)
							local isKnife=item.Type=="Knife"or item.Type=="Melee"or item.Class=="Melee"
							if availableSet[resolved]or isKnife then
								namesSet[resolved]=true
							end
						end
					end
				end
			end
		end
	end
	local names={}
	for name,_ in pairs(namesSet)do
		table.insert(names,name)
	end
	table.sort(names)
	return names
end

local function getAvailableWeapons()
	local invNames=getInventoryWeaponNames()
	if #invNames>0 then return invNames end
	local skinNames=getWeaponNamesFromSkins()
	if #skinNames>0 then return skinNames end
	local ok,assets=pcall(function()
		return RS:WaitForChild("Assets"):WaitForChild("Weapons")
	end)
	if not ok or not assets then return {} end
	local names={}
	for _,child in ipairs(assets:GetChildren())do
		if child:IsA("Folder")then
			table.insert(names,child.Name)
		end
	end
	table.sort(names)
	return names
end

local function getEquippedWeaponName()
	local success,result=pcall(function()
		local InventoryController=require(RS.Controllers.InventoryController)
		return InventoryController.getCurrentEquipped()
	end)
	if success and result and result.Identifier then
		return result.Identifier
	end
	if LP.Character then
		for _,tool in ipairs(LP.Character:GetChildren())do
			if tool:IsA("Tool")then return tool.Name end
		end
	end
	return nil
end

local function getAvailableSkinsForWeapon(weaponName)
	if not weaponName or weaponName==""then return {} end
	local raw=RS:GetAttribute("AvaiableSkins")
	if not raw or raw==""then return {} end
	local ok,decoded=pcall(function()return HTTP:JSONDecode(raw)end)
	if not ok or type(decoded)~="table"then return {} end
	local weaponSkins=decoded[weaponName]
	if type(weaponSkins)~="table"then return {} end
	local names={}
	for skinName,_ in pairs(weaponSkins)do
		table.insert(names,skinName)
	end
	table.sort(names)
	return names
end

local function getKnifeEntries()
	local entries={}
	local okInv,InventoryController=pcall(function()
		return require(RS.Controllers.InventoryController)
	end)
	if not okInv or not InventoryController then return entries end
	local inv=InventoryController.getCurrentInventory()
	if type(inv)~="table"then return entries end
	for slotKey,slot in pairs(inv)do
		if type(slot)=="table"and type(slot._items)=="table"then
			for idx,item in pairs(slot._items)do
				if type(item)=="table"then
					local isKnife=item.Type=="Knife"or item.Type=="Melee"or item.Class=="Melee"
					if isKnife then
						local name=item.Name or item.Weapon or item.Identifier or item.Item or item.Id or item.WeaponName or item.TypeName
						if name then
							entries[normalizeWeaponName(name)]={name=name,slot=slotKey,index=idx}
						end
					end
				end
			end
		end
	end
	return entries
end

local function equipSelectedKnife(entries)
	local knifeName=selectedKnifeName
	if type(UI.knifeDropdown)=="table"and UI.knifeDropdown.GetValue then
		local v=UI.knifeDropdown:GetValue()
		if v and v~=""and v~="No Knives"then knifeName=v end
	end
	local okInv,InventoryController=pcall(function()
		return require(RS.Controllers.InventoryController)
	end)
	if not okInv or not InventoryController then return end
	local equipped=InventoryController.getCurrentEquipped()
	if not equipped then return end
	local isKnife=false
	if equipped.Properties and equipped.Properties.Class=="Melee"then isKnife=true end
	local ename=(equipped.Name or equipped.Identifier or "")
	if string.find(ename,"Knife")then isKnife=true end
	if not isKnife then return end
	local okSkins,Skins=pcall(function()
		return require(RS.Database.Components.Libraries.Skins)
	end)
	if not okSkins or not Skins then return end
	local camModel=Skins.GetCameraModel(knifeName,equipped.Skin)
	if not camModel then
		camModel=Skins.GetBaseWeaponModel(knifeName,"Camera")
	end
	if Flags.debugMode then
		print("[Knife] Selected:",knifeName,"CamModel:",camModel and camModel.Name or "nil")
	end
	if not camModel then return end
	if equipped.Viewmodel and equipped.Viewmodel.Model then
		local oldModel=equipped.Viewmodel.Model
		camModel.Name=knifeName
		camModel.Parent=game:GetService("ReplicatedFirst")
		for _,bp in ipairs(camModel:GetDescendants())do
			if bp:IsA("BasePart")then
				bp.CollisionGroup="Viewmodel"
				bp.CanCollide=false
				bp.CastShadow=false
				bp.CanQuery=true
				bp.CanTouch=false
				if bp.Name=="HumanoidRootPart"or bp.Name=="ViewmodelLight"then
					bp.Transparency=1
				end
			end
		end
		if equipped.Viewmodel.IsEquipped then
			camModel.Parent=workspace.CurrentCamera
		end
		equipped.Viewmodel.Model=camModel
		copyGlovesFromModel(oldModel,camModel)
		local glovesAttr=nil
		if LP.Character then
			glovesAttr=LP.Character:GetAttribute("EquippedGloves")
		end
		if not glovesAttr then
			glovesAttr=LP:GetAttribute("EquippedGloves")
		end
		if glovesAttr then
			local ok,gloveData=pcall(function()return HTTP:JSONDecode(glovesAttr)end)
			if ok and gloveData and gloveData.SkinIdentifier then
				local okS,Skins2=pcall(function()return require(RS.Database.Components.Libraries.Skins)end)
				if okS and Skins2 then
					local name,skin=gloveData.SkinIdentifier:match("^(.*)_(.*)$")
					if name and skin then
						local gm=Skins2.GetGloves(name,skin,0)
						if gm then
							attachGlovesToModel(camModel,gm)
							gm:Destroy()
						end
					end
				end
			end
		end
		if equipped.Viewmodel.attachSleeves then
			local team=LP:GetAttribute("Team")
			local sleeveKey=nil
			if team=="Counter-Terrorists" then
				sleeveKey=workspace:GetAttribute("CTCharacter")
			elseif team=="Terrorists" then
				sleeveKey=workspace:GetAttribute("TCharacter")
			end
			if sleeveKey then
				pcall(function()equipped.Viewmodel:attachSleeves(sleeveKey)end)
				if Flags.debugMode then
					local ra=camModel:FindFirstChild("Right Arm",true)
					local la=camModel:FindFirstChild("Left Arm",true)
					print("[Knife] Sleeve arms:",ra and ra.Name or "nil",la and la.Name or "nil")
				end
				local hasSleeve=false
				for _,part in ipairs(camModel:GetDescendants())do
					if part:IsA("BasePart")and part:FindFirstChild("Sleeve")then
						hasSleeve=true
						break
					end
				end
				if not hasSleeve then
					attachSleevesToModel(camModel,sleeveKey)
				end
			end
		end
		if LP.Character then
			applyArmColors(camModel,LP.Character)
		end
		pcall(function()camModel:ScaleTo(0.1)end)
		if equipped.Viewmodel.Bobble and equipped.Viewmodel.Bobble.setModel then
			pcall(function()equipped.Viewmodel.Bobble:setModel(camModel)end)
		end
		local okSound,Sound=pcall(function()return require(RS.Classes.Sound)end)
		if okSound and Sound then
			if equipped.Viewmodel.Sound and equipped.Viewmodel.Sound.destroy then
				pcall(function()equipped.Viewmodel.Sound:destroy()end)
			end
			local okNew,newSound=pcall(function()return Sound.new(selectedKnifeName)end)
			if okNew and newSound then
				equipped.Viewmodel.Sound=newSound
			end
		end
		local animObj=equipped.Viewmodel.Animation
		local animator=nil
		local ac=camModel:FindFirstChildWhichIsA("AnimationController",true)
		if not ac then
			ac=Instance.new("AnimationController")
			ac.Name="AnimationController"
			ac.Parent=camModel
		end
		animator=ac:FindFirstChildWhichIsA("Animator",true)
		if not animator then
			animator=Instance.new("Animator")
			animator.Parent=ac
		end
		if animObj then animObj.Animator=animator end
		if animObj and animator then
			animObj.Animation=selectedKnifeName
			for _,track in pairs(animObj.Animations)do
				if track and track.Stop then pcall(function()track:Stop()end)end
			end
			animObj.Animations={}
			local folder=getCameraAnimationsFolder(selectedKnifeName)
			if Flags.debugMode then
				print("[Knife] AnimFolder:",folder and folder:GetFullName() or "nil")
			end
			if folder then
				local count=0
				for _,anim in ipairs(folder:GetChildren())do
					if anim:IsA("Animation")then
						local ok,track=pcall(function()return animator:LoadAnimation(anim)end)
						if ok and track then
							animObj.Animations[anim.Name]=track
							count=count+1
						end
					end
				end
				if Flags.debugMode then
					print("[Knife] Loaded animations:",count)
				end
			end
			local idle=animObj.Animations["Idle"]
			if Flags.debugMode then
				print("[Knife] Idle track:",idle and idle.Name or "nil")
			end
			if idle then
				pcall(function()
					idle.Looped=true
					idle:Stop()
				end)
			end
		end
		pcall(function()equipped.Viewmodel:equip(true)end)
		if animObj then
			animObj.CurrentAnimation="Idle"
			if animObj.Animations and animObj.Animations.Idle then
				pcall(function()animObj.Animations.Idle:Play()end)
				if Flags.debugMode then
					print("[Knife] Idle playing:",animObj.Animations.Idle.IsPlaying)
					if animObj.Animator and animObj.Animator.GetPlayingAnimationTracks then
						print("[Knife] Playing tracks:",#animObj.Animator:GetPlayingAnimationTracks())
					end
				end
			end
		end
		pcall(function()oldModel:Destroy()end)
	end
end

local function getKnifeList()
	local names={}
	local okScore,Score=pcall(function()
		return require(RS.Database.Custom.GameStats.Score)
	end)
	if okScore and Score and Score.Knife then
		for _,name in ipairs(Score.Knife)do
			table.insert(names,name)
		end
	end
	if #names==0 then
		names={
			"CT Knife","T Knife","Butterfly Knife","Flip Knife","Gut Knife","Karambit","M9 Bayonet","Bayonet","Bowie Knife","Falchion Knife",
			"Huntsman Knife","Navaja Knife","Paracord Knife","Shadow Daggers","Skeleton Knife","Stiletto Knife","Survival Knife","Talon Knife",
			"Ursus Knife","Classic Knife","Nomad Knife","Kukri Knife"
		}
	end
	local assets=RS:FindFirstChild("Assets")
	local weapons=assets and assets:FindFirstChild("Weapons")
	local filtered={}
	for _,name in ipairs(names)do
		if weapons and weapons:FindFirstChild(name)then
			table.insert(filtered,name)
		end
	end
	table.sort(filtered)
	return filtered
end

local function isKnifeWeapon(name)
	if not name or name==""then return false end
	local list=getKnifeList()
	for _,n in ipairs(list)do
		if n==name then return true end
	end
	return false
end

local function getKnifePageOptions()
	local list=getKnifeList()
	local total=#list
	if total==0 then return {"No Knives"},1,1 end
	local maxPage=math.max(1,math.ceil(total/KNIFE_PAGE_SIZE))
	knifePage=math.clamp(knifePage,1,maxPage)
	local startIndex=(knifePage-1)*KNIFE_PAGE_SIZE+1
	local endIndex=math.min(startIndex+KNIFE_PAGE_SIZE-1,total)
	local options={}
	for i=startIndex,endIndex do
		table.insert(options,list[i])
	end
	return options,knifePage,maxPage
end

local function getLocalTeamKey()
	local t=nil
	if LP and LP.Team then
		t=LP.Team.Name
	end
	if (not t or t=="")and LP then
		t=LP:GetAttribute("Team")
	end
	return t
end

local function getTeamSkinKey(weaponName)
	if not weaponName or weaponName==""then return weaponName end
	local t=getLocalTeamKey()
	if t and t~=""then
		return t.."|"..weaponName
	end
	return weaponName
end

local function getSkinKeyForSelection()
	local key=selectedWeaponName
	if isKnifeWeapon(key)and selectedKnifeName and selectedKnifeName~=""then
		key=selectedKnifeName
	end
	return getTeamSkinKey(key)
end

local function setSkinSelection(key,skin)
	if not key or key==""or not skin or skin==""or skin=="No Options"then return end
	if type(skinSelections)~="table"then skinSelections={}end
	skinSelections[key]=skin
end

local function applySurfaceAppearances(targetModel,sourceModel)
	if not targetModel or not sourceModel then return 0 end
	local sourcePartsByName={}
	local sourcePartsByMesh={}
	for _,part in ipairs(sourceModel:GetDescendants())do
		if part:IsA("MeshPart")then
			local sa=part:FindFirstChildOfClass("SurfaceAppearance")
			if sa then
				sourcePartsByName[part.Name]=sa
				if part.MeshId and part.MeshId~=""then
					sourcePartsByMesh[part.MeshId]=sa
				end
			end
		end
	end
	local applied=0
	for _,part in ipairs(targetModel:GetDescendants())do
		if part:IsA("MeshPart")then
			local src=nil
			if part.MeshId and part.MeshId~=""then
				src=sourcePartsByMesh[part.MeshId]
			end
			if not src then
				src=sourcePartsByName[part.Name]
			end
			if src then
				local existing=part:FindFirstChildOfClass("SurfaceAppearance")
				if existing then existing:Destroy()end
				src:Clone().Parent=part
				applied=applied+1
			end
		end
	end
	return applied
end

local function getTargetWeaponModels(weaponName)
	local models={}
	local function addModel(m)
		if m and (m:IsA("Model")or m:IsA("Tool"))then
			table.insert(models,m)
		end
	end
	if LP.Character then
		addModel(LP.Character:FindFirstChild("WeaponModel"))
		for _,tool in ipairs(LP.Character:GetChildren())do
			if tool:IsA("Tool")then addModel(tool)end
		end
	end
	local debris=WS:FindFirstChild("Debris")
	if debris then
		addModel(debris:FindFirstChild(LP.Name.."_Weapon"))
	end
	if Cam then
		addModel(Cam:FindFirstChild("WeaponModel"))
		addModel(Cam:FindFirstChild("ViewModel"))
	end
	local function addByAttr(container)
		if not container then return end
		for _,desc in ipairs(container:GetDescendants())do
			if (desc:IsA("Model")or desc:IsA("Tool"))and desc:GetAttribute("Weapon")==weaponName then
				addModel(desc)
			end
		end
	end
	addByAttr(LP.Character)
	addByAttr(debris)
	addByAttr(Cam)
	return models
end

function SkinUtil.getSkinsModule()
	local ok,Skins=pcall(function()
		return require(RS.Database.Components.Libraries.Skins)
	end)
	if ok and Skins then return Skins end
	return nil
end

function SkinUtil.applySkinToEquipped(Skins,weaponName,skinName)
	local okInv,InventoryController=pcall(function()
		return require(RS.Controllers.InventoryController)
	end)
	if not okInv or not InventoryController then return false end
	local equipped=InventoryController.getCurrentEquipped()
	if not equipped then return false end
	local equippedName=equipped.Name or equipped.Identifier
	local props=equipped.Properties
	local isEquippedKnife=props and props.Class=="Melee"
	local matchName=normalizeWeaponName(equippedName)==normalizeWeaponName(weaponName)
	local allowKnifeSkin=isEquippedKnife and isKnifeWeapon(weaponName)
	if not (matchName or allowKnifeSkin) then return false end
	equipped.Skin=skinName
	local viewmodel=equipped.Viewmodel
	local viewModel=viewmodel and viewmodel.Model
	if viewModel then
		local camModel=Skins.GetCameraModel(weaponName,skinName)or Skins.GetCharacterModel(weaponName,skinName)
		if camModel then
			applySurfaceAppearances(viewModel,camModel)
			camModel:Destroy()
		end
	end
	local debris=WS:FindFirstChild("Debris")
	if debris then
		local wepModel=debris:FindFirstChild(LP.Name.."_Weapon")
		if wepModel and wepModel:IsA("Model")then
			local worldModel=Skins.GetWorldModel(weaponName,skinName)or Skins.GetCharacterModel(weaponName,skinName)
			if worldModel then
				applySurfaceAppearances(wepModel,worldModel)
				worldModel:Destroy()
			end
		end
	end
	return true
end

function SkinUtil.getSkinSources(Skins,weaponName,skinName)
	local sources={}
	local cam=Skins.GetCameraModel(weaponName,skinName)
	if cam then table.insert(sources,cam)end
	local char=Skins.GetCharacterModel(weaponName,skinName)
	if char then table.insert(sources,char)end
	local world=Skins.GetWorldModel(weaponName,skinName)
	if world then table.insert(sources,world)end
	return sources
end

function SkinUtil.destroySkinSources(sources)
	for _,src in ipairs(sources)do
		if src then src:Destroy()end
	end
end

function SkinUtil.applySkinSourcesToTargets(weaponName,sources)
	local targets=getTargetWeaponModels(weaponName)
	for _,target in ipairs(targets)do
		local applied=0
		for _,src in ipairs(sources)do
			if src then
				applied=applied+applySurfaceAppearances(target,src)
				if applied>0 then break end
			end
		end
	end
end

function SkinUtil.applyClientSkin(weaponName,skinName)
	if not weaponName or weaponName==""or not skinName or skinName==""then return end
	if weaponName=="No Weapons"or skinName=="No Options"then return end
	weaponName=resolveWeaponNameFromSkins(weaponName)
	local Skins=SkinUtil.getSkinsModule()
	if not Skins then return end
	if SkinUtil.applySkinToEquipped(Skins,weaponName,skinName)then return end
	local sources=SkinUtil.getSkinSources(Skins,weaponName,skinName)
	if #sources==0 then return end
	SkinUtil.applySkinSourcesToTargets(weaponName,sources)
	SkinUtil.destroySkinSources(sources)
end

local function clearSkinControls()
	for _,ctrl in ipairs(skinControls)do
		pcall(function()
			if typeof(ctrl)=="Instance"then
				ctrl:Destroy()
			elseif type(ctrl)=="table"and ctrl.Destroy then
				ctrl:Destroy()
			end
		end)
	end
	skinControls={}
end

local function trackSkinControl(ctrl)
	if ctrl then table.insert(skinControls,ctrl)end
	return ctrl
end

local function refreshSkinLists()
	if refreshingSkins then return end
	if not UI.miscTab then return end
	refreshingSkins=true
	pcall(function()
		local weapons=getAvailableWeapons()
		if #weapons==0 then weapons={"No Weapons"}end
		local equipped=getEquippedWeaponName()
		if equipped then
			local found=false
			for _,name in ipairs(weapons)do
				if name==equipped then
					selectedWeaponName=equipped
					found=true
					break
				end
			end
			if not found and not selectedWeaponName then
				selectedWeaponName=weapons[1]
			end
		end
		local hasSelected=false
		for _,name in ipairs(weapons)do
			if name==selectedWeaponName then
				hasSelected=true
				break
			end
		end
		if not selectedWeaponName or selectedWeaponName==""or not hasSelected then
			selectedWeaponName=weapons[1]
		end
		local weaponForSkins=selectedWeaponName
		if isKnifeWeapon(weaponForSkins)and selectedKnifeName and selectedKnifeName~=""then
			weaponForSkins=selectedKnifeName
		end
		local skins=getAvailableSkinsForWeapon(weaponForSkins)
		if #skins==0 then skins={"No Options"}end
		local hasSkin=false
		for _,name in ipairs(skins)do
			if name==selectedSkinName then
				hasSkin=true
				break
			end
		end
		if not selectedSkinName or selectedSkinName==""or not hasSkin then
			selectedSkinName=skins[1]
		end
		local skinKey=getSkinKeyForSelection()
		local savedSkin=skinSelections[skinKey] or skinSelections[weaponForSkins]
		if savedSkin then
			for _,name in ipairs(skins)do
				if name==savedSkin then
					selectedSkinName=savedSkin
					break
				end
			end
		end
		local knifeEntries=getKnifeEntries()
		local knifeOptions,curPage,maxPage=getKnifePageOptions()
		local knifeSelected=false
		for _,n in ipairs(knifeOptions)do
			if n==selectedKnifeName then knifeSelected=true break end
		end
		if not selectedKnifeName or selectedKnifeName==""or not knifeSelected then
			selectedKnifeName=knifeOptions[1]
		end
		if not UI.skinWeaponDropdown then
			trackSkinControl(UI.miscTab.AddLabel({text="Skins"}))
			UI.skinWeaponDropdown=trackSkinControl(UI.miscTab.AddDropdown({options=weapons,callback=function(v)
				if refreshingSkins then return end
				selectedWeaponName=v
				task.defer(refreshSkinLists)
			end}))
			UI.skinDropdown=trackSkinControl(UI.miscTab.AddDropdown({options=skins,callback=function(v)
				selectedSkinName=v
				setSkinSelection(getSkinKeyForSelection(),v)
			end}))
			trackSkinControl(UI.miscTab.AddButton({text="Refresh List",callback=function()task.defer(refreshSkinLists)end}))
			trackSkinControl(UI.miscTab.AddButton({text="Apply Skin",callback=function()
				local w=selectedWeaponName
				if isKnifeWeapon(w)and selectedKnifeName and selectedKnifeName~=""then
					w=selectedKnifeName
				end
				setSkinSelection(getSkinKeyForSelection(),selectedSkinName)
				SkinUtil.applyClientSkin(w,selectedSkinName)
			end}))
			trackSkinControl(UI.miscTab.AddDivider())
			trackSkinControl(UI.miscTab.AddLabel({text="Knives"}))
			UI.knifeDropdown=trackSkinControl(UI.miscTab.AddDropdown({options=knifeOptions,callback=function(v)selectedKnifeName=v end}))
			trackSkinControl(UI.miscTab.AddButton({text="Prev Knives",callback=function()
				knifePage=knifePage-1
				refreshSkinLists()
			end}))
			trackSkinControl(UI.miscTab.AddButton({text="Next Knives",callback=function()
				knifePage=knifePage+1
				refreshSkinLists()
			end}))
			UI.knifePageLabel=trackSkinControl(UI.miscTab.AddLabel({text="Page "..curPage.." / "..maxPage}))
			trackSkinControl(UI.miscTab.AddButton({text="Equip Knife",callback=function()equipSelectedKnife(knifeEntries)end}))
		else
			if type(UI.skinWeaponDropdown)=="table"and UI.skinWeaponDropdown.SetOptions then UI.skinWeaponDropdown:SetOptions(weapons,selectedWeaponName)end
			if type(UI.skinDropdown)=="table"and UI.skinDropdown.SetOptions then UI.skinDropdown:SetOptions(skins,selectedSkinName)end
			if type(UI.knifeDropdown)=="table"and UI.knifeDropdown.SetOptions then UI.knifeDropdown:SetOptions(knifeOptions,selectedKnifeName)end
			if UI.knifePageLabel and UI.knifePageLabel.FindFirstChildOfClass then
				local lbl=UI.knifePageLabel:FindFirstChildOfClass("TextLabel")
				if lbl then lbl.Text="Page "..curPage.." / "..maxPage end
			end
		end
	end)
	refreshingSkins=false
end

spawn(function()
	local s,BC=pcall(function()return require(RS:WaitForChild("Components"):WaitForChild("Weapon"):WaitForChild("Classes"):WaitForChild("Bullet"))end)
	if not s then return end
	local origPR=BC._performRaycast
	BC._performRaycast=function(self,spread)
		if SA.Enabled then
			if SA.HitChance and SA.HitChance<100 then
				if math.random(1,100)>SA.HitChance then
					return origPR(self,spread)
				end
			end
			local tp=getSAPos()
			if tp then
				local GRI,RC=require(RS.Components.Common.GetRayIgnore),require(RS.Shared.Raycast)
				local org,dir=Cam.CFrame.Position,(tp-Cam.CFrame.Position).Unit
				if SA.ShowTracers then createTracer(org,tp)end
				local bd={Origin=org,Direction=dir,Distance=0,Hits={}}
				local res=RC.cast(org,dir*math.min((tp-org).Magnitude+10,self.Properties.Range or 500),nil,GRI())
				if not res.instance then bd.Distance=self.Properties.Range or 500 return bd end
				bd.Distance=(res.position-org).Magnitude
				local pen=(self.Properties.Penetration or 0)
				if SA.WallbangCheck then
					local power=SA.WallbangPower or 1
					if power<99999 then power=99999 end
					if power>0 then pen=pen*power end
				end
				local tr=RC.castThrough(res.position-dir*0.001,dir*(pen+0.001),pen,GRI())
				for idx,ht in ipairs(tr)do
					if ht.instance and ht.material then
						table.insert(bd.Hits,{Position=ht.position,Instance=ht.instance,Material=ht.material.Name,Normal=ht.normal or Vector3.new(0,0,0),Exit=idx%2==0})
					end
				end
				return bd
			end
		end
		local res=origPR(self,spread)
		if SA.WallbangCheck and self and self.Properties and res and res.Origin and res.Direction then
			local dir=res.Direction
			if typeof(dir)~="Vector3"then return res end
			if dir.Magnitude<=0 then return res end
			dir=dir.Unit
			local GRI,RC=require(RS.Components.Common.GetRayIgnore),require(RS.Shared.Raycast)
			local org=res.Origin
			local maxDistance=self.Properties.Range or res.Distance or 500
			local pen=(self.Properties.Penetration or 0)
			local power=SA.WallbangPower or 1
			if power<99999 then power=99999 end
			if power>0 then pen=pen*power end
			local bd={Origin=org,Direction=dir,Distance=0,Hits={}}
			local castRes=RC.cast(org,dir*maxDistance,nil,GRI())
			if not castRes.instance then
				bd.Distance=maxDistance
				table.insert(bd.Hits,{Distance=maxDistance,Instance=nil,Position=org+dir*maxDistance,Normal=Vector3.new(0,1,0),Material="Air",Exit=false})
				return bd
			end
			bd.Distance=(castRes.position-org).Magnitude
			local tr=RC.castThrough(castRes.position-dir*0.001,dir*(pen+0.001),pen,GRI())
			for idx,ht in ipairs(tr)do
				if ht.instance and ht.material then
					table.insert(bd.Hits,{
						Distance=(ht.position-org).Magnitude,
						Position=ht.position,
						Instance=ht.instance,
						Material=ht.material.Name,
						Normal=ht.normal or Vector3.new(0,0,0),
						Exit=idx%2==0
					})
				end
			end
			if #bd.Hits==0 then
				local matName="Plastic"
				if castRes.material then matName=castRes.material.Name end
				table.insert(bd.Hits,{
					Distance=bd.Distance,
					Position=castRes.position,
					Instance=castRes.instance,
					Material=matName,
					Normal=castRes.normal or Vector3.new(0,1,0),
					Exit=false
				})
			end
			return bd
		end
		return res
	end
	local origGetSpread,origGetBaseSpread,origGetTrueSpread=BC.getSpread,BC.getBaseSpread,BC.getTrueSpread
	BC.getSpread=function(self)if SA.NoSpread then return 0 end return origGetSpread(self)end
	BC.getBaseSpread=function(self)if SA.NoSpread then return 0 end return origGetBaseSpread(self)end
	BC.getTrueSpread=function(self)if SA.NoSpread then return 0 end return origGetTrueSpread(self)end
end)

spawn(function()
	task.wait(2)
	pcall(function()
		local CameraController=require(RS.Controllers.CameraController)
		local origSetWeaponRecoil=CameraController.setWeaponRecoil
		CameraController.setWeaponRecoil=function(...)if SA.NoRecoil then return end return origSetWeaponRecoil(...)end
		local origWeaponKick=CameraController.weaponKick
		CameraController.weaponKick=function(...)if SA.NoRecoil then return end return origWeaponKick(...)end
	end)
end)

local success,RoSense=pcall(function()
	local localPath="Ui.lua"
	if readfile then
		local ok,src=pcall(function()return readfile(localPath)end)
		if ok and src and src~=""then
			local fn=loadstring(src)
			if fn then return fn()end
		end
	end
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/v0qh/LuauScripts/refs/heads/main/RoSense.lua"))()
end)
if not success or not RoSense then return end
RoSense:Init()

local function unloadCheat()
	pcall(function()
		if Flags.spinbotEnabled then toggleSpinbot(false)end
		if Flags.autoShootEnabled then toggleAutoShoot(false)end
		if Flags.bhopEnabled then toggleBhop(false)end
		if Flags.freecamEnabled then toggleFreecam(false)end
		if Flags.noFlashEnabled then toggleNoFlash(false)end
		if Flags.noSmokeEnabled then toggleNoSmoke(false)end
		Flags.instantCrouchEnabled=false
		Flags.walkSpeedEnabled=false
		Flags.fastClimbEnabled=false
		Flags.meleeRangeEnabled=false
		Flags.fastReloadEnabled=false
		Flags.customFovEnabled=false
		WeaponUtil.applyWeaponTweaksToInventory()
		WeaponUtil.applyCameraFov(true)
		for _,g in pairs(game.CoreGui:GetChildren())do
			if g:IsA("ScreenGui")and(g.Name=="X9Hub"or string.find(g.Name,"InvESP_")or g.Name=="SAGUI")then g:Destroy()end
		end
		if SAGUI and SAGUI.TargetBox then SAGUI.TargetBox:Remove()end
		SAGUI=nil
		if statsText then statsText:Remove()statsText=nil end
		clearSATracers()
		for p in pairs(DrawObjs)do removeESP(p)end
		for m in pairs(DroppedWeps)do removeDropESP(m)end
		FOV:Remove()
		if tpUpdateConn then tpUpdateConn:Disconnect()end
		if tpVisLoop then tpVisLoop:Disconnect()end
		if tpDescendantConn then tpDescendantConn:Disconnect()end
		if Runtime.collisionCapsuleHandler then Runtime.collisionCapsuleHandler:Disconnect()end
		if Runtime.spinbotConnection then Runtime.spinbotConnection:Disconnect()Runtime.spinbotConnection=nil end
		if Runtime.autoShootConnection then Runtime.autoShootConnection:Disconnect()end
		if Runtime.bhopConnection then Runtime.bhopConnection:Disconnect()end
		if origCamSub then Cam.CameraSubject,Cam.CameraType=origCamSub,origCamType or Enum.CameraType.Custom end
		if LP.Character and LP.Character:FindFirstChild("Humanoid")then LP.Character.Humanoid.AutoRotate=true end
	end)
end

local configFolder="BloxStrikeConfigs"
local selectedConfigName=nil
local autoLoadConfigName=nil

function ConfigUtil.hasConfigApi()
	return type(writefile)=="function"and type(readfile)=="function"and type(isfile)=="function"and type(makefolder)=="function"and type(listfiles)=="function"and type(delfile)=="function"
end

function ConfigUtil.ensureConfigFolder()
	if not ConfigUtil.hasConfigApi()then return false end
	if type(isfolder)=="function"and isfolder(configFolder)then return true end
	pcall(function()makefolder(configFolder)end)
	if type(isfolder)=="function"then
		return isfolder(configFolder)
	end
	return true
end

function ConfigUtil.getConfigPath(name)
	return configFolder.."/"..name..".json"
end

function ConfigUtil.listConfigs()
	if not ConfigUtil.ensureConfigFolder()then return {} end
	local ok,files=pcall(function()return listfiles(configFolder)end)
	if not ok or not files then return {} end
	local names={}
	for _,p in ipairs(files)do
		local n=p:match("([^/\\]+)%.json$")
		if n then table.insert(names,n)end
	end
	table.sort(names)
	if #names == 0 then
		return {"No Configs"}
	end
	return names
end


function ConfigUtil.buildConfigData()
	local saCopy={}
	for k,v in pairs(SA)do
		saCopy[k]=v
	end
	return {
		SA=saCopy,
		autoShootEnabled=Flags.autoShootEnabled,
		autoShootDelay=Runtime.autoShootDelay,
		autoShootFOV=Runtime.autoShootFOV,
		spinbotEnabled=Flags.spinbotEnabled,
		spinbotSpeed=Runtime.spinbotSpeed,
		instantCrouchEnabled=Flags.instantCrouchEnabled,
		walkSpeedEnabled=Flags.walkSpeedEnabled,
		walkSpeedValue=Values.walkSpeedValue,
		fastClimbEnabled=Flags.fastClimbEnabled,
		climbSpeedMultiplier=Values.climbSpeedMultiplier,
		meleeRangeEnabled=Flags.meleeRangeEnabled,
		meleeRangeMultiplier=Values.meleeRangeMultiplier,
		fastReloadEnabled=Flags.fastReloadEnabled,
		reloadEquipMultiplier=Values.reloadEquipMultiplier,
		customFovEnabled=Flags.customFovEnabled,
		customFovValue=Values.customFovValue,
		espOn=Flags.espOn,
		wepOn=Flags.wepOn,
		invOn=Flags.invOn,
		dropOn=Flags.dropOn,
		skelOn=Flags.skelOn,
		tpEnabled=Flags.tpEnabled,
		tpDist=Runtime.tpDist,
		freecamEnabled=Flags.freecamEnabled,
		bhopEnabled=Flags.bhopEnabled,
		hitSfxEnabled=Flags.hitSfxEnabled,
		hitSfxId=hitSfxId,
		noFlashEnabled=Flags.noFlashEnabled,
		noSmokeEnabled=Flags.noSmokeEnabled,
		hlOn=Flags.hlOn,
		debugMode=Flags.debugMode,
		statsBarEnabled=Flags.statsBarEnabled,
		boxType=Values.boxType,
		boxFillEnabled=Flags.boxFillEnabled,
		tracerStyle=tracerStyle,
		skinSelections=skinSelections,
		selectedWeaponName=selectedWeaponName,
		selectedSkinName=selectedSkinName,
		selectedKnifeName=selectedKnifeName,
		knifePage=knifePage
	}
end

function ConfigUtil.syncUIFromState()
	if UI.saEnabledToggle and UI.saEnabledToggle.SetValue then UI.saEnabledToggle:SetValue(SA.Enabled,true)end
	if UI.noSpreadToggle and UI.noSpreadToggle.SetValue then UI.noSpreadToggle:SetValue(SA.NoSpread,true)end
	if UI.noRecoilToggle and UI.noRecoilToggle.SetValue then UI.noRecoilToggle:SetValue(SA.NoRecoil,true)end
	if UI.teamCheckToggle and UI.teamCheckToggle.SetValue then UI.teamCheckToggle:SetValue(SA.TeamCheck,true)end
	if UI.fovToggle and UI.fovToggle.SetValue then UI.fovToggle:SetValue(SA.FOV,true)end
	if UI.fovSizeSlider and UI.fovSizeSlider.SetValue then UI.fovSizeSlider:SetValue(math.floor(SA.Range or 0),true)end
	if UI.targetPartDropdown and UI.targetPartDropdown.SetValue then UI.targetPartDropdown:SetValue(SA.TargetPart)end
	if UI.targetEspToggle and UI.targetEspToggle.SetValue then UI.targetEspToggle:SetValue(SA.ShowESP,true)end
	if UI.showTracersToggle and UI.showTracersToggle.SetValue then UI.showTracersToggle:SetValue(SA.ShowTracers,true)end
	if UI.hitChanceSlider and UI.hitChanceSlider.SetValue then UI.hitChanceSlider:SetValue(math.floor(SA.HitChance or 0),true)end
	if UI.wallbangToggle and UI.wallbangToggle.SetValue then UI.wallbangToggle:SetValue(SA.WallbangCheck,true)end
	if UI.tracerDropdown and UI.tracerDropdown.SetValue then UI.tracerDropdown:SetValue(tracerStyle)end
	if UI.hitSfxToggle and UI.hitSfxToggle.SetValue then UI.hitSfxToggle:SetValue(Flags.hitSfxEnabled,true)end
	if UI.autoShootToggle and UI.autoShootToggle.SetValue then UI.autoShootToggle:SetValue(Flags.autoShootEnabled,true)end
	if UI.autoShootDelaySlider and UI.autoShootDelaySlider.SetValue then UI.autoShootDelaySlider:SetValue(math.floor((Runtime.autoShootDelay or 0)*1000),true)end
	if UI.autoShootFovSlider and UI.autoShootFovSlider.SetValue then UI.autoShootFovSlider:SetValue(math.floor(Runtime.autoShootFOV or 0),true)end
	if UI.spinbotToggle and UI.spinbotToggle.SetValue then UI.spinbotToggle:SetValue(Flags.spinbotEnabled,true)end
	if UI.spinSpeedSlider and UI.spinSpeedSlider.SetValue then UI.spinSpeedSlider:SetValue(math.floor(Runtime.spinbotSpeed or 0),true)end
	if UI.instantCrouchToggle and UI.instantCrouchToggle.SetValue then UI.instantCrouchToggle:SetValue(Flags.instantCrouchEnabled,true)end
	if UI.walkSpeedToggle and UI.walkSpeedToggle.SetValue then UI.walkSpeedToggle:SetValue(Flags.walkSpeedEnabled,true)end
	if UI.walkSpeedSlider and UI.walkSpeedSlider.SetValue then UI.walkSpeedSlider:SetValue(math.floor(Values.walkSpeedValue or 0),true)end
	if UI.fastClimbToggle and UI.fastClimbToggle.SetValue then UI.fastClimbToggle:SetValue(Flags.fastClimbEnabled,true)end
	if UI.fastClimbSlider and UI.fastClimbSlider.SetValue then UI.fastClimbSlider:SetValue(Values.climbSpeedMultiplier or 1,true)end
	if UI.meleeRangeToggle and UI.meleeRangeToggle.SetValue then UI.meleeRangeToggle:SetValue(Flags.meleeRangeEnabled,true)end
	if UI.meleeRangeSlider and UI.meleeRangeSlider.SetValue then UI.meleeRangeSlider:SetValue(Values.meleeRangeMultiplier or 1,true)end
	if UI.fastReloadToggle and UI.fastReloadToggle.SetValue then UI.fastReloadToggle:SetValue(Flags.fastReloadEnabled,true)end
	if UI.fastReloadSlider and UI.fastReloadSlider.SetValue then UI.fastReloadSlider:SetValue(Values.reloadEquipMultiplier or 1,true)end
	if UI.customFovToggle and UI.customFovToggle.SetValue then UI.customFovToggle:SetValue(Flags.customFovEnabled,true)end
	if UI.customFovSlider and UI.customFovSlider.SetValue then UI.customFovSlider:SetValue(math.floor(Values.customFovValue or defaultCameraFov),true)end
	if UI.espToggle and UI.espToggle.SetValue then UI.espToggle:SetValue(Flags.espOn,true)end
	if UI.snaplinesToggle and UI.snaplinesToggle.SetValue then UI.snaplinesToggle:SetValue(SA.SnaplineEnabled,true)end
	if UI.boxStyleDropdown and UI.boxStyleDropdown.SetValue then UI.boxStyleDropdown:SetValue(Values.boxType)end
	if UI.boxFillToggle and UI.boxFillToggle.SetValue then UI.boxFillToggle:SetValue(Flags.boxFillEnabled,true)end
	if UI.weaponEspToggle and UI.weaponEspToggle.SetValue then UI.weaponEspToggle:SetValue(Flags.wepOn,true)end
	if UI.inventoryEspToggle and UI.inventoryEspToggle.SetValue then UI.inventoryEspToggle:SetValue(Flags.invOn,true)end
	if UI.droppedEspToggle and UI.droppedEspToggle.SetValue then UI.droppedEspToggle:SetValue(Flags.dropOn,true)end
	if UI.skeletonEspToggle and UI.skeletonEspToggle.SetValue then UI.skeletonEspToggle:SetValue(Flags.skelOn,true)end
	if UI.snaplinePosDropdown and UI.snaplinePosDropdown.SetValue then UI.snaplinePosDropdown:SetValue(SA.SnaplinePosition)end
	if UI.highlightToggle and UI.highlightToggle.SetValue then UI.highlightToggle:SetValue(Flags.hlOn,true)end
	if UI.noFlashToggle and UI.noFlashToggle.SetValue then UI.noFlashToggle:SetValue(Flags.noFlashEnabled,true)end
	if UI.noSmokeToggle and UI.noSmokeToggle.SetValue then UI.noSmokeToggle:SetValue(Flags.noSmokeEnabled,true)end
	if UI.statsBarToggle and UI.statsBarToggle.SetValue then UI.statsBarToggle:SetValue(Flags.statsBarEnabled,true)end
	if UI.tpToggle and UI.tpToggle.SetValue then UI.tpToggle:SetValue(Flags.tpEnabled,true)end
	if UI.freecamToggle and UI.freecamToggle.SetValue then UI.freecamToggle:SetValue(Flags.freecamEnabled,true)end
	if UI.tpDistanceSlider and UI.tpDistanceSlider.SetValue then UI.tpDistanceSlider:SetValue(math.floor(Runtime.tpDist or 0),true)end
	if UI.bhopToggle and UI.bhopToggle.SetValue then UI.bhopToggle:SetValue(Flags.bhopEnabled,true)end
	if UI.debugToggle and UI.debugToggle.SetValue then UI.debugToggle:SetValue(Flags.debugMode,true)end
	if UI.hitSfxTextBox and UI.hitSfxTextBox.SetValue then UI.hitSfxTextBox:SetValue(hitSfxId,true)end
	if UI.hitSfxPresetDropdown then
		local presetName=getHitSfxPresetNameById(hitSfxId)
		if not presetName and hitSfxIsCustom then
			presetName=hitSfxCustomLabel
		end
		if presetName then UI.hitSfxPresetDropdown:SetValue(presetName)end
	end
end

function ConfigUtil.applyConfigData(data)
	if not data then return end
	if data.SA then
		for k,v in pairs(data.SA)do
			if SA[k]~=nil then SA[k]=v end
		end
	end
	if SA.Enabled and not SAGUI then SAGUI=createSAGUI()end
	if not SA.Enabled and SAGUI and SAGUI.TargetBox then SAGUI.TargetBox.Visible=false end
	if not SA.ShowTracers then
		clearSATracers()
	end
	Runtime.autoShootDelay=data.autoShootDelay or Runtime.autoShootDelay
	Runtime.autoShootFOV=data.autoShootFOV or Runtime.autoShootFOV
	Runtime.spinbotSpeed=data.spinbotSpeed or Runtime.spinbotSpeed
	Flags.instantCrouchEnabled=data.instantCrouchEnabled and true or false
	Flags.walkSpeedEnabled=data.walkSpeedEnabled and true or false
	Values.walkSpeedValue=tonumber(data.walkSpeedValue) or Values.walkSpeedValue
	Flags.fastClimbEnabled=data.fastClimbEnabled and true or false
	Values.climbSpeedMultiplier=tonumber(data.climbSpeedMultiplier) or Values.climbSpeedMultiplier
	Flags.meleeRangeEnabled=data.meleeRangeEnabled and true or false
	Values.meleeRangeMultiplier=tonumber(data.meleeRangeMultiplier) or Values.meleeRangeMultiplier
	Flags.fastReloadEnabled=data.fastReloadEnabled and true or false
	Values.reloadEquipMultiplier=tonumber(data.reloadEquipMultiplier) or Values.reloadEquipMultiplier
	Flags.customFovEnabled=data.customFovEnabled and true or false
	Values.customFovValue=tonumber(data.customFovValue) or Values.customFovValue
	Runtime.tpDist=data.tpDist or Runtime.tpDist
	Flags.debugMode=data.debugMode or Flags.debugMode
	Flags.statsBarEnabled=data.statsBarEnabled or false
	Values.boxType=data.boxType or Values.boxType
	Flags.boxFillEnabled=data.boxFillEnabled and true or false
	Flags.espOn=data.espOn and true or false
	Flags.wepOn=data.wepOn and true or false
	Flags.invOn=data.invOn and true or false
	Flags.dropOn=data.dropOn and true or false
	Flags.skelOn=data.skelOn and true or false
	Flags.hlOn=data.hlOn and true or false
	if type(data.hitSfxEnabled)=="boolean"then
		Flags.hitSfxEnabled=data.hitSfxEnabled
	end
	if type(data.hitSfxId)=="string"then
		setHitSfxId(data.hitSfxId)
	end
	if type(data.tracerStyle)=="string"and table.find(tracerStyleOptions,data.tracerStyle)then
		tracerStyle=data.tracerStyle
	end
	if UI.tracerDropdown then UI.tracerDropdown:SetValue(tracerStyle)end
	if type(data.skinSelections)=="table"then
		skinSelections=data.skinSelections
	end
	if type(data.selectedWeaponName)=="string"and data.selectedWeaponName~=""then
		selectedWeaponName=data.selectedWeaponName
	end
	if type(data.selectedSkinName)=="string"and data.selectedSkinName~=""then
		selectedSkinName=data.selectedSkinName
	end
	if type(data.selectedKnifeName)=="string"and data.selectedKnifeName~=""then
		selectedKnifeName=data.selectedKnifeName
	end
	if type(data.knifePage)=="number"then
		knifePage=math.max(1,math.floor(data.knifePage))
	end
	if data.autoShootEnabled then toggleAutoShoot(true)else toggleAutoShoot(false)end
	if data.spinbotEnabled then toggleSpinbot(true)else toggleSpinbot(false)end
	if data.bhopEnabled then toggleBhop(true)else toggleBhop(false)end
	if data.tpEnabled then toggleTP(true)else toggleTP(false)end
	if data.freecamEnabled then toggleFreecam(true)else toggleFreecam(false)end
	if data.noFlashEnabled then toggleNoFlash(true)else toggleNoFlash(false)end
	if data.noSmokeEnabled then toggleNoSmoke(true)else toggleNoSmoke(false)end
	WeaponUtil.applyWeaponTweaksToInventory()
	WeaponUtil.applyCameraFov(true)
	if UI.miscTab then task.defer(refreshSkinLists)end
	ConfigUtil.syncUIFromState()
end

function ConfigUtil.saveConfig(name)
	if not name or name==""then
		name=ConfigUtil.getSelectedConfigName()
	end
	if not name or name==""or name=="No Configs"then return end
	if not ConfigUtil.ensureConfigFolder()then return end
	local data=ConfigUtil.buildConfigData()
	pcall(function()
		writefile(ConfigUtil.getConfigPath(name),HTTP:JSONEncode(data))
	end)
end

function ConfigUtil.loadConfig(name)
	if not name or name==""then
		name=ConfigUtil.getSelectedConfigName()
	end
	if not name or name==""or name=="No Configs"then return end
	if not ConfigUtil.ensureConfigFolder()then return end
	local path=ConfigUtil.getConfigPath(name)
	if not isfile(path)then return end
	local ok,decoded=pcall(function()
		return HTTP:JSONDecode(readfile(path))
	end)
	if ok and decoded then
		ConfigUtil.applyConfigData(decoded)
	end
end

function ConfigUtil.deleteConfig(name)
	if not name or name==""then
		name=ConfigUtil.getSelectedConfigName()
	end
	if not name or name==""or name=="No Configs"then return end
	if not ConfigUtil.ensureConfigFolder()then return end
	local path=ConfigUtil.getConfigPath(name)
	if isfile(path)then pcall(function()delfile(path)end)end
end

function ConfigUtil.setAutoLoadConfig(name)
	if not name or name==""then
		name=ConfigUtil.getSelectedConfigName()
	end
	if not name or name==""or name=="No Configs"then return end
	if not ConfigUtil.ensureConfigFolder()then return end
	autoLoadConfigName=name
	pcall(function()writefile(configFolder.."/autoload.txt",name)end)
end

function ConfigUtil.readAutoLoadConfig()
	if not ConfigUtil.ensureConfigFolder()then return nil end
	local path=configFolder.."/autoload.txt"
	if isfile(path)then
		local ok,name=pcall(function()return readfile(path)end)
		if ok and name and name~=""then return name end
	end
	return nil
end

function ConfigUtil.resetSettings()
	SA.Range=100
	SA.FOV=false
	SA.Enabled=false
	SA.ShowESP=false
	SA.ShowTracers=false
	SA.SnaplineEnabled=false
	SA.SnaplinePosition="Bottom"
	SA.TeamCheck=false
	SA.NoSpread=false
	SA.NoRecoil=false
	SA.HitChance=100
	SA.TargetPart="Head"
	SA.WallbangCheck=false
	SA.WallbangPower=99999
	Runtime.autoShootDelay=0.15
	Runtime.autoShootFOV=20
	Runtime.spinbotSpeed=20
	Flags.instantCrouchEnabled=false
	Flags.walkSpeedEnabled=false
	Values.walkSpeedValue=20
	Flags.fastClimbEnabled=false
	Values.climbSpeedMultiplier=1
	Flags.meleeRangeEnabled=false
	Values.meleeRangeMultiplier=1
	Flags.fastReloadEnabled=false
	Values.reloadEquipMultiplier=1
	Flags.customFovEnabled=false
	Values.customFovValue=defaultCameraFov
	Runtime.tpDist=10
	Flags.debugMode=false
	Flags.statsBarEnabled=false
	Values.boxType="2D"
	Flags.boxFillEnabled=false
	Flags.espOn=false
	Flags.wepOn=false
	Flags.invOn=false
	Flags.dropOn=false
	Flags.skelOn=false
	Flags.hlOn=false
	Flags.hitSfxEnabled=true
	setHitSfxId(defaultHitSfxId)
	Flags.noFlashEnabled=false
	Flags.noSmokeEnabled=false
	tracerStyle=tracerStyleOptions[1]
	if UI.tracerDropdown then UI.tracerDropdown:SetValue(tracerStyle)end
	skinSelections={}
	selectedKnifeName=nil
	clearSATracers()
	Runtime.freecamRestoreTP=false
	toggleAutoShoot(false)
	toggleSpinbot(false)
	toggleBhop(false)
	toggleTP(false)
	toggleFreecam(false)
	toggleNoFlash(false)
	toggleNoSmoke(false)
	WeaponUtil.applyWeaponTweaksToInventory()
	WeaponUtil.applyCameraFov(true)
	ConfigUtil.syncUIFromState()
end

autoLoadConfigName=ConfigUtil.readAutoLoadConfig()
if autoLoadConfigName then
	ConfigUtil.loadConfig(autoLoadConfigName)
end

UI.configDropdown=nil
function ConfigUtil.refreshConfigDropdown()
	local opts=ConfigUtil.listConfigs()
	if not selectedConfigName or selectedConfigName==""or not table.find(opts,selectedConfigName)then
		selectedConfigName=opts[1]
	end
	if type(UI.configDropdown)=="table"and UI.configDropdown.SetOptions then
		pcall(function()UI.configDropdown:SetOptions(opts,selectedConfigName)end)
	end
end

function ConfigUtil.getSelectedConfigName()
	if selectedConfigName and selectedConfigName~=""and selectedConfigName~="No Configs"then
		return selectedConfigName
	end
	if type(UI.configDropdown)=="table"and UI.configDropdown.GetValue then
		local v=UI.configDropdown:GetValue()
		if v and v~=""and v~="No Configs"then return v end
	end
	return nil
end

local aimbotTab=RoSense:CreateTab("Aimbot","combat")
aimbotTab.AddLabel({text="Silent Aim"})
UI.saEnabledToggle=aimbotTab.AddToggle({text="Enable Silent Aim",default=SA.Enabled,callback=function(v)
	SA.Enabled=v
	if v and not SAGUI then SAGUI=createSAGUI()end
	if not v and SAGUI and SAGUI.TargetBox then SAGUI.TargetBox.Visible=false end
end})
UI.noSpreadToggle=aimbotTab.AddToggle({text="No Spread",default=SA.NoSpread,callback=function(v)SA.NoSpread=v end})
UI.noRecoilToggle=aimbotTab.AddToggle({text="No Recoil",default=SA.NoRecoil,callback=function(v)SA.NoRecoil=v end})
UI.teamCheckToggle=aimbotTab.AddToggle({text="Team Check",default=SA.TeamCheck,callback=function(v)SA.TeamCheck=v end})
aimbotTab.AddDivider()
aimbotTab.AddLabel({text="Targeting"})
UI.fovToggle=aimbotTab.AddToggle({text="Show FOV Circle",default=SA.FOV,callback=function(v)SA.FOV=v end})
UI.fovSizeSlider=aimbotTab.AddSlider({text="FOV Size",min=1,max=1000,default=SA.Range,callback=function(v)SA.Range=v end})
UI.targetPartDropdown=aimbotTab.AddDropdown({options={"Head","Torso","HumanoidRootPart","Closest Part"},callback=function(v)SA.TargetPart=v end})
UI.targetEspToggle=aimbotTab.AddToggle({text="Show Target ESP",default=SA.ShowESP,callback=function(v)
	SA.ShowESP=v
	if not v and SAGUI and SAGUI.TargetBox then SAGUI.TargetBox.Visible=false end
end})
UI.showTracersToggle=aimbotTab.AddToggle({text="Show Tracers",default=SA.ShowTracers,callback=function(v)
	SA.ShowTracers=v
	if not v then
		clearSATracers()
	end
end})
UI.hitChanceSlider=aimbotTab.AddSlider({text="Hit Chance %",min=0,max=100,default=SA.HitChance,callback=function(v)SA.HitChance=v end})
aimbotTab.AddLabel({text="Wallbang"})
UI.wallbangToggle=aimbotTab.AddToggle({text="Wallbang",default=SA.WallbangCheck,callback=function(v)SA.WallbangCheck=v end})
aimbotTab.AddDivider()
aimbotTab.AddLabel({text="Tracer Style"})
UI.tracerDropdown=aimbotTab.AddDropdown({options=tracerStyleOptions,callback=function(v)tracerStyle=v end})
if UI.tracerDropdown then UI.tracerDropdown:SetValue(tracerStyle)end
aimbotTab.AddLabel({text="Hit SFX"})
UI.hitSfxToggle=aimbotTab.AddToggle({text="Enable Hit SFX",default=Flags.hitSfxEnabled,callback=function(v)Flags.hitSfxEnabled=v end})
UI.hitSfxTextBox=aimbotTab.AddTextBox({placeholder=hitSfxId,callback=function(t)setHitSfxId(t)end})
if UI.hitSfxTextBox then setHitSfxId(hitSfxId)end
aimbotTab.AddLabel({text="Hit SFX Preset"})
UI.hitSfxPresetDropdown=aimbotTab.AddDropdown({options=hitSfxPresetOptions,callback=function(v)
	if v==hitSfxCustomLabel then return end
	local preset=getHitSfxPresetByName(v)
	if not preset then return end
	local path=ensureLocalHitSfx(preset)
	if not path then
		warn("Hit SFX download failed for preset: "..preset.Name)
		return
	end
	setHitSfxId(path)
end})
if UI.hitSfxPresetDropdown then
	local presetName=getHitSfxPresetNameById(hitSfxId)
	if not presetName and hitSfxIsCustom then
		presetName=hitSfxCustomLabel
	end
	if presetName then UI.hitSfxPresetDropdown:SetValue(presetName)end
end
aimbotTab.AddDivider()
aimbotTab.AddLabel({text="Trigger Bot"})
UI.autoShootToggle=aimbotTab.AddToggle({text="Auto Shoot",default=Flags.autoShootEnabled,callback=function(v)toggleAutoShoot(v)end})
UI.autoShootDelaySlider=aimbotTab.AddSlider({text="Shoot Delay (ms)",min=100,max=1000,default=math.floor(Runtime.autoShootDelay*1000),callback=function(v)Runtime.autoShootDelay=v/1000 end})
UI.autoShootFovSlider=aimbotTab.AddSlider({text="Shoot FOV",min=5,max=90,default=Runtime.autoShootFOV,callback=function(v)Runtime.autoShootFOV=v end})
aimbotTab.AddDivider()
aimbotTab.AddLabel({text="Spinbot"})
UI.spinbotToggle=aimbotTab.AddToggle({text="Enable Spinbot",default=Flags.spinbotEnabled,callback=function(v)toggleSpinbot(v)end})
UI.spinSpeedSlider=aimbotTab.AddSlider({text="Spin Speed",min=1,max=50,default=Runtime.spinbotSpeed,callback=function(v)Runtime.spinbotSpeed=v end})

local visualTab=RoSense:CreateTab("Visuals","visuals")
visualTab.AddLabel({text="ESP"})
UI.espToggle=visualTab.AddToggle({text="Enable ESP",default=Flags.espOn,callback=function(v)Flags.espOn=v if not v then for p in pairs(DrawObjs)do removeESP(p)end end end})
UI.snaplinesToggle=visualTab.AddToggle({text="Snaplines",default=SA.SnaplineEnabled,callback=function(v)SA.SnaplineEnabled=v end})
visualTab.AddLabel({text="Box Style"})
UI.boxStyleDropdown=visualTab.AddDropdown({options={"2D","Corner","3D"},callback=function(v)Values.boxType=v end})
UI.boxFillToggle=visualTab.AddToggle({text="Box Fill",default=Flags.boxFillEnabled,callback=function(v)Flags.boxFillEnabled=v end})
UI.weaponEspToggle=visualTab.AddToggle({text="Weapon ESP",default=Flags.wepOn,callback=function(v)Flags.wepOn=v end})
UI.inventoryEspToggle=visualTab.AddToggle({text="Inventory ESP",default=Flags.invOn,callback=function(v)Flags.invOn=v end})
UI.droppedEspToggle=visualTab.AddToggle({text="Dropped Weapons",default=Flags.dropOn,callback=function(v)Flags.dropOn=v if not v then for m in pairs(DroppedWeps)do removeDropESP(m)end end end})
UI.skeletonEspToggle=visualTab.AddToggle({text="Skeleton ESP",default=Flags.skelOn,callback=function(v)Flags.skelOn=v end})
visualTab.AddLabel({text="Snapline Position"})
UI.snaplinePosDropdown=visualTab.AddDropdown({options={"Top","Middle","Bottom"},callback=function(v)SA.SnaplinePosition=v end})
visualTab.AddDivider()
visualTab.AddLabel({text="Highlight"})
UI.highlightToggle=visualTab.AddToggle({text="Enable Highlight",default=Flags.hlOn,callback=function(v)Flags.hlOn=v end})
visualTab.AddDivider()
visualTab.AddLabel({text="Effects"})
UI.noFlashToggle=visualTab.AddToggle({text="No Flash",default=Flags.noFlashEnabled,callback=function(v)toggleNoFlash(v)end})
UI.noSmokeToggle=visualTab.AddToggle({text="No Smoke",default=Flags.noSmokeEnabled,callback=function(v)toggleNoSmoke(v)end})
visualTab.AddButton({text="Remove All Smoke",callback=function()removeAllSmoke()end})
visualTab.AddDivider()
visualTab.AddLabel({text="HUD"})
UI.statsBarToggle=visualTab.AddToggle({text="Stats Bar",default=Flags.statsBarEnabled,callback=function(v)Flags.statsBarEnabled=v end})
visualTab.AddDivider()
visualTab.AddLabel({text="World"})
visualTab.AddButton({text="Night Time",callback=function()Light.ClockTime,Light.Brightness,Light.OutdoorAmbient,Light.Ambient=0,2,Color3.fromRGB(100,100,150),Color3.fromRGB(100,100,150)end})
visualTab.AddButton({text="Day Time",callback=function()Light.ClockTime,Light.Brightness,Light.OutdoorAmbient,Light.Ambient=14,2,Color3.fromRGB(128,128,128),Color3.fromRGB(128,128,128)end})
visualTab.AddButton({text="Sunset+",callback=function()applyWorldPreset("Sunset")end})
visualTab.AddButton({text="Full Bright",callback=function()Light.Brightness,Light.Ambient,Light.OutdoorAmbient=5,Color3.fromRGB(255,255,255),Color3.fromRGB(255,255,255)end})
visualTab.AddButton({text="Sakura",callback=function()applyWorldPreset("Sakura")end})

local playerTab=RoSense:CreateTab("Player","movement")
playerTab.AddLabel({text="Camera"})
UI.tpToggle=playerTab.AddToggle({text="Third Person",default=Flags.tpEnabled,callback=function(v)toggleTP(v)end})
UI.freecamToggle=playerTab.AddToggle({text="Free Cam",default=Flags.freecamEnabled,callback=function(v)toggleFreecam(v)end})
UI.tpDistanceSlider=playerTab.AddSlider({text="TP Distance",min=5,max=30,default=Runtime.tpDist,callback=function(v)Runtime.tpDist=v end})
UI.customFovToggle=playerTab.AddToggle({text="Custom FOV",default=Flags.customFovEnabled,callback=function(v)
	Flags.customFovEnabled=v
	WeaponUtil.applyCameraFov(true)
end})
UI.customFovSlider=playerTab.AddSlider({text="FOV Value",min=40,max=120,default=Values.customFovValue,callback=function(v)
	Values.customFovValue=v
	if Flags.customFovEnabled then WeaponUtil.applyCameraFov()end
end})
playerTab.AddDivider()
playerTab.AddLabel({text="Movement"})
UI.walkSpeedToggle=playerTab.AddToggle({text="Walk Speed",default=Flags.walkSpeedEnabled,callback=function(v)Flags.walkSpeedEnabled=v end})
UI.walkSpeedSlider=playerTab.AddSlider({text="Speed Value",min=10,max=120,default=Values.walkSpeedValue,callback=function(v)Values.walkSpeedValue=v end})
UI.instantCrouchToggle=playerTab.AddToggle({text="Instant Crouch",default=Flags.instantCrouchEnabled,callback=function(v)Flags.instantCrouchEnabled=v end})
UI.fastClimbToggle=playerTab.AddToggle({text="Fast Climb",default=Flags.fastClimbEnabled,callback=function(v)Flags.fastClimbEnabled=v end})
UI.fastClimbSlider=playerTab.AddSlider({text="Climb Speed x",min=1,max=10,default=Values.climbSpeedMultiplier,callback=function(v)Values.climbSpeedMultiplier=v end})
UI.bhopToggle=playerTab.AddToggle({text="Bunny Hop",default=Flags.bhopEnabled,callback=function(v)toggleBhop(v)end})
playerTab.AddDivider()
playerTab.AddLabel({text="Weapon Tweaks"})
UI.meleeRangeToggle=playerTab.AddToggle({text="Melee Range Boost",default=Flags.meleeRangeEnabled,callback=function(v)
	Flags.meleeRangeEnabled=v
	WeaponUtil.applyWeaponTweaksToInventory()
end})
UI.meleeRangeSlider=playerTab.AddSlider({text="Melee Range x",min=1,max=10,default=Values.meleeRangeMultiplier,callback=function(v)
	Values.meleeRangeMultiplier=v
	if Flags.meleeRangeEnabled then WeaponUtil.applyWeaponTweaksToInventory()end
end})
UI.fastReloadToggle=playerTab.AddToggle({text="Fast Reload/Equip",default=Flags.fastReloadEnabled,callback=function(v)
	Flags.fastReloadEnabled=v
	WeaponUtil.applyWeaponTweaksToInventory()
end})
UI.fastReloadSlider=playerTab.AddSlider({text="Reload/Equip Speed x",min=1,max=10,default=Values.reloadEquipMultiplier,callback=function(v)
	Values.reloadEquipMultiplier=v
	if Flags.fastReloadEnabled then WeaponUtil.applyWeaponTweaksToInventory()end
end})
UI.miscTab=RoSense:CreateTab("Misc","misc")
selectedWeaponName=getEquippedWeaponName() or selectedWeaponName
refreshSkinLists()

local configTab=RoSense:CreateTab("Config","config")
configTab.AddLabel({text="Config Manager"})
configTab.AddTextBox({placeholder="Config name...",callback=function(t)selectedConfigName=t end})
configTab.AddButton({text="Save Config",callback=function()ConfigUtil.saveConfig(selectedConfigName)ConfigUtil.refreshConfigDropdown()end})
configTab.AddButton({text="Load Config",callback=function()ConfigUtil.loadConfig(selectedConfigName)end})
configTab.AddButton({text="Delete Config",callback=function()ConfigUtil.deleteConfig(selectedConfigName)ConfigUtil.refreshConfigDropdown()end})
configTab.AddButton({text="Set Auto Load",callback=function()ConfigUtil.setAutoLoadConfig(selectedConfigName)end})
configTab.AddButton({text="Clear Settings",callback=function()ConfigUtil.resetSettings()end})
configTab.AddDivider()
configTab.AddLabel({text="Config List"})
local configList = ConfigUtil.listConfigs()
if not configList or #configList == 0 then
    configList = {"No Configs"}
end
selectedConfigName=selectedConfigName or configList[1]
UI.configDropdown=configTab.AddDropdown({options=configList,callback=function(v)selectedConfigName=v end})
configTab.AddDivider()
configTab.AddLabel({text="Advanced"})
UI.debugToggle=configTab.AddToggle({text="Debug Mode",default=Flags.debugMode,callback=function(v)Flags.debugMode=v if v then print("[DEBUG] Debug mode enabled")end end})
configTab.AddButton({text="Unload Cheat",callback=function()unloadCheat()end})

ConfigUtil.syncUIFromState()

Plrs.PlayerAdded:Connect(function(p)task.wait(0.5)createESP(p)end)
Plrs.PlayerRemoving:Connect(function(p)removeESP(p)end)

for _,p in ipairs(Plrs:GetPlayers())do if p~=LP then createESP(p)end end

LP.CharacterAdded:Connect(function(char)
	task.wait(1)
	WeaponUtil.applyWeaponTweaksToInventory()
	for _,p in ipairs(Plrs:GetPlayers())do
		if p~=LP then
			if DrawObjs[p]then removeESP(p)end
			createESP(p)
		end
	end
	if Flags.spinbotEnabled then
		local wasEnabled=Flags.spinbotEnabled
		toggleSpinbot(false)
		task.wait(0.5)
		if wasEnabled then toggleSpinbot(true)end
	end
	if Flags.autoShootEnabled then
		local wasEnabled=Flags.autoShootEnabled
		toggleAutoShoot(false)
		task.wait(0.5)
		if wasEnabled then toggleAutoShoot(true)end
	end
	if Flags.bhopEnabled then
		local wasEnabled=Flags.bhopEnabled
		toggleBhop(false)
		task.wait(0.5)
		if wasEnabled then toggleBhop(true)end
	end
	if Flags.tpEnabled then
		task.wait(0.5)
		toggleTP(false)
		task.wait(0.1)
		toggleTP(true)
	end
end)

WS.Debris.ChildAdded:Connect(function(c)
	task.wait(0.1)
	if c:IsA("Model")and c:GetAttribute("CanPickup")then
		createDropESP(c)
	end
end)

WS.Debris.ChildRemoved:Connect(function(c)if DroppedWeps[c]then removeDropESP(c)end end)

Run.RenderStepped:Connect(function()
	pcall(function()
		if SA.Enabled and SAGUI then updateSAVis()end
		if SA.ShowTracers then updateTracers()end
		if Flags.customFovEnabled then WeaponUtil.applyCameraFov()end
		updateStatsBar()
		if Flags.espOn or SA.SnaplineEnabled then
			for _,p in ipairs(Plrs:GetPlayers())do
				if p~=LP then updateESP(p)end
			end
		end
		if Flags.dropOn then
			for _,c in ipairs(WS.Debris:GetChildren())do
				if c:IsA("Model")and c:GetAttribute("CanPickup")then
					updateDropESP(c)
				end
			end
		end
	end)
end)

game["Run Service"].Heartbeat:Connect(function()
	pcall(function()
		for _,pl in pairs(Plrs:GetPlayers())do
			if pl~=LP then
				local ch=pl.Character
				if Flags.hlOn and ch and not ch:FindFirstChild("HacksHigh")then
					local hg=Instance.new("Highlight")
					hg.FillTransparency,hg.FillColor,hg.Name,hg.OutlineTransparency,hg.OutlineColor=0.5,Color3.new(1,1,1),"HacksHigh",0,Color3.new(1,1,1)
					hg.DepthMode,hg.Adornee,hg.Parent=Enum.HighlightDepthMode.AlwaysOnTop,ch,ch
				elseif ch and ch:FindFirstChild("HacksHigh")and not Flags.hlOn then
					ch:FindFirstChild("HacksHigh"):Destroy()
				end
			end
		end
	end)
end)
