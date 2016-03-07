--- Author informations ---
SWEP.Author = "Zaratusa"
SWEP.Contact = "http://steamcommunity.com/profiles/76561198032479768"

local TTT = false
local SB = false
if (gmod.GetGamemode().Name == "Trouble in Terrorist Town") then
	TTT = true
elseif gmod.GetGamemode().Name == "Sandbox" then
	SB = true
end

if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("639762141")
elseif CLIENT then
	SWEP.PrintName = "Dragon Elites"
	SWEP.Slot = 1
	if TTT then
		SWEP.Icon = "vgui/ttt/icon_dragon_elites"

		-- Equipment menu information is only needed on the client
		SWEP.EquipMenuData = {
			type = "item_weapon",
			desc = "Dual Dragon Elites,\nwith one additional magazine.\n\nGet the Style."
		};
	end
end

--- Gamemode dependent settings ---
if TTT then
	SWEP.Base = "weapon_tttbase"
elseif SB then
	SWEP.Base = "weapon_base"
	SWEP.Category = "TTT"
	SWEP.Purpose = "A weapon originally created for Traitors and Detectives in TTT."
	SWEP.Spawnable = true
	SWEP.AdminOnly = false
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true

	SWEP.Secondary.Ammo = "none"
	SWEP.Secondary.ClipSize = -1
	SWEP.Secondary.DefaultClip = -1
end

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
SWEP.ViewModel  = Model("models/weapons/zaratusa/dragon_elites/v_dragon_elites.mdl")
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

if SB then
	function SWEP:PrimaryAttack()
		if (self:CanPrimaryAttack()) then
			self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
			self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			if SERVER then
				sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
			end

			self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
			self:TakePrimaryAmmo(1)

			if (IsValid(owner) and !owner:IsNPC() and owner.ViewPunch) then
				owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) * self.Primary.Recoil, 0))
			end
		end
	end

	function SWEP:SecondaryAttack()
	end
end
