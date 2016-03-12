AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

hook.Add("TTTPrepareRound", "MineTurtleClean", function()
	for _, slam in pairs(ents.FindByClass("ttt_mine_turtle")) do
		slam:Remove()
	end
end)

function ENT:Think()
	if (IsValid(self) and self:IsActive()) then
		if (!self.HelloPlayed) then
			for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.ScanRadius)) do
				if (IsValid(ent) and ent:IsPlayer() and !ent:IsSpec()) then
					self:EmitSound(self.ClickSound)
					timer.Simple(0.15, function() if (IsValid(self)) then sound.Play(self.HelloSound, self:GetPos(), 100, math.random(95, 105), 1) end end)
					self.HelloPlayed = true

					timer.Simple(0.85, function() if (IsValid(self)) then self:StartExplode(true) end end)
					break
				end
			end
		end

		self:NextThink(CurTime() + 0.1)
		return true
	end
end

function ENT:SendWarn(armed)
	net.Start("TTT_MineTurtleWarning")
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
		LANG.Msg(owner, "mine_turtle_disarmed")
	end

	self:SetDefusable(false)
	self:SendWarn(false)
end

function ENT:OnRemove()
	self:SendWarn(false)
end
