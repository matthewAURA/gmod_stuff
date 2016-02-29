if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("254177214")
end

if CLIENT then
   SWEP.PrintName = "Jihad Bomb"
   SWEP.Slot = 8
   SWEP.Icon = "vgui/ttt/icon_jihad"
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

--- Default GMod values ---
SWEP.HoldType = "slam"

SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 5
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

--- Model settings ---
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 54
SWEP.ViewModel = Model("models/weapons/v_jb.mdl")
SWEP.WorldModel = Model("models/weapons/w_jb.mdl")

--- TTT config values ---

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_ROLE

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, 
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts.
SWEP.InLoadoutFor = { ROLE_TRAITOR }

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true


-- Precache sounds and models
function SWEP:Precache()
	util.PrecacheSound("weapons/jihad/jihad.wav")
	util.PrecacheSound("weapons/jihad/big_explosion.wav")
	
	util.PrecacheModel("models/Humans/Charple01.mdl")
	util.PrecacheModel("models/Humans/Charple02.mdl")
	util.PrecacheModel("models/Humans/Charple03.mdl")
	util.PrecacheModel("models/Humans/Charple04.mdl")
end

-- Particle effects / Begin attack
function SWEP:PrimaryAttack()
	self.AllowDrop = false
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetNormal(self:GetPos())
	effectdata:SetMagnitude(8)
	effectdata:SetScale(1)
	effectdata:SetRadius(20)
	util.Effect("Sparks", effectdata)
	self.BaseClass.ShootEffects(self)

	-- The rest is only done on the server
	if SERVER then
		timer.Simple(2, function() self:Explode() end)
		self.Owner:EmitSound("weapons/jihad/jihad.wav", math.random(100, 150), math.random(95, 105))
	end
end

-- Explosion properties
function SWEP:Explode()
	local explosion = ents.Create("env_explosion")
	explosion:SetPos(self:GetPos())
	explosion:SetOwner(self.Owner)
	explosion:SetKeyValue("iMagnitude", 256)
	explosion:Spawn()
	explosion:Fire("Explode", 0, 0)
	explosion:EmitSound("weapons/jihad/big_explosion.wav", 400, math.random(100, 125))
	   
	self:Remove()
	self.Owner:SetModel("models/Humans/Charple0" .. math.random(1,4) .. ".mdl")
	self.Owner:Kill()
end

-- Secondary attack does nothing
function SWEP:SecondaryAttack()
end

-- Reload does nothing
function SWEP:Reload()
end