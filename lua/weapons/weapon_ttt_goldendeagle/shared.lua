if SERVER then
   AddCSLuaFile( "shared.lua" )
end

if CLIENT then
   SWEP.PrintName = "Golden Deagle"
   SWEP.Slot = 6
   SWEP.Icon = "vgui/ttt/icon_goldendeagle"
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

-- Standard GMod values
SWEP.HoldType = "pistol"

SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.08
SWEP.Primary.Recoil = 1.2
SWEP.Primary.Cone = 0.025
SWEP.Primary.Damage = 1
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Sound = Sound( "weapons/goldendeagle/goldendeagle.wav" )

-- Model settings
SWEP.UseHands = true
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 72
SWEP.ViewModel = "models/weapons/v_powerdeagle.mdl"
SWEP.WorldModel = "models/weapons/w_powerdeagle.mdl"

SWEP.IronSightsPos = Vector( -6.361, -3.701, 2.15 )
SWEP.IronSightsAng = Vector( 0, 0, 0 )

--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP1

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_DETECTIVE }

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = { nil }

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = false

-- Equipment menu information is only needed on the client
if CLIENT then
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Shoot a traitor, kill a traitor. \nShoot an innocent, kill yourself. \nBe careful."
   };
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	local trace = util.GetPlayerTrace(self.Owner)
	local tr = util.TraceLine(trace)

	if tr.Entity.IsPlayer() then
		if tr.Entity:IsRole(ROLE_TRAITOR) then
			bullet = {}
			bullet.Num = self.Primary.NumberofShots
			bullet.Src = self.Owner:GetShootPos()
			bullet.Dir = self.Owner:GetAimVector()
			bullet.Spread = Vector( 0, 0, 0 )
			bullet.Tracer = 0
			bullet.Force = 1000
			bullet.Damage = 1000
			bullet.AmmoType = self.Primary.Ammo
			self.Owner:FireBullets(bullet)
			self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			self:TakePrimaryAmmo(1)
			self.Weapon.EmitSound(Sound( "Weapon_Deagle.Single" ))
			return
		elseif tr.Entity:IsRole(ROLE_INNOCENT) or tr.Entity:IsRole(ROLE_DETECTIVE) then
			self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			self.Weapon:EmitSound(Sound( "Weapon_Deagle.Single" ))
			self:TakePrimaryAmmo(1)
			if SERVER then
				self.Owner:Kill()
			end
			return
        end
	end
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:TakePrimaryAmmo(1)
	self.Owner:EmitSound(Sound( "Weapon_Deagle.Single" ))
	return
end