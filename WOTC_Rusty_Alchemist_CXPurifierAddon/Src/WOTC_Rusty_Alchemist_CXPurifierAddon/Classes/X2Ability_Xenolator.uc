//---------------------------------------------------------------------------------------
//  FILE:   X2Ability_Xenolator.uc                                    
//  
//	File created by RustyDios	24/11/19	02:45
//	LAST UPDATED				08/06/20	04:00
//
//	Creates and add the Xenolator, Corrolator and Toxilator abilities to the game
//
//*******************************************************************************************

class X2Ability_Xenolator extends X2Ability config (Xenolator);

//var config stuffs
var config int XENOLATOR_TILE_LENGTH, XENOLATOR_TILE_WIDTH, CHEMSTORM_RADIUS_METERS, Chemstorm_Cooldown, Chemstorm_Ammocost;

var config int XENOLATOR_DIRECTED_ACTIONPOINTCOST, XENOLATOR_DIRECTED_COOLDOWN, XENOLATOR_DIRECTED_AMMO, XENOLATOR_DIRECTED_TILE_LENGTH, XENOLATOR_DIRECTED_TILE_WIDTH;
var config bool XENOLATOR_DIRECTED_ACTIONPOINTCOST_TURNENDING, XENOLATOR_DIRECTED_ACTIONPOINTCOST_FREE, XENOLATOR_DIRECTED_AMMO_CONSUMEALL, XENOLATOR_DIRECTED_CANNOTMISS;

var config int XENOLATOR_FIREWALL_ACTIONPOINTCOST, XENOLATOR_FIREWALL_COOLDOWN, XENOLATOR_FIREWALL_AMMO, XENOLATOR_FIREWALL_TILE_LENGTH, XENOLATOR_FIREWALL_TILE_WIDTH;
var config bool XENOLATOR_FIREWALL_ACTIONPOINTCOST_TURNENDING, XENOLATOR_FIREWALL_ACTIONPOINTCOST_FREE, XENOLATOR_FIREWALL_AMMO_CONSUMEALL, XENOLATOR_FIREWALL_CANNOTMISS;

var config int XENOLATOR_ARCCUTTER_COOLDOWN;
var config bool XENOLATOR_ARCCUTTER_CANNOTMISS;

var config WeaponDamageValue XENOLATOR_DIRECTED_DMG, XENOLATOR_FIREWALL_DMG, XENOLATOR_ARCCUTTER_DMG, XENOLATOR_ARCCUTTER_ROBOT_DMG;
var config float XENOLATOR_FIRECHANCE_LVL1, XENOLATOR_FIRECHANCE_LVL2, XENOLATOR_FIRECHANCE_LVL3;

//add the templates
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	//copied abilities from CX Purifier
	Templates.AddItem(Create_XENOLATOR_Directed());
	Templates.AddItem(Create_XENOLATOR_FlameArea());
	Templates.AddItem(Create_XENOLATOR_ArcCutter());

	//copied abilities from Mitzruti's Immolator to get it to actually shoot like them, but with possibly different cone ranges
	Templates.AddItem(CreateRDThrowerShot('RDThrowerShot_Fire'));
	Templates.AddItem(CreateRDThrowerOverwatchShot('RDThrowerOverwatchShot_Fire'));
	//Templates.Additem(CreateRDChemstormShot()); // Mitzruti already has firestorm

	Templates.AddItem(CreateRDThrowerShot('RDThrowerShot_Acid'));
	Templates.AddItem(CreateRDThrowerOverwatchShot('RDThrowerOverwatchShot_Acid'));
	Templates.Additem(CreateRDChemstormShot('RDChemstorm_Acid'));

	Templates.AddItem(CreateRDThrowerShot('RDThrowerShot_Poison'));
	Templates.AddItem(CreateRDThrowerOverwatchShot('RDThrowerOverwatchShot_Poison'));
	Templates.Additem(CreateRDChemstormShot('RDChemstorm_Poison'));

	return Templates;
}

//create the standard shots
static function X2AbilityTemplate CreateRDThrowerShot(name TemplateName)
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCost_Ammo				AmmoCost;

	local X2AbilityTarget_Cursor			CursorTarget;
	local X2AbilityMultiTarget_Cone			ConeMultiTarget;
	local X2AbilityToHitCalc_StandardAim	StandardAim;

	local X2Effect_PersistentStatChange     DisorientedEffect;
	local X2Effect_ApplyMedikitHeal			MedikitHeal;
	local X2Condition_AbilityProperty		AbilityCondition;

	local X2Effect_ApplyWeaponDamage		WeaponDamageEffect;
	local X2Effect_ApplyFireToWorld			FireToWorldEffect;
	local X2Effect_ApplyAcidToWorld_Cone	AcidToWorldEffect;
	local X2Effect_ApplyPoisonToWorld		PoisonToWorldEffect;
	local array<name>                       SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	//setup
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_WrongSoldierClass');
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.Hostility = eHostility_Offensive;

	//costs actions
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllEffects.AddItem('MZBurningRush');
	Template.AbilityCosts.AddItem(ActionPointCost);

	//costs ammo
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	//targeting
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bMultiTargetOnly = true;
	Template.AbilityToHitCalc = StandardAim;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeEndDiameter = default.XENOLATOR_TILE_WIDTH * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = default.XENOLATOR_TILE_LENGTH * class'XComWorldData'.const.WORLD_StepSize;
		//add support for Mitzruti's attachment upgrades
	ConeMultiTarget.AddBonusConeSize('MZWidthNozzleBsc', 2, 0);
    ConeMultiTarget.AddBonusConeSize('MZWidthNozzleAdv', 3, 0);
    ConeMultiTarget.AddBonusConeSize('MZWidthNozzleSup', 4, 0);
    ConeMultiTarget.AddBonusConeSize('MZLengthNozzleBsc', 0, 1);
    ConeMultiTarget.AddBonusConeSize('MZLengthNozzleAdv', 0, 2);
    ConeMultiTarget.AddBonusConeSize('MZLengthNozzleSup', 0, 3);

	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.bCheckCollision = true;
	Template.bAffectNeighboringTiles = true;
	Template.bFragileDamageOnly = false;

	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Shooter conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	Template.AbilityMultiTargetConditions.AddItem(default.LivingTargetOnlyProperty);
	Template.AbilityMultiTargetConditions.AddItem(new class'X2Condition_FineControl');

	///////////////////damages and ability add ons///////////////////////////
	// basic weapon damage 

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bExplosiveDamage = true;
	Template.AddMultiTargetEffect(WeaponDamageEffect);

	//swap for spread type based on template name
	if (TemplateName == 'RDThrowerShot_Fire')
	{
		Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_flamethrower";

		FireToWorldEffect = new class'X2Effect_ApplyFireToWorld';
		FireToWorldEffect.bUseFireChanceLevel = true;
		FireToWorldEffect.bDamageFragileOnly = true;
		FireToWorldEffect.FireChance_Level1 = default.XENOLATOR_FIRECHANCE_LVL1;
		FireToWorldEffect.FireChance_Level2 = default.XENOLATOR_FIRECHANCE_LVL2;
		FireToWorldEffect.FireChance_Level3 = default.XENOLATOR_FIRECHANCE_LVL3;
		FireToWorldEffect.bCheckForLOSFromTargetLocation = false; //The flamethrower does its own LOS filtering
		Template.AddMultiTargetEffect(FireToWorldEffect);
	}

	if (TemplateName == 'RDThrowerShot_Acid')
	{
		Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_andromedon_acidblob";

		AcidToWorldEffect = new class'X2Effect_ApplyAcidToWorld_Cone';
		Template.AddMultiTargetEffect(AcidToWorldEffect);
	}

	if (TemplateName == 'RDThrowerShot_Poison')
	{
		Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_viper_poisonspit";

		PoisonToWorldEffect = new class'X2Effect_ApplyPoisonToWorld';
		Template.AddMultiTargetEffect(PoisonToWorldEffect);
	}
	
	//tie in Mitzruti's chemthrower abilities and effects	
	MedikitHeal = new class'X2Effect_ApplyMedikitHeal';
	MedikitHeal.PerUseHP = 1;
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('Phoenix');
	MedikitHeal.TargetConditions.AddItem(AbilityCondition);
	Template.AddShooterEffect(MedikitHeal);

	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();
	DisorientedEffect.iNumTurns = 2;
	DisorientedEffect.DamageTypes.AddItem('Mental');
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('FlamePanic');
	DisorientedEffect.TargetConditions.AddItem(AbilityCondition);
	Template.AddMultiTargetEffect(DisorientedEffect);

	Template.PostActivationEvents.AddItem('ChemthrowerActivated');

	Template.bAllowBonusWeaponEffects = true;

	///////////////////damages and ability add ons///////////////////////////

	//visualization and stuff
	Template.ActionFireClass = class'X2Action_Fire_Flamethrower';

	Template.ActivationSpeech = 'Flamethrower';
	//Template.CinescriptCameraType = "Soldier_HeavyWeapons";
	Template.CinescriptCameraType = "Iridar_Flamethrower";
	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bFrameEvenWhenUnitIsHidden = true;

    // Interactions with the Chosen and Shadow
    Template.SuperConcealmentLoss = 100;
    Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;

	return Template;
}

//create the overwatch shots
static function X2AbilityTemplate CreateRDThrowerOverwatchShot(name TemplateName)
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ReserveActionPoints ReserveActionPointCost;
	local X2AbilityCost_Ammo				AmmoCost;

	local X2AbilityMultiTarget_Cone			ConeMultiTarget;
	local X2AbilityToHitCalc_StandardAim	StandardAim;
	local X2Condition_Visibility			TargetVisibilityCondition;
	local X2Condition_UnitProperty          ShooterCondition;
	local X2AbilityTarget_Single            SingleTarget;
	local X2AbilityTrigger_EventListener	Trigger;

	local X2Effect_PersistentStatChange     DisorientedEffect;
	local X2Effect_ApplyMedikitHeal			MedikitHeal;
	local X2Condition_AbilityProperty		AbilityCondition;

	local X2Effect_ApplyWeaponDamage		WeaponDamageEffect;
	local X2Effect_ApplyFireToWorld			FireToWorldEffect;
	local X2Effect_ApplyAcidToWorld_Cone	AcidToWorldEffect;
	local X2Effect_ApplyPoisonToWorld		PoisonToWorldEffect;
	local array<name>                       SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	//setup
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY + 1;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.Hostility = eHostility_Offensive;

	//costs action point - overwatch
	ReserveActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ReserveActionPointCost.iNumPoints = 1;
	ReserveActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint);
	Template.AbilityCosts.AddItem(ReserveActionPointCost);

	//costs ammo
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	//targeting
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bReactionFire = true;
	StandardAim.bOnlyMultiHitWithSuccess = false;
	Template.AbilityToHitCalc = StandardAim;

	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeEndDiameter = default.XENOLATOR_TILE_WIDTH * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = default.XENOLATOR_TILE_LENGTH * class'XComWorldData'.const.WORLD_StepSize;
		//add support for Mitzruti's attachment upgrades
	ConeMultiTarget.AddBonusConeSize('MZWidthNozzleBsc', 2, 0);
    ConeMultiTarget.AddBonusConeSize('MZWidthNozzleAdv', 3, 0);
    ConeMultiTarget.AddBonusConeSize('MZWidthNozzleSup', 4, 0);
    ConeMultiTarget.AddBonusConeSize('MZLengthNozzleBsc', 0, 1);
    ConeMultiTarget.AddBonusConeSize('MZLengthNozzleAdv', 0, 2);
    ConeMultiTarget.AddBonusConeSize('MZLengthNozzleSup', 0, 3);

	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.bCheckCollision = true;
	Template.bAffectNeighboringTiles = true;
	Template.bFragileDamageOnly = false;
	Template.bAllowFreeFireWeaponUpgrade = false;

	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	//Trigger on movement - interrupt the move
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'ObjectMoved';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalOverwatchListener;
	Template.AbilityTriggers.AddItem(Trigger);

	// Shooter conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	ShooterCondition = new class'X2Condition_UnitProperty';
	ShooterCondition.ExcludeConcealed = true;
	Template.AbilityShooterConditions.AddItem(ShooterCondition);

	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bRequireBasicVisibility = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true; //Don't use peek tiles for over watch shots	
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	Template.AbilityMultiTargetConditions.AddItem(default.LivingTargetOnlyProperty);
	Template.AbilityMultiTargetConditions.AddItem(new class'X2Condition_FineControl');

	///////////////////damages and ability add ons///////////////////////////
	// basic weapon damage 

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bExplosiveDamage = true;
	Template.AddMultiTargetEffect(WeaponDamageEffect);

	//swap for spread type based on template name
	if (TemplateName == 'RDThrowerOverwatchShot_Fire')
	{
		Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_flamethrower";

		FireToWorldEffect = new class'X2Effect_ApplyFireToWorld';
		FireToWorldEffect.bUseFireChanceLevel = true;
		FireToWorldEffect.bDamageFragileOnly = true;
		FireToWorldEffect.FireChance_Level1 = default.XENOLATOR_FIRECHANCE_LVL1;
		FireToWorldEffect.FireChance_Level2 = default.XENOLATOR_FIRECHANCE_LVL2;
		FireToWorldEffect.FireChance_Level3 = default.XENOLATOR_FIRECHANCE_LVL3;
		FireToWorldEffect.bCheckForLOSFromTargetLocation = false; //The flamethrower does its own LOS filtering
		Template.AddMultiTargetEffect(FireToWorldEffect);
	}

	if (TemplateName == 'RDThrowerOverwatchShot_Acid')
	{
		Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_andromedon_acidblob";

		AcidToWorldEffect = new class'X2Effect_ApplyAcidToWorld_Cone';
		Template.AddMultiTargetEffect(AcidToWorldEffect);
	}

	if (TemplateName == 'RDThrowerOverwatchShot_Poison')
	{
		Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_viper_poisonspit";

		PoisonToWorldEffect = new class'X2Effect_ApplyPoisonToWorld';
		Template.AddMultiTargetEffect(PoisonToWorldEffect);
	}
	
	//tie in Mitzruti's chemthrower abilities and effects	
	MedikitHeal = new class'X2Effect_ApplyMedikitHeal';
	MedikitHeal.PerUseHP = 1;
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('Phoenix');
	MedikitHeal.TargetConditions.AddItem(AbilityCondition);
	Template.AddShooterEffect(MedikitHeal);

	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();
	DisorientedEffect.iNumTurns = 2;
	DisorientedEffect.DamageTypes.AddItem('Mental');
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('FlamePanic');
	DisorientedEffect.TargetConditions.AddItem(AbilityCondition);
	Template.AddMultiTargetEffect(DisorientedEffect);

	Template.bAllowBonusWeaponEffects = true;

	//Template.PostActivationEvents.AddItem('ChemthrowerActivated'); //Original overwatch shot doesn't include

	///////////////////damages and ability add ons///////////////////////////

	//visualization and stuff
	Template.ActionFireClass = class'X2Action_Fire_Flamethrower';

	Template.ActivationSpeech = 'Flamethrower';
	Template.CinescriptCameraType = "Soldier_HeavyWeapons";
	//Template.CinescriptCameraType = "Iridar_Flamethrower";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	//Template.BuildVisualizationFn = OverwatchShot_BuildVisualization;
	Template.bFrameEvenWhenUnitIsHidden = true;

    // Interactions with the Chosen and Shadow
    Template.SuperConcealmentLoss = 100;
    Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;

	return Template;
}

//create the firestorm shots
static function X2AbilityTemplate CreateRDChemstormShot(name TemplateName)
{
    local X2AbilityTemplate                 Template;
    local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityCost_Ammo				AmmoCost;
	local X2AbilityCooldown					Cooldown;

    local X2AbilityTarget_Cursor            CursorTarget;
    local X2AbilityMultiTarget_Radius       RadiusMultiTarget;
    local X2AbilityToHitCalc_StandardAim    StandardAim;
    local X2Condition_UnitProperty          UnitPropertyCondition;

	local X2Effect_ApplyWeaponDamage		WeaponDamageEffect;
	local X2Effect_ApplyAcidToWorld_Cone			AcidToWorldEffect;
	local X2Effect_ApplyPoisonToWorld		PoisonToWorldEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	//setup
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_AbilityUnavailable');
    Template.IconImage = "img:///UILibrary_MZImmolator.LW_AbilityFirestorm";
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.Hostility = eHostility_Offensive;
	
	//costs
    ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = 1;
    ActionPointCost.bConsumeAllPoints = true;
    Template.AbilityCosts.AddItem(ActionPointCost);

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = default.Chemstorm_Ammocost;
	Template.AbilityCosts.AddItem(AmmoCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.Chemstorm_Cooldown;
	Template.AbilityCooldown = Cooldown;

	//target and triggering
    Template.AbilityTriggers.AddItem( new class'X2AbilityTrigger_PlayerInput');

    StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bMultiTargetOnly = true;
	Template.AbilityToHitCalc = StandardAim;
    
    Template.TargetingMethod = class'X2TargetingMethod_Grenade';

    CursorTarget = new class'X2AbilityTarget_Cursor';
    CursorTarget.bRestrictToWeaponRange = false;
    CursorTarget.FixedAbilityRange = 1;
    Template.AbilityTargetStyle = CursorTarget;
    Template.ShotHUDPriority = 370;

    RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
    RadiusMultiTarget.fTargetRadius = default.CHEMSTORM_RADIUS_METERS;
    RadiusMultiTarget.bIgnoreBlockingCover = true;
    RadiusMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	RadiusMultiTarget.AddAbilityBonusRadius('MZLengthNozzleBsc', 2);
	RadiusMultiTarget.AddAbilityBonusRadius('MZLengthNozzleBsc', 3);
	RadiusMultiTarget.AddAbilityBonusRadius('MZLengthNozzleBsc', 4);
    Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
    UnitPropertyCondition.ExcludeDead = true;
    Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

	Template.AbilityMultiTargetConditions.AddItem(new class'X2Condition_FineControl');
    Template.AddShooterEffectExclusions();

    Template.bCheckCollision = true;
    Template.bAffectNeighboringTiles = true;
    Template.bFragileDamageOnly = true;

    // Adds Suppression restrictions to the ability, depending on config values
	// HandleSuppressionRestriction(Template);
    
	///////////////////damages and ability add ons///////////////////////////
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bExplosiveDamage = true;
	WeaponDamageEffect.bIgnoreBaseDamage = false;
	WeaponDamageEffect.DamageTag = 'Chemstorm';
	Template.AddMultiTargetEffect(WeaponDamageEffect);
	
	if (TemplateName == 'RDChemstorm_Acid')
	{
		AcidToWorldEffect = new class'X2Effect_ApplyAcidToWorld_Cone';
		Template.AddMultiTargetEffect(AcidToWorldEffect);
	}

	if (TemplateName == 'RDChemstorm_Poison')
	{
		PoisonToWorldEffect = new class'X2Effect_ApplyPoisonToWorld';
		Template.AddMultiTargetEffect(PoisonToWorldEffect);
	}

    Template.PostActivationEvents.AddItem('ChemthrowerActivated');
	///////////////////damages and ability add ons///////////////////////////

	//visualization and stuff
    Template.ActionFireClass = class'X2Action_Fire_Firestorm';

    Template.ActivationSpeech = 'Flamethrower';
    Template.CinescriptCameraType = "Soldier_HeavyWeapons";
	//Template.CinescriptCameraType = "Iridar_Flamethrower";

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

    // Interactions with the Chosen and Shadow
    Template.SuperConcealmentLoss = 100;
    Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;

    return Template;
}

/////////////////////////////
//	Xenolator Bonus Abilities
/////////////////////////////

//create the directed blast
static function X2AbilityTemplate Create_XENOLATOR_Directed()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCooldown_LocalAndGlobal	Cooldown;
	local X2AbilityCost_Ammo				AmmoCost;

	local X2Effect_ApplyWeaponDamage		WeaponDamageEffect_All;// WeaponDamageEffect;
	local X2Effect_ApplyFireToWorld			FireToWorldEffect;

	local X2AbilityTarget_Cursor			CursorTarget;
	local X2AbilityMultiTarget_Cone			ConeMultiTarget;
	local X2AbilityToHitCalc_StandardAim	StandardAim;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'XENOLATOR_Directed');

	//setup
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_WrongSoldierClass');
	Template.IconImage = "img:///UILibrary_RustyXenolator.UIPerk_directed";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY + 3;
	Template.Hostility = eHostility_Offensive;

	//costs action points
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.XENOLATOR_DIRECTED_ACTIONPOINTCOST;
	ActionPointCost.bConsumeAllPoints = default.XENOLATOR_DIRECTED_ACTIONPOINTCOST_TURNENDING;
	ActionPointCost.bFreeCost = default.XENOLATOR_DIRECTED_ACTIONPOINTCOST_FREE;
	ActionPointCost.DoNotConsumeAllEffects.AddItem('MZBurningRush');
	Template.AbilityCosts.AddItem(ActionPointCost);

	//costs cooldown
	Cooldown = new class'X2AbilityCooldown_LocalAndGlobal';
	Cooldown.iNumTurns = default.XENOLATOR_DIRECTED_COOLDOWN;
	Cooldown.NumGlobalTurns = 0;
	Template.AbilityCooldown = Cooldown;

	//costs ammo
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = default.XENOLATOR_DIRECTED_AMMO;
	AmmoCost.bConsumeAllAmmo = default.XENOLATOR_DIRECTED_AMMO_CONSUMEALL;
	Template.AbilityCosts.AddItem(AmmoCost);

	//targeting
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bAllowCrit = true;
	Template.AbilityToHitCalc = StandardAim;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;
	
	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeEndDiameter = default.XENOLATOR_DIRECTED_TILE_WIDTH * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = default.XENOLATOR_DIRECTED_TILE_LENGTH * class'XComWorldData'.const.WORLD_StepSize;
		//add support for Mitzruti's attachment upgrades
	ConeMultiTarget.AddBonusConeSize('MZWidthNozzleBsc', 2, 0);
    ConeMultiTarget.AddBonusConeSize('MZWidthNozzleAdv', 3, 0);
    ConeMultiTarget.AddBonusConeSize('MZWidthNozzleSup', 4, 0);
    ConeMultiTarget.AddBonusConeSize('MZLengthNozzleBsc', 0, 1);
    ConeMultiTarget.AddBonusConeSize('MZLengthNozzleAdv', 0, 2);
    ConeMultiTarget.AddBonusConeSize('MZLengthNozzleSup', 0, 3);

	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Shooter conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();
	Template.AbilityMultiTargetConditions.AddItem(default.LivingTargetOnlyProperty);
	Template.AbilityMultiTargetConditions.AddItem(new class'X2Condition_FineControl');

	// Damage ... to any units in the blast line
	WeaponDamageEffect_All = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect_All.bExplosiveDamage = true;
	WeaponDamageEffect_All.EffectDamageValue = default.XENOLATOR_DIRECTED_DMG;
	WeaponDamageEffect_All.bIgnoreBaseDamage = true;
	WeaponDamageEffect_All.bApplyOnMiss = default.XENOLATOR_DIRECTED_CANNOTMISS;
	Template.AddMultiTargetEffect(WeaponDamageEffect_All);

	// Damage ... to environment
	FireToWorldEffect = new class'X2Effect_ApplyFireToWorld';
	FireToWorldEffect.bUseFireChanceLevel = true;
	FireToWorldEffect.bDamageFragileOnly = true;
	FireToWorldEffect.FireChance_Level1 = default.XENOLATOR_FIRECHANCE_LVL1;
	FireToWorldEffect.FireChance_Level2 = default.XENOLATOR_FIRECHANCE_LVL2;
	FireToWorldEffect.FireChance_Level3 = default.XENOLATOR_FIRECHANCE_LVL3;
	FireToWorldEffect.bCheckForLOSFromTargetLocation = false; //The flamethrower does its own LOS filtering
	Template.AddMultiTargetEffect(FireToWorldEffect);

	Template.bCheckCollision = true;
	Template.bAffectNeighboringTiles = true;
	Template.bFragileDamageOnly = true;

	//allow burning from base weapon
	Template.bAllowBonusWeaponEffects = true;

	//visualizations and stuff
	Template.ActionFireClass = class'X2Action_Fire_Flamethrower';

	Template.ActivationSpeech = 'Flamethrower';
	Template.CinescriptCameraType = "Soldier_HeavyWeapons";
	//Template.CinescriptCameraType = "Iridar_Flamethrower";

	Template.bShowActivation = true;

	Template.PostActivationEvents.AddItem('ChemthrowerActivated');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bFrameEvenWhenUnitIsHidden = true;

	Template.SuperConcealmentLoss = 100;
    Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;

	Template.DamagePreviewFn = XENOLATOR_Directed_DamagePreview;

	return Template;
}

//function for UI preview of directed blast
function bool XENOLATOR_Directed_DamagePreview(XComGameState_Ability AbilityState, StateObjectReference TargetRef, out WeaponDamageValue MinDamagePreview, out WeaponDamageValue MaxDamagePreview, out int AllowsShield)
{
	AbilityState.GetMyTemplate().AbilityMultiTargetEffects[0].GetDamagePreview(TargetRef, AbilityState, false, MinDamagePreview, MaxDamagePreview, AllowsShield);
	return true;
}

//create wide burst/flame area
static function X2AbilityTemplate Create_XENOLATOR_FlameArea()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCooldown_LocalAndGlobal	Cooldown;
	local X2AbilityCost_Ammo				AmmoCost;

	local X2Effect_ApplyWeaponDamage		WeaponDamageEffect_All; // WeaponDamageEffect;
	local X2Effect_ApplyFireToWorld			FireToWorldEffect;

	local X2AbilityTarget_Cursor			CursorTarget;
	local X2AbilityMultiTarget_Cone			ConeMultiTarget;
	local X2AbilityToHitCalc_StandardAim	StandardAim;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'XENOLATOR_FlameArea');

	//setup
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_WrongSoldierClass');
	Template.IconImage = "img:///UILibrary_RustyXenolator.UIPerk_widearea";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY + 2;
	Template.Hostility = eHostility_Offensive;

	//costs action points
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.XENOLATOR_FIREWALL_ACTIONPOINTCOST;
	ActionPointCost.bConsumeAllPoints = default.XENOLATOR_FIREWALL_ACTIONPOINTCOST_TURNENDING;
	ActionPointCost.bFreeCost = default.XENOLATOR_FIREWALL_ACTIONPOINTCOST_FREE;
	ActionPointCost.DoNotConsumeAllEffects.AddItem('MZBurningRush');
	Template.AbilityCosts.AddItem(ActionPointCost);

	//costs cooldown
	Cooldown = new class'X2AbilityCooldown_LocalAndGlobal';
	Cooldown.iNumTurns = default.XENOLATOR_FIREWALL_COOLDOWN;
	Cooldown.NumGlobalTurns = 0;
	Template.AbilityCooldown = Cooldown;

	//costs ammo
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = default.XENOLATOR_FIREWALL_AMMO;
	AmmoCost.bConsumeAllAmmo = default.XENOLATOR_FIREWALL_AMMO_CONSUMEALL;
	Template.AbilityCosts.AddItem(AmmoCost);

	//targeting
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bAllowCrit = true;
	Template.AbilityToHitCalc = StandardAim;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = false;
	Template.AbilityTargetStyle = CursorTarget;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeEndDiameter = default.XENOLATOR_FIREWALL_TILE_WIDTH * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = default.XENOLATOR_FIREWALL_TILE_LENGTH * class'XComWorldData'.const.WORLD_StepSize;
		//add support for Mitzruti's attachment upgrades
	ConeMultiTarget.AddBonusConeSize('MZWidthNozzleBsc', 2, 0);
    ConeMultiTarget.AddBonusConeSize('MZWidthNozzleAdv', 3, 0);
    ConeMultiTarget.AddBonusConeSize('MZWidthNozzleSup', 4, 0);
    ConeMultiTarget.AddBonusConeSize('MZLengthNozzleBsc', 0, 1);
    ConeMultiTarget.AddBonusConeSize('MZLengthNozzleAdv', 0, 2);
    ConeMultiTarget.AddBonusConeSize('MZLengthNozzleSup', 0, 3);

	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Shooter conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();
	Template.AbilityMultiTargetConditions.AddItem(default.LivingTargetOnlyProperty);
	Template.AbilityMultiTargetConditions.AddItem(new class'X2Condition_FineControl');
	
	// Damage ... to anyone caught in the area
	WeaponDamageEffect_All = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect_All.bExplosiveDamage = true;
	WeaponDamageEffect_All.EffectDamageValue = default.XENOLATOR_FIREWALL_DMG;
	WeaponDamageEffect_All.bIgnoreBaseDamage = true;
	WeaponDamageEffect_All.bApplyOnMiss = default.XENOLATOR_FIREWALL_CANNOTMISS;
	Template.AddMultiTargetEffect(WeaponDamageEffect_All);

	// Damage ... to environment
	FireToWorldEffect = new class'X2Effect_ApplyFireToWorld';
	FireToWorldEffect.bUseFireChanceLevel = true;
	FireToWorldEffect.bDamageFragileOnly = true;
	FireToWorldEffect.FireChance_Level1 = default.XENOLATOR_FIRECHANCE_LVL1;
	FireToWorldEffect.FireChance_Level2 = default.XENOLATOR_FIRECHANCE_LVL2;
	FireToWorldEffect.FireChance_Level3 = default.XENOLATOR_FIRECHANCE_LVL3;
	FireToWorldEffect.bCheckForLOSFromTargetLocation = false; //The flamethrower does its own LOS filtering
	Template.AddMultiTargetEffect(FireToWorldEffect);

	Template.bCheckCollision = true;
	Template.bAffectNeighboringTiles = true;
	Template.bFragileDamageOnly = true;

	//allow burning from base weapon
	Template.bAllowBonusWeaponEffects = true;

	//visualization and stuff
	//Template.ActionFireClass = class'X2Action_Fire_Flamethrower_Purifier';
	Template.ActionFireClass = class'X2Action_Fire_Flamethrower';

	Template.ActivationSpeech = 'Flamethrower';
	//Template.CinescriptCameraType = "Soldier_HeavyWeapons";
	Template.CinescriptCameraType = "Iridar_Flamethrower";
	
	Template.bShowActivation = true;

	Template.PostActivationEvents.AddItem('ChemthrowerActivated');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bFrameEvenWhenUnitIsHidden = true;

	Template.SuperConcealmentLoss = 100;
    Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	
	Template.DamagePreviewFn = XENOLATOR_FlameArea_DamagePreview;

	return Template;
}

//function for UI preview of wide blast
function bool XENOLATOR_FlameArea_DamagePreview(XComGameState_Ability AbilityState, StateObjectReference TargetRef, out WeaponDamageValue MinDamagePreview, out WeaponDamageValue MaxDamagePreview, out int AllowsShield)
{
	AbilityState.GetMyTemplate().AbilityMultiTargetEffects[0].GetDamagePreview(TargetRef, AbilityState, false, MinDamagePreview, MaxDamagePreview, AllowsShield);
	return true;
}

//create melee attack
static function X2AbilityTemplate Create_XENOLATOR_ArcCutter()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCooldown                 Cooldown;

	local X2Condition_UnitProperty			ShooterPropertyCondition, TargetPropertyCondition, RobotProperty;

	local X2AbilityToHitCalc_StandardMelee  StandardMelee;
	local X2AbilityTarget_MovingMelee       MeleeTarget;

	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect, RobotDamage;
	local X2Effect_Stunned					StunnedEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'XENOLATOR_ArcCutter');

	//setup
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	//Template.IconImage = "img:///UILibrary_RustyXenolator.UIPerk_arccutter";
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_rend";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY + 1;
	Template.Hostility = eHostility_Offensive;
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";

	//costs action points
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	//costs cooldown	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.XENOLATOR_ARCCUTTER_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	//targeting - never misses, like rend
	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	StandardMelee.bGuaranteedHit = default.XENOLATOR_ARCCUTTER_CANNOTMISS;
	Template.AbilityToHitCalc = StandardMelee;

	MeleeTarget = new class'X2AbilityTarget_MovingMelee';
	Template.AbilityTargetStyle = MeleeTarget;

	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_PlayerInput');
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	// Target Conditions
	TargetPropertyCondition = new class'X2Condition_UnitProperty';	
	TargetPropertyCondition.ExcludeDead = true;                     //Can't target dead
	TargetPropertyCondition.ExcludeFriendlyToSource = true;         //Can't target friendlies
	Template.AbilityTargetConditions.AddItem(TargetPropertyCondition);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	// Shooter Conditions
	ShooterPropertyCondition = new class'X2Condition_UnitProperty';	
	ShooterPropertyCondition.ExcludeDead = true;                    //Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(ShooterPropertyCondition);
	Template.AddShooterEffectExclusions();

	// Damage ... to Organic Units
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.EffectDamageValue = default.XENOLATOR_ARCCUTTER_DMG;
	WeaponDamageEffect.bIgnoreBaseDamage = True;
	WeaponDamageEffect.DamageTypes.AddItem('Melee');
	Template.AddTargetEffect(WeaponDamageEffect);

	// Damage ... to Robotics
	RobotDamage = new class'X2Effect_ApplyWeaponDamage';
	RobotDamage.EffectDamageValue = default.XENOLATOR_ARCCUTTER_ROBOT_DMG;
	RobotDamage.DamageTypes.AddItem('Electrical');
	RobotDamage.bIgnoreBaseDamage = True;
		RobotProperty = new class'X2Condition_UnitProperty';
		RobotProperty.ExcludeOrganic = true;
		RobotProperty.IncludeWeakAgainstTechLikeRobot = true;
		RobotDamage.TargetConditions.AddItem(RobotProperty);
	Template.AddTargetEffect(RobotDamage);

	StunnedEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 45, false);
	StunnedEffect.SetDisplayInfo(ePerkBuff_Penalty, class'X2StatusEffects'.default.RoboticStunnedFriendlyName, class'X2StatusEffects'.default.RoboticStunnedFriendlyDesc, "img:///UILibrary_PerkIcons.UIPerk_stun");
		RobotProperty = new class'X2Condition_UnitProperty';
		RobotProperty.ExcludeOrganic = true;
		RobotProperty.IncludeWeakAgainstTechLikeRobot = true;
	StunnedEffect.TargetConditions.AddItem(RobotProperty);
	Template.AddTargetEffect(StunnedEffect);

	//allow burning from base weapon
	Template.bAllowBonusWeaponEffects = true;

	//visualization and stuffs
	Template.bSkipMoveStop = true;
	Template.CustomFireAnim = 'FF_MeleeA';

	Template.PostActivationEvents.AddItem('ChemthrowerActivated');

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	//Template.CinescriptCameraType = "Ranger_Reaper";

	Template.SuperConcealmentLoss = 100;
    Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.MeleeLostSpawnIncreasePerUse;
    Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;

	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}
