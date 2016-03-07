--- Author informations ---
SWEP.Author = "Zaratusa"
SWEP.Contact = "http://steamcommunity.com/profiles/76561198032479768"

if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("634300198")
elseif CLIENT then
	SWEP.PrintName = "Jihad Bomb"
	SWEP.Slot = 8
	SWEP.Icon = "vgui/ttt/icon_jihad_bomb"

	-- Equipment menu information is only needed on the client
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Sacrifice yourself to Allah.\nYour 72 virgins await.\n\nNOTE: This is not refundable after use."
	};
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

--- Default GMod values ---
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 5
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

--- Model settings ---
SWEP.HoldType = "slam"

SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 54
SWEP.ViewModel = Model("models/weapons/zaratusa/jihad_bomb/v_jb.mdl")
SWEP.WorldModel = Model("models/weapons/zaratusa/jihad_bomb/w_jb.mdl")

--- TTT config values ---

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_ROLE

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

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true

-- Precache sounds and models
function SWEP:Precache()
	util.PrecacheSound("weapons/jihad_bomb/jihad.wav")
	util.PrecacheSound("weapons/jihad_bomb/big_explosion.wav")

	util.PrecacheModel("models/humans/charple01.mdl")
	util.PrecacheModel("models/humans/charple02.mdl")
	util.PrecacheModel("models/humans/charple03.mdl")
	util.PrecacheModel("models/humans/charple04.mdl")
end

local function ScorchUnderRagdoll(ent)
	-- big scorch at center
	local mid = ent:LocalToWorld(ent:OBBCenter())
	mid.z = mid.z + 25
	util.PaintDown(mid, "Scorch", ent)
end

-- Checks if the burn time is over, or if the body is in water
local function RunIgniteTimer(tname, body, burn_destroy)
	if (IsValid(body)) then
		if (CurTime() > burn_destroy) then
			body:SetNotSolid(true)
			body:Remove()
		elseif (body:WaterLevel() > 0) then
			body:Extinguish()
			timer.Destroy(tname)
		end
	else
		timer.Destroy(tname)
	end
end

-- Burn the body of the user
local function BurnOwnersBody(model)
	local body
	-- Search for all ragdolls and the one with the given model
	for _, ragdoll in pairs(ents.FindByClass("prop_ragdoll")) do
		if (ragdoll:GetModel() == model) then
			body = ragdoll
		end
	end

	ScorchUnderRagdoll(body)

	if SERVER then
		local burn_time = 7.5
		local burn_destroy = CurTime() + burn_time
		local tname = "burn_jihad"
		timer.Simple(0.01, function() if (IsValid(body)) then body:Ignite(burn_time, 100) end end)
		timer.Create(tname, 0.1, math.ceil(1 + burn_time / 0.1), function () RunIgniteTimer(tname, body, burn_destroy) end)
	end
end

-- Particle effects / Begin attack
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.AllowDrop = false

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetNormal(self:GetPos())
	effectdata:SetMagnitude(8)
	effectdata:SetScale(1)
	effectdata:SetRadius(20)
	util.Effect("Sparks", effectdata)
	self.BaseClass.ShootEffects(self)

	-- The rest is only done on the server
	if SERVER then
		-- Only explode, if the code was completely typed in
		timer.Simple(2.05, function() if (IsValid(self.Owner)) then self:Explode() end end)
		self.Owner:EmitSound("weapons/jihad_bomb/jihad.wav", math.random(100, 150), math.random(95, 105))
	end
end

-- Explosion properties
function SWEP:Explode()
	local pos = self:GetPos()
	local dmg = 200
	local dmgowner = self.Owner

	local r_inner = 550
	local r_outer = r_inner * 1.15

	self:EmitSound("weapons/jihad_bomb/big_explosion.wav", 400, math.random(100, 125))

	-- change body to a random charred body
	local model = "models/humans/charple0" .. math.random(1,4) .. ".mdl"
	self.Owner:SetModel(model)

	-- damage through walls
	self:SphereDamage(dmgowner, pos, r_inner)

	-- explosion damage
	util.BlastDamage(self, dmgowner, pos, r_outer, dmg)

	local effect = EffectData()
	effect:SetStart(pos)
	effect:SetOrigin(pos)
	effect:SetScale(r_outer)
	effect:SetRadius(r_outer)
	effect:SetMagnitude(dmg)
	util.Effect("Explosion", effect, true, true)

	self:Remove()
	BurnOwnersBody(model)
end

-- Calculate who is affected by the damage
function SWEP:SphereDamage(dmgowner, center, radius)
	local r = radius ^ 2 -- square so we can compare with dotproduct directly

	local d = 0.0
	local diff = nil
	local dmg = 0
	for _, ent in pairs(player.GetAll()) do
		if (IsValid(ent) and ent:Team() == TEAM_TERROR) then

			-- dot of the difference with itself is distance squared
			diff = center - ent:GetPos()
			d = diff:Dot(diff)

			if d < r then
				-- deadly up to a certain range, then a quick falloff
				d = math.max(0, math.sqrt(d) - 400)
				dmg = -0.01 * (d^2) + 125

				local dmginfo = DamageInfo()
				dmginfo:SetDamage(dmg)
				dmginfo:SetAttacker(dmgowner)
				-- dmginfo:SetInflictor(self)
				dmginfo:SetDamageType(DMG_BLAST)
				dmginfo:SetDamageForce(diff)
				dmginfo:SetDamagePosition(ent:GetPos())

				ent:TakeDamageInfo(dmginfo)
			end
		end
	end
end

-- Secondary attack does nothing
function SWEP:SecondaryAttack()
end

-- Reload does nothing
function SWEP:Reload()
end
