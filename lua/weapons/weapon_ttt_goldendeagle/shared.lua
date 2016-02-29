if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("253737047")
end

if CLIENT then
   SWEP.PrintName = "Golden Deagle"
   SWEP.Slot = 6
   SWEP.Icon = "vgui/ttt/icon_goldendeagle"
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

--- Default GMod values ---
SWEP.HoldType = "pistol"

SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.6
SWEP.Primary.Recoil = 6
SWEP.Primary.Cone = 0.02
SWEP.Primary.Damage = 1
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Sound = Sound("weapons/goldendeagle/goldendeagle-1.wav")

--- Model settings ---
SWEP.UseHands = true
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 72
SWEP.ViewModel = Model("models/weapons/v_powerdeagle.mdl")
SWEP.WorldModel = Model("models/weapons/w_powerdeagle.mdl")

--- TTT config values ---

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP1

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, 
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_DETECTIVE }

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true

-- Equipment menu information is only needed on the client
if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Shoot a traitor, kill a traitor.\nShoot an innocent or detective, kill yourself.\nBe careful."
	};
end


-- Precache sounds
function SWEP:Precache()
	util.PrecacheSound("weapons/goldendeagle/goldendeagle-1.wav")
end

function SWEP:PrimaryAttack()
	if (self:CanPrimaryAttack()) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		-- If the sound is emitted on the Weapon, the sound will stop on self.Owner:Kill(), emit it on the Owner instead
		self.Owner:EmitSound(self.Primary.Sound)
		self:TakePrimaryAmmo(1)
		
		local tr = util.TraceLine(util.GetPlayerTrace(self.Owner))
		
		if (tr.Entity.IsPlayer()) then
			if (tr.Entity:IsRole(ROLE_TRAITOR)) then
				bullet = {}
				bullet.Num = self.Primary.NumberofShots
				bullet.Src = self.Owner:GetShootPos()
				bullet.Dir = self.Owner:GetAimVector()
				bullet.Spread = Vector(0, 0, 0)
				bullet.Tracer = 0
				bullet.Force = 1000
				bullet.Damage = 1000
				bullet.AmmoType = self.Primary.Ammo
				self.Owner:FireBullets(bullet)
			elseif (SERVER and (tr.Entity:IsRole(ROLE_INNOCENT) or tr.Entity:IsRole(ROLE_DETECTIVE))) then
				self.Owner:Kill()
			end
		end
	end
end