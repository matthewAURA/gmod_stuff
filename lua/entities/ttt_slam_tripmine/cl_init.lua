include('shared.lua')

ENT.LaserMaterial = Material("trails/laser")
local Laser = {}

hook.Add("TTTPrepareRound", "SLAMLaserClean", function()
	for _, slam in pairs(Laser) do
		hook.Remove("PostDrawTranslucentRenderables", "SLAMBeam" .. slam)
	end
	Laser = {}
end)

function ENT:ActivateSLAM()
	if (IsValid(self)) then
		self.LaserPos = self:GetAttachment(self:LookupAttachment("beam_attach")).Pos

		local ignore = ents.GetAll()
		local tr = util.QuickTrace(self.LaserPos, self:GetUp() * 10000, ignore)
		self.LaserLength = tr.Fraction
		self.LaserEndPos = tr.HitPos

		self:SetDefusable(true)

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
end
