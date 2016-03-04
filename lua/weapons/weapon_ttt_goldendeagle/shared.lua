--- Author informations ---
SWEP.Author = "Zaratusa"
SWEP.Contact = "http://steamcommunity.com/profiles/76561198032479768"

if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("253737047")
elseif CLIENT then
	SWEP.PrintName = "Golden Deagle"
	SWEP.Slot = 6
	SWEP.Icon = "vgui/ttt/icon_goldendeagle"
	
	-- Equipment menu information is only needed on the client
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Shoot a traitor, kill a traitor.\nShoot an innocent or detective, kill yourself.\nBe careful."
	};
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

--- Default GMod values ---
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.6
SWEP.Primary.Recoil = 6
SWEP.Primary.Cone = 0.02
SWEP.Primary.Damage = 37
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Sound = Sound("Golden_Deagle.Single")

--- Model settings ---
SWEP.HoldType = "pistol"

SWEP.UseHands = true
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 72
SWEP.ViewModel = Model("models/weapons/v_powerdeagle.mdl")
SWEP.WorldModel = Model("models/weapons/w_powerdeagle.mdl")

SWEP.IronSightsPos = Vector(1.1, 0.6, 2.55)
SWEP.IronSightsAng = Vector(0, 0, 75)

--- TTT config values ---

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP1

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "none"

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
SWEP.NoSights = false

-- Precache sounds
function SWEP:Precache()
	util.PrecacheSound("Golden_Deagle.Single")
end

function SWEP:PrimaryAttack()
	if (self:CanPrimaryAttack()) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)		
		self:SendWeaponAnim(self.PrimaryAnim)
		
		-- If the sound is emitted on the weapon, the sound will stop upon owners death, so emit it on the owner instead
		self.Owner:EmitSound(self.Primary.Sound)
		self:TakePrimaryAmmo(1)
		
		local tr = util.TraceLine(util.GetPlayerTrace(self.Owner))
		
		if (SERVER and tr.Entity.IsPlayer() and (tr.Entity:IsRole(ROLE_INNOCENT) or tr.Entity:IsRole(ROLE_DETECTIVE))) then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(1000)
			dmginfo:SetAttacker(self.Owner)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageType(DMG_BULLET)
			dmginfo:SetDamagePosition(self.Owner:GetPos())
				
			self.Owner:TakeDamageInfo(dmginfo)
		else
			local bullet = {}
			bullet.Attacker = self.Owner
			bullet.Num = self.Primary.NumberofShots
			bullet.Src = self.Owner:GetShootPos()
			bullet.Dir = self.Owner:GetAimVector()
			bullet.AmmoType = self.Primary.Ammo
			
			if (tr.Entity.IsPlayer() and tr.Entity:IsRole(ROLE_TRAITOR)) then
				bullet.Force = 1000
				bullet.Damage = 1000
			else
				bullet.Damage = self.Primary.Damage
			end
			
			self:FireBullets(bullet)
		end
	end
end