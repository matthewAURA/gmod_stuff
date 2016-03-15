--- Author informations ---
SWEP.Author = "Zaratusa"
SWEP.Contact = "http://steamcommunity.com/profiles/76561198032479768"

if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("639762141")
elseif CLIENT then
	SWEP.PrintName = "Dragon Elites"
	SWEP.Slot = 1
end

--- Default GMod values ---
SWEP.Base = "weapon_base"
SWEP.Category = "Counter-Strike: Source"
SWEP.Purpose = "A nice Dual Elite modification."
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

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

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1

SWEP.HeadshotMultiplier = 2.97

--- Model settings ---
SWEP.HoldType = "duel"

SWEP.DeploySpeed = 1.4
SWEP.UseHands = true
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 74
SWEP.ViewModel = Model("models/weapons/zaratusa/dragon_elites/v_dragon_elites.mdl")
SWEP.WorldModel = Model("models/weapons/zaratusa/dragon_elites/w_dragon_elites.mdl")

-- Precache sounds
function SWEP:Precache()
	util.PrecacheSound("Dragon_Elite.Single")
	util.PrecacheSound("Dragon_Elite.Elite_reloadstart")
	util.PrecacheSound("Dragon_Elite.Elite_leftclipin")
	util.PrecacheSound("Dragon_Elite.Elite_rightclipin")
	util.PrecacheSound("Dragon_Elite.Elite_deploy")
end

function SWEP:Initialize()
	self:SetDeploySpeed(self.DeploySpeed)

	if (self.SetHoldType) then
		self:SetHoldType(self.HoldType or "pistol")
	end

	self.LastShot = 0
	self.AnimateRight = true
end

function SWEP:PrimaryAttack()
	if (self:CanPrimaryAttack()) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

		self.Weapon:EmitSound(self.Primary.Sound)

		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone)
		self.LastShot = CurTime()
		self:TakePrimaryAmmo(1)

		if (IsValid(owner) and !owner:IsNPC() and owner.ViewPunch) then
			owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) * self.Primary.Recoil, 0))
		end
	end
end

function SWEP:SecondaryAttack()
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
