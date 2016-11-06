--- Author informations ---
SWEP.Author = "Zaratusa"
SWEP.Contact = "http://steamcommunity.com/profiles/76561198032479768"

if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("637848943")
else
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
SWEP.Primary.Cone = 0
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

SWEP.IronSightsPos = Vector(3.76, -0.5, 1.67)
SWEP.IronSightsAng = Vector(-0.6, 0, 0)

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
		self.shotsFired = 0
		self.fingerprints = {}
		self:SetIronsights(false)
	end

	self:SetDeploySpeed(self.DeploySpeed)

	if (self.SetHoldType) then
		self:SetHoldType(self.HoldType or "pistol")
	end

	PrecacheParticleSystem("smoke_trail")
end

function SWEP:PrimaryAttack()
	local owner = self.Owner

	if (self:CanPrimaryAttack() and owner:IsRole(ROLE_DETECTIVE)) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)


		owner:GetViewModel():StopParticles()

		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

		if SERVER then
			sound.Play(self.Primary.Sound, self:GetPos())
			self.shotsFired = self.shotsFired + 1

			local owner = self.Owner
			local title = "HandleGoldenDeagle" .. self:EntIndex() .. self.shotsFired

			hook.Add("EntityTakeDamage", title, function(ent, dmginfo)
				if (IsValid(ent) and ent:IsPlayer() and dmginfo:IsBulletDamage() and dmginfo:GetAttacker():GetActiveWeapon() == self) then
					if (ent:IsRole(ROLE_INNOCENT) or ent:IsRole(ROLE_DETECTIVE)) then
						local newdmg = DamageInfo()
						newdmg:SetDamage(1000)
						newdmg:SetAttacker(owner)
						newdmg:SetInflictor(self.Weapon)
						newdmg:SetDamageType(DMG_BULLET)
						newdmg:SetDamagePosition(owner:GetPos())

						hook.Remove("EntityTakeDamage", title) -- remove hook before applying new damage
						owner:TakeDamageInfo(newdmg)
						return true -- block all damage
					elseif (ent:IsRole(ROLE_TRAITOR)) then
						hook.Remove("EntityTakeDamage", title)
						dmginfo:ScaleDamage(100) -- should always be deadly
					end
				end
			end)

			timer.Simple(1, function() hook.Remove("EntityTakeDamage", title) end) -- wait 1 seconds for the damage
		end

		self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone())
		self:TakePrimaryAmmo(1)

		if (IsValid(owner) and !owner:IsNPC() and owner.ViewPunch) then
			owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) * self.Primary.Recoil, 0))
		end

		timer.Simple(0.5, function() if (IsValid(self) and IsValid(self.Owner)) then ParticleEffectAttach("smoke_trail", PATTACH_POINT_FOLLOW, self.Owner:GetViewModel(), 1) end end)
	end
end
