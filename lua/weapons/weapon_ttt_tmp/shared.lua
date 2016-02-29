if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("253737973")
end

if CLIENT then
   SWEP.PrintName = "TMP"
   SWEP.Slot = 2
   SWEP.Icon = "vgui/ttt/icon_tmp"
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

--- Default GMod values ---
SWEP.HoldType = "ar2"

SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Delay = 0.08
SWEP.Primary.Recoil	= 1.1
SWEP.Primary.Cone = 0.017
SWEP.Primary.Damage = 16
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Sound = Sound("Weapon_TMP.Single")

--- Model settings ---
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 64
SWEP.ViewModel = Model("models/weapons/cstrike/c_smg_tmp.mdl")
SWEP.WorldModel	= Model("models/weapons/w_smg_tmp.mdl")

SWEP.IronSightsPos = Vector (-6.395, -6.822, 2.735)
SWEP.IronSightsAng = Vector (2.253, 0.9, 0.7)

--- TTT config values ---

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_HEAVY

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, 
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = true

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "item_ammo_smg1_ttt"

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = true

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = false


function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
	return true
end