--- Author informations ---
SWEP.Author = "Zaratusa"
SWEP.Contact = "http://steamcommunity.com/profiles/76561198032479768"

if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("645663146")
else
	SWEP.PrintName = "Sandwich"
	SWEP.Slot = 7
	SWEP.Icon = "vgui/ttt/icon_sandwich"

	-- Equipment menu information is only needed on the client
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Have a snack\nand heal yourself or others."
	}
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

--- Default GMod values ---
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 2
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 4
SWEP.Primary.DefaultClip = 4

SWEP.HealAmount = 25

--- Model settings ---
SWEP.HoldType = "slam"

SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 70
SWEP.ViewModel = Model("models/weapons/zaratusa/sandwich/v_sandwich.mdl")
SWEP.WorldModel = Model("models/weapons/zaratusa/sandwich/w_sandwich.mdl")

--- TTT config values ---

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP2

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2,
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "none"

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_DETECTIVE, ROLE_TRAITOR }

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = false

local HealSound = Sound("weapons/sandwich/eat.wav")

function SWEP:PrimaryAttack()
	if (SERVER and self:CanPrimaryAttack() and self:GetNextPrimaryFire() <= CurTime()) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

		local owner = self.Owner
		if (IsValid(owner)) then
			local tr = util.TraceLine({
				start = owner:GetShootPos(),
				endpos = owner:GetShootPos() + owner:GetAimVector() * 80,
				filter = owner,
				mask = MASK_SOLID
			})
			local ent = tr.Entity
			if (IsValid(ent) and ent:IsPlayer() and ent:Health() < ent:GetMaxHealth()) then
				self:Heal(ent)
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if (SERVER and self:CanSecondaryAttack() and self:GetNextSecondaryFire() <= CurTime()) then
		self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

		local owner = self.Owner
		if (IsValid(owner) and owner:Health() < owner:GetMaxHealth()) then
			self:Heal(owner)
		end
	end
end

function SWEP:Heal(player)
	player:SetHealth(math.min(player:GetMaxHealth(), player:Health() + self.HealAmount))
	player:EmitSound(HealSound)
	player:SetAnimation(PLAYER_ATTACK1)

	self:TakePrimaryAmmo(1)
	if (self.Weapon:Clip1() < 1) then
		self:Remove()
	end
end

function SWEP:OnRemove()
	if (CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive()) then
		RunConsoleCommand("lastinv")
	end
end

function SWEP:DrawHUD()
	local x = ScrW() / 2.0
	local y = ScrH() * 0.995

	draw.SimpleText("Primary attack to feed someone else.", "Default", x, y - 20, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("Secondary attack to eat.", "Default", x, y, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

	return self.BaseClass.DrawHUD(self)
end
