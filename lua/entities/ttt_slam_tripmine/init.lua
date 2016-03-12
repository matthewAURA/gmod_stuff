AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:ActivateSLAM()
	if (IsValid(self)) then
		self.LaserPos = self:GetAttachment(self:LookupAttachment("beam_attach")).Pos

		local ignore = ents.GetAll()
		local tr = util.QuickTrace(self.LaserPos, self:GetUp() * 10000, ignore)
		self.LaserLength = tr.Fraction
		self.LaserEndPos = tr.HitPos

		self:SetDefusable(true)

		sound.Play(self.BeepSound, self:GetPos(), 65, 110, 0.7)
	end
end

function ENT:Think()
	if (IsValid(self) and self:IsActive()) then
		local tr = util.QuickTrace(self.LaserPos, self:GetUp() * 10000, self)

		if (tr.Fraction < self.LaserLength and (!self.Exploding)) then
			local ent = tr.Entity

			if (IsValid(ent) and ent:IsPlayer() and (!ent:IsSpec())) then
				self:StartExplode(true)
			end
		end

		self:NextThink(CurTime() + 0.05)
		return true
	end
end
