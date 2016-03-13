--- Author informations ---
SWEP.Author = "Zaratusa"
SWEP.Contact = "http://steamcommunity.com/profiles/76561198032479768"

if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("639762141")
elseif CLIENT then
	SWEP.PrintName = "Dragon Elites"
	SWEP.Slot = 1
	SWEP.Icon = "vgui/ttt/icon_dragon_elites"

	-- Equipment menu information is only needed on the client
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Dual Dragon Elites,\nwith one additional magazine.\n\nGet the Style."
	}
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

--- Default GMod values ---
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Delay = 0.1
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Cone = 0.025
SWEP.Primary.Damage = 22
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 60
SWEP.Primary.Sound = Sound("Dragon_Elite.Single")

SWEP.HeadshotMultiplier = 2.97

--- Model settings ---
SWEP.HoldType = "duel"

SWEP.UseHands = true
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 74
SWEP.ViewModel = Model("models/weapons/zaratusa/dragon_elites/v_dragon_elites.mdl")
SWEP.WorldModel = Model("models/weapons/zaratusa/dragon_elites/w_dragon_elites.mdl")

--- TTT config values ---

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_PISTOL

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2,
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "item_ammo_pistol_ttt"

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_DETECTIVE, ROLE_TRAITOR }

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true

-- Precache sounds
function SWEP:Precache()
	util.PrecacheSound("Dragon_Elite.Single")
	util.PrecacheSound("Dragon_Elite.Elite_reloadstart")
	util.PrecacheSound("Dragon_Elite.Elite_leftclipin")
	util.PrecacheSound("Dragon_Elite.Elite_rightclipin")
	util.PrecacheSound("Dragon_Elite.Elite_deploy")
end

-- copied from weapon_tttbase and modified for the correct animaton
function SWEP:Initialize()
	if (CLIENT and self:Clip1() == -1) then
		self:SetClip1(self.Primary.DefaultClip)
	elseif (SERVER) then
		self.fingerprints = {}
		self:SetIronsights(false)
	end

	self:SetDeploySpeed(self.DeploySpeed)

	-- compat for gmod update
	if (self.SetHoldType) then
		self:SetHoldType(self.HoldType or "pistol")
	end

	self.LastShot = 0
	self.AnimateRight = true
end

-- copied from weapon_tttbase and modified for the correct sound
function SWEP:PrimaryAttack()
	if (self:CanPrimaryAttack()) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

		if SERVER then
			sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
		end

		self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone())
		self.LastShot = CurTime()
		self:TakePrimaryAmmo(1)

		local owner = self.Owner
		if (IsValid(owner) and !owner:IsNPC() and owner.ViewPunch) then
			owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) * self.Primary.Recoil, 0))
		end
	end
end

local sparkle = CLIENT and CreateConVar("ttt_crazy_sparks", "0", FCVAR_ARCHIVE)
-- copied from weapon_tttbase and modified for the correct animaton
function SWEP:ShootBullet(dmg, recoil, numbul, cone)
	self:ShootEffects()

	if (IsFirstTimePredicted()) then
		local sights = self:GetIronsights()

		numbul = numbul or 1
		cone = cone or 0.01

		local bullet = {}
		bullet.Num = numbul
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector( cone, cone, 0 )
		bullet.Tracer = 4
		bullet.TracerName = self.Tracer or "Tracer"
		bullet.Force = 10
		bullet.Damage = dmg
		if CLIENT and sparkle:GetBool() then
			bullet.Callback = Sparklies
		end

		self.Owner:FireBullets(bullet)

		-- Owner can die after firebullets
		if (IsValid(self.Owner) and self.Owner:Alive() and (!self.Owner:IsNPC())
			and ((game.SinglePlayer() and SERVER)
				or ((!game.SinglePlayer()) and CLIENT and IsFirstTimePredicted()))) then
			-- reduce recoil if ironsighting
			recoil = sights and (recoil * 0.6) or recoil

			local eyeang = self.Owner:EyeAngles()
			eyeang.pitch = eyeang.pitch - recoil
			self.Owner:SetEyeAngles(eyeang)
		end
	end
end

function SWEP:ShootEffects()
	local sequence
	if self.AnimateRight then
		if (CurTime() - self.LastShot > 0.3) then
			sequence = "shoot_right1"
		else
			sequence = "shoot_right2"
		end
	else
		if (CurTime() - self.LastShot > 0.3) then
			sequence = "shoot_left1"
		else
			sequence = "shoot_left2"
		end
	end

	local viewModel = self.Owner:GetViewModel()
	viewModel:ResetSequence(viewModel:LookupSequence(sequence))
	self.AnimateRight = !self.AnimateRight

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end
