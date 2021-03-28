//---------------------------------------------------------------------------------------
//  FILE:   X2Item_XCOM_Xenolator.uc                                    
//  
//	File created by RustyDios	24/11/19	02:45
//	LAST UPDATED				08/06/20	11:20
//
//	Creates and add the Xenolator templates to the game
//	These are unique drops from the (CX Captain) Purifiers and CX Bio Mec Troopers
//
//*******************************************************************************************

class X2Item_XCOM_Xenolator extends X2Item config (Xenolator);

//var config stuffs
var config WeaponDamageValue		iXENOLATOR_BASEDAMAGE_CV,	iXENOLATOR_BASEDAMAGE_MG,	iXENOLATOR_BASEDAMAGE_BM,	iXENOLATOR_BASEDAMAGE_AC,	iXENOLATOR_BASEDAMAGE_PO;
var config array<WeaponDamageValue> iXENOLATOR_SkillDamage_CV,	iXENOLATOR_SkillDamage_MG,	iXENOLATOR_SkillDamage_BM,	iXENOLATOR_SkillDamage_AC,	iXENOLATOR_SkillDamage_PO;

var config int	iXENOLATOR_SOUNDRANGE, iXENOLATOR_ENVIRONMENTDAMAGE;
var config int	iXENOLATOR_CV_SLOTS, iXENOLATOR_MG_SLOTS, iXENOLATOR_BM_SLOTS, iXENOLATOR_CV_CLIPSIZE, iXENOLATOR_MG_CLIPSIZE, iXENOLATOR_BM_CLIPSIZE;
var config int	iXENOLATOR_CV_BURNDAMAGE, iXENOLATOR_CV_BURNSPREAD, iXENOLATOR_MG_BURNDAMAGE, iXENOLATOR_MG_BURNSPREAD, iXENOLATOR_BM_BURNDAMAGE, iXENOLATOR_BM_BURNSPREAD;
var config int	iXENOLATOR_CV_SELL, iXENOLATOR_MG_SELL, iXENOLATOR_BM_SELL; 
var config float		fXENOLATOR_TILE_COVERAGE_PERCENT;
var config bool			bXENOLATOR_INFINITEAMMO;
var config array<int>	iXENOLATOR_RANGEACCURACY;

var config array<name>	strCV_RESOURCE_COST_TYPE, strMG_RESOURCE_COST_TYPE, strBM_RESOURCE_COST_TYPE, strPO_RESOURCE_COST_TYPE, strAC_RESOURCE_COST_TYPE;
var config array<int>	iCV_RESOURCE_COST_AMOUNT, iMG_RESOURCE_COST_AMOUNT, iBM_RESOURCE_COST_AMOUNT, iPO_RESOURCE_COST_AMOUNT, iAC_RESOURCE_COST_AMOUNT;

//add the templates
static function array<X2DataTemplate> Createtemplates()
{
	local array<X2DataTemplate> Weapons;

	Weapons.AddItem(Create_XCOM_Xenolator_CV());
	Weapons.AddItem(Create_XCOM_Xenolator_MG());
	Weapons.AddItem(Create_XCOM_Xenolator_BM());

	Weapons.AddItem(Create_XCOM_Xenolator_AC());
	Weapons.AddItem(Create_XCOM_Xenolator_PO());

	return Weapons;
}

//create the templates
static function X2WeaponTemplate Create_XCOM_Xenolator_CV()
{
	local X2WeaponTemplate				Template;
	local ArtifactCost					Resources;
	local int i;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'XCOM_Xenolator_CV');

	// weapon setup
	Template.ItemCat =				'weapon';
	Template.WeaponCat =			'chemthrower';
	Template.WeaponTech =			'conventional';
	Template.strImage =				"img:///UILibrary_RustyXenolator.Inv_Xenolator";
	Template.EquipSound =			"Conventional_Weapon_Equip";
	Template.Tier =					1;
	Template.InventorySlot =		eInvSlot_PrimaryWeapon;

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype =		"WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerXENO_NOTINT";
	// Original Option	= Template.GameArchetype = "WP_AdvFlamethrower_CX.Archetypes.WP_CX_AdvFlamethrower"	//	// this is from the Creative Xeno's Advent Purifier Revamp
	// OPTC Option		= Template.GameArchetype = "WP_XCOMChemthrowerMKII.WP_ChemthrowerXENO";	//this is the tintable version

	//get them to show up in the armoury									// used by the UI. Determines iconview of the weapon.
	Template.WeaponPanelImage = "_ConventionalCannon";									//attachment icons in the slots
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon';			//viewpoint for camera
	Template.bIsLargeWeapon = true;														//tells UI camera to back off
	Template.AddDefaultAttachment('Light', "ConvAttachments.Meshes.SM_ConvFlashLight");	//adds a flashlight

	// weapon values
	Template.DamageTypeTemplateName = 'Fire';
	Template.RangeAccuracy =		default.iXENOLATOR_RANGEACCURACY;
	Template.BaseDamage =			default.iXENOLATOR_BASEDAMAGE_CV;
	Template.ExtraDamage =			default.iXENOLATOR_SkillDamage_CV;
	Template.iSoundRange =			default.iXENOLATOR_SOUNDRANGE;
	Template.iEnvironmentDamage =	default.iXENOLATOR_ENVIRONMENTDAMAGE;
	Template.iClipSize =			default.iXENOLATOR_CV_CLIPSIZE;
	Template.iRange =				class'X2Ability_Xenolator'.default.XENOLATOR_TILE_LENGTH;
	Template.iRadius =				class'X2Ability_Xenolator'.default.XENOLATOR_TILE_WIDTH;
	Template.fCoverage =			default.fXENOLATOR_TILE_COVERAGE_PERCENT;
	
	Template.InfiniteAmmo =			default.bXENOLATOR_INFINITEAMMO;
	Template.bHideClipSizeStat =	default.bXENOLATOR_INFINITEAMMO;
	Template.bMergeAmmo =			true;
	Template.bCanBeDodged =			false;

	Template.iTypicalActionCost =	1;
	Template.NumUpgradeSlots=		default.iXENOLATOR_CV_SLOTS;
	
	// abilities copied from Mitzruti's Immolator/Chemthrower Abilities
	Template.Abilities.AddItem('RDThrowerShot_Fire');
	Template.Abilities.AddItem('Reload');
	Template.Abilities.AddItem('Overwatch');
	Template.Abilities.AddItem('RDThrowerOverwatchShot_Fire');

	// abilities copied from Creative Xeno's Advent Purifier Revamp
	Template.Abilities.AddItem('XENOLATOR_ArcCutter');

	Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateBurningStatusEffect(default.iXENOLATOR_CV_BURNDAMAGE, default.iXENOLATOR_CV_BURNSPREAD));

	// creation
	Template.CanBeBuilt = false;
	Template.PointsToComplete = 0;
	Template.bInfiniteItem = false;
	Template.StartingItem = false;

	//Template.RewardDecks.AddItem('ExperimentalChemthrowerRewards');

	// Cost
	for (i = 0; i < default.strCV_RESOURCE_COST_TYPE.Length; i++)
	{
		if (default.iCV_RESOURCE_COST_AMOUNT[i] > 0)
		{
			Resources.ItemTemplateName = default.strCV_RESOURCE_COST_TYPE[i];
			Resources.Quantity = default.iCV_RESOURCE_COST_AMOUNT[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}

	// Selling
	Template.TradingPostValue = default.iXENOLATOR_CV_SELL; 

	// UI aids
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , Template.iRange);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , Template.iRadius);

	return Template;
}

static function X2WeaponTemplate Create_XCOM_Xenolator_MG()
{
	local X2WeaponTemplate				Template;
	local ArtifactCost					Resources;
	local int i;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'XCOM_Xenolator_MG');

	// weapon setup
	Template.ItemCat =				'weapon';
	Template.WeaponCat =			'chemthrower';
	Template.WeaponTech =			'magnetic';
	Template.strImage =				"img:///UILibrary_RustyXenolator.Inv_Xenolator";
	Template.EquipSound =			"Magnetic_Weapon_Equip";
	Template.Tier =					4;
	Template.InventorySlot =		eInvSlot_PrimaryWeapon;

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype =		"WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerXENO_NOTINT";
	// Original Option	= Template.GameArchetype = "WP_AdvFlamethrower_CX.Archetypes.WP_CX_AdvFlamethrower"	//	// this is from the Creative Xeno's Advent Purifier Revamp
	// OPTC Option		= Template.GameArchetype = "WP_XCOMChemthrowerMKII.WP_ChemthrowerXENO";	//this is the tintable version

	//get them to show up in the armoury									// used by the UI. Determines iconview of the weapon.
	Template.WeaponPanelImage = "_ConventionalCannon";									//attachment icons in the slots
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon';			//viewpoint for camera
	Template.bIsLargeWeapon = true;														//tells UI camera to back off
	Template.AddDefaultAttachment('Light', "ConvAttachments.Meshes.SM_ConvFlashLight");	//adds a flashlight

	// weapon values
	Template.DamageTypeTemplateName = 'Fire';
	Template.RangeAccuracy =		default.iXENOLATOR_RANGEACCURACY;
	Template.BaseDamage =			default.iXENOLATOR_BASEDAMAGE_MG;
	Template.ExtraDamage =			default.iXENOLATOR_SkillDamage_MG;
	Template.iSoundRange =			default.iXENOLATOR_SOUNDRANGE;
	Template.iEnvironmentDamage =	default.iXENOLATOR_ENVIRONMENTDAMAGE;
	Template.iClipSize =			default.iXENOLATOR_MG_CLIPSIZE;
	Template.iRange =				class'X2Ability_Xenolator'.default.XENOLATOR_TILE_LENGTH;
	Template.iRadius =				class'X2Ability_Xenolator'.default.XENOLATOR_TILE_WIDTH;
	Template.fCoverage =			default.fXENOLATOR_TILE_COVERAGE_PERCENT;
	
	Template.InfiniteAmmo =			default.bXENOLATOR_INFINITEAMMO;
	Template.bHideClipSizeStat =	default.bXENOLATOR_INFINITEAMMO;
	Template.bMergeAmmo =			true;
	Template.bCanBeDodged =			false;

	Template.iTypicalActionCost =	1;
	Template.NumUpgradeSlots=		default.iXENOLATOR_MG_SLOTS;
	
	// abilities added list from Mitzruti's Immolator/Chemthrower Abilities
	Template.Abilities.AddItem('RDThrowerShot_Fire');
	Template.Abilities.AddItem('Reload');
	Template.Abilities.AddItem('Overwatch');
	Template.Abilities.AddItem('RDThrowerOverwatchShot_Fire');

	// abilities added list from Creative Xeno's Advent Purifier Revamp
	Template.Abilities.AddItem('XENOLATOR_ArcCutter');
	Template.Abilities.AddItem('XENOLATOR_FlameArea');

	Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateBurningStatusEffect(default.iXENOLATOR_MG_BURNDAMAGE, default.iXENOLATOR_MG_BURNSPREAD));

	// creation
	Template.CanBeBuilt = false;
	Template.PointsToComplete = 0;
	Template.bInfiniteItem = false;
	Template.StartingItem = false;

	//Template.RewardDecks.AddItem('ExperimentalChemthrowerRewards');

	// Cost
	for (i = 0; i < default.strMG_RESOURCE_COST_TYPE.Length; i++)
	{
		if (default.iMG_RESOURCE_COST_AMOUNT[i] > 0)
		{
			Resources.ItemTemplateName = default.strMG_RESOURCE_COST_TYPE[i];
			Resources.Quantity = default.iMG_RESOURCE_COST_AMOUNT[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}

	// Selling
	Template.TradingPostValue = default.iXENOLATOR_MG_SELL; 

	// UI aids
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , Template.iRange);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , Template.iRadius);

	return Template;
}

static function X2WeaponTemplate Create_XCOM_Xenolator_BM()
{
	local X2WeaponTemplate				Template;
	local ArtifactCost					Resources;
	local int i;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'XCOM_Xenolator_BM');

	// weapon setup
	Template.ItemCat =				'weapon';
	Template.WeaponCat =			'chemthrower';
	Template.WeaponTech =			'beam';
	Template.strImage =				"img:///UILibrary_RustyXenolator.Inv_Xenolator";
	Template.EquipSound =			"Beam_Weapon_Equip";
	Template.Tier =					6;
	Template.InventorySlot =		eInvSlot_PrimaryWeapon;

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype =		"WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerXENO_NOTINT";
	// Original Option	= Template.GameArchetype = "WP_AdvFlamethrower_CX.Archetypes.WP_CX_AdvFlamethrower"	//	// this is from the Creative Xeno's Advent Purifier Revamp
	// OPTC Option		= Template.GameArchetype = "WP_XCOMChemthrowerMKII.WP_ChemthrowerXENO";	//this is the tintable version

	//get them to show up in the armoury									// used by the UI. Determines iconview of the weapon.
	Template.WeaponPanelImage = "_ConventionalCannon";									//attachment icons in the slots
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon';			//viewpoint for camera
	Template.bIsLargeWeapon = true;														//tells UI camera to back off
	Template.AddDefaultAttachment('Light', "ConvAttachments.Meshes.SM_ConvFlashLight");	//adds a flashlight

	// weapon values
	Template.DamageTypeTemplateName = 'Fire';
	Template.RangeAccuracy =		default.iXENOLATOR_RANGEACCURACY;
	Template.BaseDamage =			default.iXENOLATOR_BASEDAMAGE_BM;
	Template.ExtraDamage =			default.iXENOLATOR_SkillDamage_BM;
	Template.iSoundRange =			default.iXENOLATOR_SOUNDRANGE;
	Template.iEnvironmentDamage =	default.iXENOLATOR_ENVIRONMENTDAMAGE;
	Template.iClipSize =			default.iXENOLATOR_BM_CLIPSIZE;
	Template.iRange =				class'X2Ability_Xenolator'.default.XENOLATOR_TILE_LENGTH;
	Template.iRadius =				class'X2Ability_Xenolator'.default.XENOLATOR_TILE_WIDTH;
	Template.fCoverage =			default.fXENOLATOR_TILE_COVERAGE_PERCENT;
	
	Template.InfiniteAmmo =			default.bXENOLATOR_INFINITEAMMO;
	Template.bHideClipSizeStat =	default.bXENOLATOR_INFINITEAMMO;
	Template.bMergeAmmo =			true;
	Template.bCanBeDodged =			false;

	Template.iTypicalActionCost =	1;
	Template.NumUpgradeSlots=		default.iXENOLATOR_BM_SLOTS;
	
	// abilities added list from Mitzruti's Immolator/Chemthrower Abilities
	Template.Abilities.AddItem('RDThrowerShot_Fire');
	Template.Abilities.AddItem('Reload');
	Template.Abilities.AddItem('Overwatch');
	Template.Abilities.AddItem('RDThrowerOverwatchShot_Fire');

	// abilities added list from Creative Xeno's Advent Purifier Revamp
	Template.Abilities.AddItem('XENOLATOR_ArcCutter');
	Template.Abilities.AddItem('XENOLATOR_FlameArea');
	Template.Abilities.AddItem('XENOLATOR_Directed');
	
	Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateBurningStatusEffect(default.iXENOLATOR_BM_BURNDAMAGE, default.iXENOLATOR_BM_BURNSPREAD));

	// creation
	Template.CanBeBuilt = false;
	Template.PointsToComplete = 0;
	Template.bInfiniteItem = false;
	Template.StartingItem = false;

	Template.RewardDecks.AddItem('ExperimentalChemthrowerRewards');

	// Cost
	for (i = 0; i < default.strBM_RESOURCE_COST_TYPE.Length; i++)
	{
		if (default.iBM_RESOURCE_COST_AMOUNT[i] > 0)
		{
			Resources.ItemTemplateName = default.strBM_RESOURCE_COST_TYPE[i];
			Resources.Quantity = default.iBM_RESOURCE_COST_AMOUNT[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}

	// Selling
	Template.TradingPostValue = default.iXENOLATOR_BM_SELL; 

	// UI aids
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , Template.iRange);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , Template.iRadius);

	return Template;
}

static function X2WeaponTemplate Create_XCOM_Xenolator_AC()
{
	local X2WeaponTemplate				Template;
	local ArtifactCost					Resources;
	local int i;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'XCOM_Xenolator_AC');

	// weapon setup
	Template.ItemCat =				'weapon';
	Template.WeaponCat =			'chemthrower';
	Template.WeaponTech =			'beam';
	Template.strImage =				"img:///UILibrary_RustyXenolator.Inv_Xenolator_Bio";
	Template.EquipSound =			"Beam_Weapon_Equip";
	Template.Tier =					6;
	Template.InventorySlot =		eInvSlot_PrimaryWeapon;

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype =		"WP_XCOMChemthrowerMKII.WP_ChemthrowerACID_NOTINT";
	// OPTC Option = Template.GameArchetype =	"WP_XCOMChemthrowerMKII.WP_ChemthrowerACID";

	//get them to show up in the armoury									// used by the UI. Determines iconview of the weapon.
	Template.WeaponPanelImage = "_ConventionalCannon";									//attachment icons in the slots
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon';			//viewpoint for camera
	Template.bIsLargeWeapon = true;														//tells UI camera to back off
	Template.AddDefaultAttachment('Light', "ConvAttachments.Meshes.SM_ConvFlashLight");	//adds a flashlight

	// weapon values
	Template.DamageTypeTemplateName = 'Acid';
	Template.RangeAccuracy =		default.iXENOLATOR_RANGEACCURACY;
	Template.BaseDamage =			default.iXENOLATOR_BASEDAMAGE_AC;
	Template.ExtraDamage =			default.iXENOLATOR_SkillDamage_AC;
	Template.iSoundRange =			default.iXENOLATOR_SOUNDRANGE;
	Template.iEnvironmentDamage =	default.iXENOLATOR_ENVIRONMENTDAMAGE;
	Template.iClipSize =			default.iXENOLATOR_BM_CLIPSIZE;
	Template.iRange =				class'X2Ability_Xenolator'.default.XENOLATOR_TILE_LENGTH;
	Template.iRadius =				class'X2Ability_Xenolator'.default.XENOLATOR_TILE_WIDTH;
	Template.fCoverage =			default.fXENOLATOR_TILE_COVERAGE_PERCENT;
	
	Template.InfiniteAmmo =			default.bXENOLATOR_INFINITEAMMO;
	Template.bHideClipSizeStat =	default.bXENOLATOR_INFINITEAMMO;
	Template.bMergeAmmo =			true;
	Template.bCanBeDodged =			false;

	Template.iTypicalActionCost =	1;
	Template.NumUpgradeSlots=		default.iXENOLATOR_BM_SLOTS;
	
	// abilities added list from Mitzruti's Immolator/Chemthrower Abilities
	Template.Abilities.AddItem('RDThrowerShot_Acid');
	Template.Abilities.AddItem('Reload');
	Template.Abilities.AddItem('Overwatch');
	Template.Abilities.AddItem('RDThrowerOverwatchShot_Acid');

	// abilities added list from Creative Xeno's Advent Purifier Revamp
	Template.Abilities.AddItem('XENOLATOR_ArcCutter');

	Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateAcidBurningStatusEffect(default.iXENOLATOR_BM_BURNDAMAGE, default.iXENOLATOR_BM_BURNSPREAD));

	// creation
	Template.CanBeBuilt = false;
	Template.PointsToComplete = 0;
	Template.bInfiniteItem = false;
	Template.StartingItem = false;

	Template.RewardDecks.AddItem('ExperimentalChemthrowerRewards');

	// Cost
	for (i = 0; i < default.strAC_RESOURCE_COST_TYPE.Length; i++)
	{
		if (default.iAC_RESOURCE_COST_AMOUNT[i] > 0)
		{
			Resources.ItemTemplateName = default.strAC_RESOURCE_COST_TYPE[i];
			Resources.Quantity = default.iAC_RESOURCE_COST_AMOUNT[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}

	// Selling
	Template.TradingPostValue = default.iXENOLATOR_BM_SELL; 

	// UI aids
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , Template.iRange);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , Template.iRadius);

	return Template;
}

static function X2WeaponTemplate Create_XCOM_Xenolator_PO()
{
	local X2WeaponTemplate				Template;
	local ArtifactCost					Resources;
	local int i;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'XCOM_Xenolator_PO');

	// weapon setup
	Template.ItemCat =				'weapon';
	Template.WeaponCat =			'chemthrower';
	Template.WeaponTech =			'beam';
	Template.strImage =				"img:///UILibrary_RustyXenolator.Inv_Xenolator_Bio";
	Template.EquipSound =			"Beam_Weapon_Equip";
	Template.Tier =					6;
	Template.InventorySlot =		eInvSlot_PrimaryWeapon;

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype =		"WP_XCOMChemthrowerMKII.WP_ChemthrowerACID_NOTINT";
	// OPTC Option = Template.GameArchetype =	"WP_XCOMChemthrowerMKII.WP_ChemthrowerACID";

	//get them to show up in the armoury									// used by the UI. Determines iconview of the weapon.
	Template.WeaponPanelImage = "_ConventionalCannon";									//attachment icons in the slots
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon';			//viewpoint for camera
	Template.bIsLargeWeapon = true;														//tells UI camera to back off
	Template.AddDefaultAttachment('Light', "ConvAttachments.Meshes.SM_ConvFlashLight");	//adds a flashlight

	// weapon values
	Template.DamageTypeTemplateName = 'Poison';
	Template.RangeAccuracy =		default.iXENOLATOR_RANGEACCURACY;
	Template.BaseDamage =			default.iXENOLATOR_BASEDAMAGE_PO;
	Template.ExtraDamage =			default.iXENOLATOR_SkillDamage_PO;
	Template.iSoundRange =			default.iXENOLATOR_SOUNDRANGE;
	Template.iEnvironmentDamage =	default.iXENOLATOR_ENVIRONMENTDAMAGE;
	Template.iClipSize =			default.iXENOLATOR_BM_CLIPSIZE;
	Template.iRange =				class'X2Ability_Xenolator'.default.XENOLATOR_TILE_LENGTH;
	Template.iRadius =				class'X2Ability_Xenolator'.default.XENOLATOR_TILE_WIDTH;
	Template.fCoverage =			default.fXENOLATOR_TILE_COVERAGE_PERCENT;
	
	Template.InfiniteAmmo =			default.bXENOLATOR_INFINITEAMMO;
	Template.bHideClipSizeStat =	default.bXENOLATOR_INFINITEAMMO;
	Template.bMergeAmmo =			true;
	Template.bCanBeDodged =			false;

	Template.iTypicalActionCost =	1;
	Template.NumUpgradeSlots=		default.iXENOLATOR_BM_SLOTS;
	
	// abilities added list from Mitzruti's Immolator/Chemthrower Abilities
	Template.Abilities.AddItem('RDThrowerShot_Poison');
	Template.Abilities.AddItem('Reload');
	Template.Abilities.AddItem('Overwatch');
	Template.Abilities.AddItem('RDThrowerOverwatchShot_Poison');

	// abilities added list from Creative Xeno's Advent Purifier Revamp
	Template.Abilities.AddItem('XENOLATOR_ArcCutter');
	
	Template.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreatePoisonedStatusEffect());

	// creation
	Template.CanBeBuilt = false;
	Template.PointsToComplete = 0;
	Template.bInfiniteItem = false;
	Template.StartingItem = false;

	Template.RewardDecks.AddItem('ExperimentalChemthrowerRewards');
	
	// Cost
	for (i = 0; i < default.strPO_RESOURCE_COST_TYPE.Length; i++)
	{
		if (default.iPO_RESOURCE_COST_AMOUNT[i] > 0)
		{
			Resources.ItemTemplateName = default.strPO_RESOURCE_COST_TYPE[i];
			Resources.Quantity = default.iPO_RESOURCE_COST_AMOUNT[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}

	// Selling
	Template.TradingPostValue = default.iXENOLATOR_BM_SELL; 

	// UI aids
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , Template.iRange);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , Template.iRadius);

	return Template;
}
