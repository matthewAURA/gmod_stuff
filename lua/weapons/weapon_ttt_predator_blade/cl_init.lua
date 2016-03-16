include('shared.lua')

SWEP.PrintName = "Predator Blade"
SWEP.Slot = 6
SWEP.Icon = "vgui/ttt/icon_predator_blade"

-- Equipment menu information is only needed on the client
SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = "Awaken the predator in you.\nInstant kill everyone without body armor."
}

function SWEP:DrawHUD()
	local tr = self.Owner:GetEyeTrace(MASK_SHOT)
	local ent = tr.Entity

	if (tr.HitNonWorld and IsValid(ent) and ent:IsPlayer()) then
		local color, text
		if ((ent:TranslatePhysBoneToBone(tr.PhysicsBone) == 6) or (math.abs(math.AngleDifference(ent:GetAngles().y, self.Owner:GetAngles().y)) <= 50)) then
			color = Color(200 * 110 / LocalPlayer():GetPos():Distance(ent:GetPos()), 0, 200, 255 * 110 / LocalPlayer():GetPos():Distance(ent:GetPos()))
			text = "Instant kill"
		else
			color = Color(0, 0, 102 * 110 / LocalPlayer():GetPos():Distance(ent:GetPos()), 204 * 110 / LocalPlayer():GetPos():Distance(ent:GetPos()))
			text = "Weak"
		end

		local x = ScrW() / 2.0
		local y = ScrH() / 2.0

		local outer = 40
		local inner = 20

		surface.SetDrawColor(color)

		surface.DrawLine(x - outer, y - outer, x - inner, y - inner)
		surface.DrawLine(x + outer, y + outer, x + inner, y + inner)

		surface.DrawLine(x - outer, y + outer, x - inner, y + inner)
		surface.DrawLine(x + outer, y - outer, x + inner, y - inner)

		draw.SimpleText(text, "Default", x + 70, y - 55, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end

	return self.BaseClass.DrawHUD(self)
end
