--- Author informations ---
SWEP.Author = "Zaratusa"
SWEP.Contact = "http://steamcommunity.com/profiles/76561198032479768"

if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("254177306")
elseif CLIENT then
	SWEP.PrintName = "M4 SLAM"
	SWEP.Slot = 7
	SWEP.Icon = "vgui/ttt/icon_slam"

	-- Equipment menu information is only needed on the client
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "A Mine which can be manually detonated\nor sticked on a wall as a tripmine.\n\nNOTE: Can be shot and destroyed by everyone."
	};
end

local cfg
if file.Exists("ttt_weapons/slam/config.txt", "DATA") then
	cfg = util.JSONToTable(file.Read("ttt_weapons/slam/config.txt", "DATA"))
else
	cfg = { }
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

--- Default GMod values ---
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = cfg.MaxSlams or 5
SWEP.Primary.DefaultClip = cfg.BoughtSlams or 2
SWEP.Secondary.Delay = 0.3
SWEP.FiresUnderwater = false

--- Model settings ---
SWEP.HoldType = "slam"

SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 64
SWEP.ViewModel = Model("models/weapons/v_slam.mdl")
SWEP.WorldModel	= Model("models/weapons/w_slam.mdl")

--- TTT config values ---

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP2

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2,
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_TRAITOR }

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "ActiveSatchel")
end

function SWEP:Initialize()
	self.State = "NONE"
	self:SetActiveSatchel(0)
end

function SWEP:PrimaryAttack()
	if (self:CanPrimaryAttack()) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

		if (self.State == "SATCHEL") then
			self:ThrowSatchel()
		else
			self:StickTripmine()
		end
	end
end

function SWEP:ThrowSatchel()
	local owner = self.Owner
	if (SERVER and IsValid(owner)) then
		local slam = ents.Create("ttt_slam_satchel")
		if (IsValid(slam)) then
			local holdup
			if (self:GetActiveSatchel() > 0) then
				self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_THROW)
				holdup = self.Owner:GetViewModel():SequenceDuration()
				timer.Simple(holdup, function() if (IsValid(self)) then self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_THROW2) end end)
			else
				self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_THROW_ND)
				holdup = self.Owner:GetViewModel():SequenceDuration()
				timer.Simple(holdup, function() if (IsValid(self)) then self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_THROW_ND2) end end)
			end

			local src = owner:GetShootPos()
			local ang = owner:GetAimVector()
			local vel = owner:GetVelocity()
			local throw = vel + ang * 200

			slam:SetPos(src + ang * 10)
			slam:SetPlacer(owner)
			slam:SetPlacedBy(self)
			slam:Spawn()

			slam.fingerprints = self.fingerprints

			slam:PhysWake()
			local phys = slam:GetPhysicsObject()
			if (IsValid(phys)) then
				phys:SetVelocity(throw)
			end

			timer.Simple(holdup + 0.1, function()
				self:EmitSound(Sound("Weapon_SLAM.SatchelThrow"))
				self:ChangeActiveSatchel(1)
				self:TakePrimaryAmmo(1)
			end)
		end
		owner:SetAnimation(PLAYER_ATTACK1)
	end
end

function SWEP:ChangeActiveSatchel(amount)
	if (IsValid(self)) then
		self:SetActiveSatchel(self:GetActiveSatchel() + amount)
		self.State = "NONE"
		self:ChangeAnimation()
	end
end

function SWEP:StickTripmine()
	local owner = self.Owner
	if (SERVER and IsValid(owner)) then
		local ignore = {owner, self.Weapon}
		local spos = owner:GetShootPos()
		local epos = spos + owner:GetAimVector() * 42

		local tr = util.TraceLine({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID})
		if (tr.HitWorld) then
			local slam = ents.Create("ttt_slam_tripmine")
			if (IsValid(slam)) then
				local tr_ent = util.TraceEntity({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID}, slam)
				if (tr_ent.HitWorld) then
					local holdup
					if (self:GetActiveSatchel() > 0) then
						self.Weapon:SendWeaponAnim(ACT_SLAM_STICKWALL_ATTACH)
						holdup = self.Owner:GetViewModel():SequenceDuration()
						timer.Simple(holdup, function() if (IsValid(self)) then self.Weapon:SendWeaponAnim(ACT_SLAM_STICKWALL_ATTACH2) end end)
					else
						self.Weapon:SendWeaponAnim(ACT_SLAM_TRIPMINE_ATTACH)
						holdup = self.Owner:GetViewModel():SequenceDuration()
						timer.Simple(holdup, function() if (IsValid(self)) then self.Weapon:SendWeaponAnim(ACT_SLAM_TRIPMINE_ATTACH2) end end)
					end

					local ang = tr_ent.HitNormal:Angle()
					ang.p = ang.p + 90
					slam:SetPos(tr_ent.HitPos + (tr_ent.HitNormal * 3))
					slam:SetAngles(ang)
					slam:SetPlacer(owner)
					slam:Spawn()

					slam.fingerprints = self.fingerprints

					-- slam shouldn't move on the wall
					local phys = slam:GetPhysicsObject()
					if (IsValid(phys)) then
						phys:EnableMotion(false)
					end

					timer.Simple(holdup + 0.1, function()
						self:EmitSound(Sound("weapons/slam/mine_mode.wav"))
						self:TakePrimaryAmmo(1)

						if ((self:GetActiveSatchel() <= 0) and self.Weapon:Clip1() == 0 and self.Owner:GetAmmoCount(self.Weapon:GetPrimaryAmmoType()) == 0) then
							self:Remove()
						else
							self.State = "NONE"
							self:ChangeAnimation()
						end
					end)
				end
			end
		end
		owner:SetAnimation(PLAYER_ATTACK1)
	end
end

function SWEP:SecondaryAttack()
	if (SERVER and self:GetActiveSatchel() > 0 and self:CanSecondaryAttack()) then
		self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
		if (self.State == "SATCHEL") then
			self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_DETONATE)
		elseif (self.State == "TRIPMINE") then
			self.Weapon:SendWeaponAnim(ACT_SLAM_STICKWALL_DETONATE)
		else
			self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)
		end
		self:EmitSound(Sound("weapons/c4/c4_beep1.wav"))

		for _, slam in pairs(ents.FindByClass("ttt_slam_satchel")) do
			if (slam:IsActive() and slam:GetPlacedBy() == self) then
				slam:StartExplode()
			end
		end

		if ((self:GetActiveSatchel() <= 0) and self.Weapon:Clip1() == 0 and self.Owner:GetAmmoCount(self.Weapon:GetPrimaryAmmoType()) == 0) then
			self:Remove()
		else
			self.State = "NONE"
			self:ChangeAnimation()
		end
	end
end

if SERVER then
	function SWEP:Think()
		self:ChangeAnimation()

		if ((self:GetActiveSatchel() <= 0) and self.Weapon:Clip1() == 0 and self.Owner:GetAmmoCount(self.Weapon:GetPrimaryAmmoType()) == 0) then
			self:Remove()
		end

		self:NextThink(CurTime() + 0.25)
		return true
	end
end

function SWEP:CanAttachSLAM()
	local result = false

	if (IsValid(self)) then
		local owner = self.Owner

		if (IsValid(owner)) then
			local ignore = {owner, self.Weapon}
			local spos = owner:GetShootPos()
			local epos = spos + owner:GetAimVector() * 42
			local tr = util.TraceLine({start = spos, endpos = epos, filter = ignore, mask = MASK_SOLID})

			result = tr.HitWorld
		end
	end

	return result
end

function SWEP:Deploy()
	self:ChangeAnimation()
	return true
end

function SWEP:ChangeAnimation()
	if (self:CanAttachSLAM()) then
		if (self.State == "SATCHEL") then
			if (self:GetActiveSatchel() > 0) then
				self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_TO_STICKWALL)
			else
				self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_TO_TRIPMINE_ND)
			end
			self.State = "TRIPMINE"
		elseif (self.State == "NONE") then
			if (self:GetActiveSatchel() > 0) then
				self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_THROW_DRAW)
				self.State = "SATCHEL"
			else
				self.Weapon:SendWeaponAnim(ACT_SLAM_TRIPMINE_DRAW)
				self.State = "TRIPMINE"
			end
		else
			if (self:GetActiveSatchel() > 0) then
				self.Weapon:SendWeaponAnim(ACT_SLAM_STICKWALL_DETONATOR_HOLSTER)
			end
		end
	elseif (self.Weapon:Clip1() > 0) then
		if (self.State == "TRIPMINE") then
			if (self:GetActiveSatchel() > 0) then
				self.Weapon:SendWeaponAnim(ACT_SLAM_STICKWALL_TO_THROW)
			else
				self.Weapon:SendWeaponAnim(ACT_SLAM_STICKWALL_TO_THROW_ND)
			end
		elseif (self.State == "NONE") then
			if (self:GetActiveSatchel() > 0) then
				self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_THROW_DRAW)
			else
				self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_ND_DRAW)
			end
		else
			if (self:GetActiveSatchel() > 0) then
				self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_DETONATOR_HOLSTER)
			end
		end
		self.State = "SATCHEL"
	else
		self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
	end
end

function SWEP:Holster()
	self.State = "NONE"
	return true
end

function SWEP:OnRemove()
	if (CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive()) then
		RunConsoleCommand("lastinv")
	end
end

-- Reload does nothing
function SWEP:Reload()
end
