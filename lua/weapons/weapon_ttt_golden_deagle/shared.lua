--- Author informations ---
SWEP.Author = "Zaratusa"
SWEP.Contact = "http://steamcommunity.com/profiles/76561198032479768"

if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("637848943")
elseif CLIENT then
	SWEP.PrintName = "Golden Deagle"
	SWEP.Slot = 6
	SWEP.Icon = "vgui/ttt/icon_golden_deagle"

	-- Equipment menu information is only needed on the client
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Shoot a traitor, kill a traitor.\nShoot an innocent or detective, kill yourself.\nBe careful."
	}
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
SWEP.ViewModelFOV = 85
SWEP.ViewModel = Model("models/weapons/zaratusa/golden_deagle/v_golden_deagle.mdl")
SWEP.WorldModel = Model("models/weapons/zaratusa/golden_deagle/w_golden_deagle.mdl")

SWEP.IronSightsPos = Vector(3.76, -0.5, 3.67)
SWEP.IronSightsAng = Vector(-0.75, 0.06, 0)

--- TTT config values ---

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP1

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2,
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = false

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

function SWEP:Initialize()
	if (CLIENT and self:Clip1() == -1) then
		self:SetClip1(self.Primary.DefaultClip)
	elseif (SERVER) then
		self.fingerprints = {}
		self:SetIronsights(false)
	end

	self:SetDeploySpeed(self.DeploySpeed)

	if (self.SetHoldType) then
		self:SetHoldType(self.HoldType or "pistol")
	end

	PrecacheParticleSystem("smoke_trail")
end

function SWEP:PrimaryAttack(worldsnd)
	if (self:CanPrimaryAttack()) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

		local owner = self.Owner
		owner:GetViewModel():StopParticles()

		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self.Owner:MuzzleFlash()
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		if (!worldsnd) then
			self.Weapon:EmitSound(self.Primary.Sound)
		elseif SERVER then
			sound.Play(self.Primary.Sound, self:GetPos())
		end

		local tr = util.TraceLine(util.GetPlayerTrace(owner))

		if (SERVER and tr.Entity:IsPlayer() and (tr.Entity:IsRole(ROLE_INNOCENT) or tr.Entity:IsRole(ROLE_DETECTIVE))) then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(1000)
			dmginfo:SetAttacker(owner)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageType(DMG_BULLET)
			dmginfo:SetDamagePosition(owner:GetPos())

			owner:TakeDamageInfo(dmginfo)
		else
			local bullet = {}
			bullet.Attacker = owner
			bullet.Num = self.Primary.NumberofShots
			bullet.Src = owner:GetShootPos()
			bullet.Dir = owner:GetAimVector()
			bullet.AmmoType = self.Primary.Ammo

			if (tr.Entity:IsPlayer() and tr.Entity:IsRole(ROLE_TRAITOR)) then
				bullet.Force = 1000
				bullet.Damage = 1000
			else
				bullet.Damage = self.Primary.Damage
				bullet.Spread = Vector(self.Primary.Cone, self.Primary.Cone, 0)
			end

			self:FireBullets(bullet)
		end
		self:TakePrimaryAmmo(1)

		if (IsValid(owner) and !owner:IsNPC() and owner.ViewPunch) then
			owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) * self.Primary.Recoil, 0))
		end

		timer.Simple(0.5, function() if (IsValid(self) and IsValid(self.Owner)) then ParticleEffectAttach("smoke_trail", PATTACH_POINT_FOLLOW, self.Owner:GetViewModel(), 1) end end)
	end
end
