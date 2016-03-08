-- Author: Zaratusa
-- Contact: http://steamcommunity.com/profiles/76561198032479768

if SERVER then
	AddCSLuaFile()
elseif CLIENT then
	ENT.Icon = "vgui/ttt/icon_slam"
	ENT.PrintName = "M4 SLAM"
	ENT.LaserMaterial = Material("trails/laser")

	LANG.AddToLanguage("english", "slam_full", "You currently cannot carry SLAM's.")
	LANG.AddToLanguage("english", "slam_disarmed", "A SLAM you've planted has been disarmed.")
end

ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_slam.mdl")

ENT.CanHavePrints = true
ENT.CanUseKey = true
ENT.Avoidable = true

ENT.BlastRadius = 200
ENT.BlastDamage = 1000
local Laser = {}

AccessorFunc(ENT, "Placer", "Placer") -- using Placer instead of Owner, so everyone can damage the SLAM

-- sounds
local beepSound = Sound("weapons/c4/c4_beep1.wav")
local explosionSound = Sound("Weapon_SLAM.SatchelDetonate")

-- clean up
if SERVER then
	hook.Add("TTTPrepareRound", "SLAMClean", function()
		for _, slam in pairs(ents.FindByClass("ttt_slam_tripmine")) do
			slam:Remove()
		end
	end)
else
	hook.Add("TTTPrepareRound", "SLAMClean", function()
		for _, slam in pairs(Laser) do
			hook.Remove("PostDrawTranslucentRenderables", "SLAMBeam" .. slam)
		end
		Laser = {}
	end)
end

-- function for better legibility
function ENT:IsActive()
	return self:GetDefusable()
end

-- function for defuser
function ENT:Defusable()
	return self:GetDefusable()
end

function ENT:SetupDataTables()
   self:NetworkVar("Bool", 0, "Defusable") -- same as active on C4, just for defuser compatibility
end

function ENT:Initialize()
	if (IsValid(self)) then
		self:SetModel(self.Model)

		if SERVER then
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_NONE)
		end
		self:SetSolid(SOLID_BBOX)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		if SERVER then
			self:SetUseType(SIMPLE_USE)
			self:SetMaxHealth(10)
		end
		self:SetHealth(10)

		if (self:GetPlacer()) then
			if (!self:GetPlacer():IsActiveTraitor()) then
				self.Avoidable = false
			end
		else
			self:SetPlacer(nil)
		end

		self:SetDefusable(false)
		self.Exploding = false
		self:SetBodygroup(0, 1)

		if SERVER then
			self:SendWarn(true)
		end

		timer.Simple(1.5, function() if IsValid(self) then self:ActivateSLAM() end end)
	end
end

function ENT:ActivateSLAM()
	if (IsValid(self)) then
		self.LaserPos = self:GetAttachment(self:LookupAttachment("beam_attach")).Pos

		local ignore = ents.GetAll()
		local tr = util.QuickTrace(self.LaserPos, self:GetUp() * 10000, ignore)
		self.LaserLength = tr.Fraction
		self.LaserEndPos = tr.HitPos

		self:SetDefusable(true)

		if CLIENT then
			local index = self:EntIndex()
			hook.Add("PostDrawTranslucentRenderables", "SLAMBeam" .. index, function()
				if (IsValid(self) and self:IsActive()) then
					render.SetMaterial(self.LaserMaterial)
					if (LocalPlayer():IsTraitor() or LocalPlayer():HasWeapon("weapon_ttt_defuser")) then
						render.DrawBeam(self.LaserPos, self.LaserEndPos, 2, 1, 1, Color(255, 0, 0, 255))
					else
						render.DrawBeam(self.LaserPos, self.LaserEndPos, 0.5, 1, 1, Color(75, 0, 0, 255))
					end
				end
			end)
			table.insert(Laser, index)
		end

		if SERVER then
			sound.Play(beepSound, self:GetPos(), 65, 110, 0.7)
		end
	end
end

function ENT:UseOverride(activator)
	if (IsValid(self) and (!self.Exploding) and IsValid(activator) and activator:IsPlayer()) then
		local owner = self:GetPlacer()
		if ((self:IsActive() and owner == activator) or (!self:IsActive())) then
			-- check if the user already has a slam
			if (activator:HasWeapon("weapon_ttt_slam")) then
				local weapon = activator:GetWeapon("weapon_ttt_slam")
				weapon:SetClip1(weapon:Clip1() + 1)
			else
				local weapon = activator:Give("weapon_ttt_slam")
				weapon:SetClip1(1)
			end

			-- remove the entity
			if activator:HasWeapon("weapon_ttt_slam") then
				self:Remove()
			else
				LANG.Msg(activator, "slam_full")
			end
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	if (IsValid(self)) then
		-- it can still explode, even if defused
		self:SetHealth(self:Health() - dmginfo:GetDamage())
		if (self:Health() <= 0) then
			self:StartExplode()
		end
	end
end

function ENT:StartExplode()
	if (!self.Exploding) then
		self:EmitSound(beepSound)
		timer.Simple(0.1, function() if (IsValid(self)) then self:Explode() end end)
	end
end

function ENT:Explode()
	if (IsValid(self) and !self.Exploding) then
		self.Exploding = true
		local pos = self:GetPos()
		local radius = self.BlastRadius
		local damage = self.BlastDamage

		self:EmitSound(explosionSound, 60, math.random(125, 150))

		util.BlastDamage(self, self:GetPlacer(), pos, radius, damage)

		local effect = EffectData()
		effect:SetStart(pos)
		effect:SetOrigin(pos)
		effect:SetScale(radius)
		effect:SetRadius(radius)
		effect:SetMagnitude(damage)
		util.Effect("Explosion", effect, true, true)

		self:Remove()
	end
end

if SERVER then
	function ENT:SendWarn(armed)
		net.Start("TTT_SLAMWarning")
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteBool(armed)
		net.WriteVector(self:GetPos())
		local owner = self:GetPlacer()
		if (IsValid(owner) and owner:IsRole(ROLE_TRAITOR)) then
			net.Send(GetTraitorFilter(true))
		end
	end

	function ENT:Disarm(ply)
		local owner = self:GetPlacer()
		SCORE:HandleC4Disarm(ply, owner, true)

		if (IsValid(owner)) then
			LANG.Msg(owner, "slam_disarmed")
		end

		self:SetBodygroup(0, 0)
		self:SetDefusable(false)
		self:SendWarn(false)
	end

	function ENT:Think()
		if (IsValid(self) and self:IsActive()) then
			local tr = util.QuickTrace(self.LaserPos, self:GetUp() * 10000, self)

			if (tr.Fraction < self.LaserLength and (!self.Exploding)) then
				local ent = tr.Entity

				if (IsValid(ent) and ent:IsPlayer() and (!ent:IsSpec())) then
					self:StartExplode()
				end
			end

			self:NextThink(CurTime() + 0.05)
			return true
		end
	end

	function ENT:OnRemove()
		self:SendWarn(false)
	end
end
