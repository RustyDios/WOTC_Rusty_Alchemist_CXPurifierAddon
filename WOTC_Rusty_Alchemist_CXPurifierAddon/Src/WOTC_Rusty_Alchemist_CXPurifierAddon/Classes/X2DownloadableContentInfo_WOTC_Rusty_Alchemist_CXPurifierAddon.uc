//*******************************************************************************************
//  FILE:   XComDownloadableContentInfo_WOTC_Rusty_Alchemist_CXPurifierAddon.uc                                    
//  
//	File created by RustyDios	24/11/19	02:45
//	LAST UPDATED				24/07/20	06:30
//
//	X2 DLC Info for my alchemist class, addon to include a new chemthrowers from the CX mods
//		Option to update all chemthrower models to a re-colourable version with flashlights
//
//*******************************************************************************************


class X2DownloadableContentInfo_WOTC_Rusty_Alchemist_CXPurifierAddon extends X2DownloadableContentInfo config (Xenolator);

// var config stuffs
var config bool bAdjustLootTablePurifier, bAdjustLootTableCaptain, bAdjustLootTableBioMecTrooper;;

var config bool bUseUpdatedChemthrowerModels_Immo, bUseUpdatedChemthrowerModels_Cryo;// , bUseUpdatedChemthrowerModels_Xeno;
var config bool bUseTintableChemthrowerModels_Immo, bUseTintableChemthrowerModels_Cryo, bUseTintableChemthrowerModels_Xeno, bUseTintableChemthrowerModels_Bio;
var config bool bPGCanisters;

var config bool bMergeCryolatorToExperimental, bUpdateClausSPARKthrowers;

//adjustments to include sparkthrowers
var config array<name> PatchSparkFlamethrowersAbilities;

/// Called on new campaign while this DLC / Mod is installed
static event InstallNewCampaign(XComGameState StartState){}		//empty_func

/// Called on first time load game if not already installed	
static event OnLoadedSavedGame(){}								//empty_func

/// Called on load to strategy save
static event OnLoadedSavedGameToStrategy()
{
	AddProjectToHistory();
}

//*******************************************************************************************
//		OPTC code 
//*******************************************************************************************

static event OnPostTemplatesCreated()
{
	local X2CharacterTemplateManager	AllCharacters;
	local X2ItemTemplateManager			AllItems;
    
	local X2AbilityTemplate         	Template;
    local X2AbilityTemplateManager  	AbilityTemplateManager;
	local name							AbilityName;

    AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AllItems = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	AllCharacters = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	//if the config is set to adjust normal purifiers
	if (default.bAdjustLootTablePurifier)
	{
		AdjustLootTables(AllCharacters.FindCharacterTemplate('AdvPurifierM1'), 'Rusty_CXAdvPurifierM1_BaseLoot');
		AdjustLootTables(AllCharacters.FindCharacterTemplate('AdvPurifierM2'), 'Rusty_CXAdvPurifierM2_BaseLoot');
		AdjustLootTables(AllCharacters.FindCharacterTemplate('AdvPurifierM3'), 'Rusty_CXAdvPurifierM3_BaseLoot');
	}

	//if the config is set to adjust captain purifiers
	if (default.bAdjustLootTableCaptain)
	{
		AdjustLootTables(AllCharacters.FindCharacterTemplate('AdvPurifierCaptainM1'), 'Rusty_CXAdvPurifierM1_BaseLoot');
		AdjustLootTables(AllCharacters.FindCharacterTemplate('AdvPurifierCaptainM1'), 'Rusty_CXAdvPurifierM2_BaseLoot');
		AdjustLootTables(AllCharacters.FindCharacterTemplate('AdvPurifierCaptainM1'), 'Rusty_CXAdvPurifierM3_BaseLoot');
	}

	//if the config is set to adjust Bio Mec Troopers
	if (default.bAdjustLootTableBioMecTrooper)
	{
		AdjustLootTables(AllCharacters.FindCharacterTemplate('BioMecTrooper'), 'Rusty_CXBioMecTrooper_BaseLoot');
	}

	//==============================================================================
	// Update the chemthrowers templates - Non tintable
	//==============================================================================

	if (default.bUseUpdatedChemthrowerModels_Immo)
	{
		//================	try and find the standard immolators	=================
		UpdateChemthrowerModels(AllItems.FindItemTemplate('MZImmolator_CV'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerNORM_NOTINT", true);
		UpdateChemthrowerModels(AllItems.FindItemTemplate('MZImmolator_MG'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerNORM_NOTINT", true);
		UpdateChemthrowerModels(AllItems.FindItemTemplate('MZImmolator_BM'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerNORM_NOTINT", true);
	}

	if (default.bUseUpdatedChemthrowerModels_Cryo)
	{
		//================	try and find the standard cryolators	=================
		UpdateChemthrowerModels(AllItems.FindItemTemplate('XcomCryolator_CV'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerCRYO_NOTINT", true);
		UpdateChemthrowerModels(AllItems.FindItemTemplate('XcomCryolator_MG'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerCRYO_NOTINT", true);
		UpdateChemthrowerModels(AllItems.FindItemTemplate('XcomCryolator_BM'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerCRYO_NOTINT", true);
	}

	//==============================================================================
	// Update the chemthrowers templates - Tintable
	//==============================================================================

	if (default.bUseTintableChemthrowerModels_Immo)
	{
		//================	try and find the standard immolators	=================
		UpdateChemthrowerModels(AllItems.FindItemTemplate('MZImmolator_CV'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerNORM", true);
		UpdateChemthrowerModels(AllItems.FindItemTemplate('MZImmolator_MG'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerNORM", true);
		UpdateChemthrowerModels(AllItems.FindItemTemplate('MZImmolator_BM'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerNORM", true);
	}

	if (default.bUseTintableChemthrowerModels_Cryo)
	{
		//================	try and find the standard cryolators	=================
		UpdateChemthrowerModels(AllItems.FindItemTemplate('XcomCryolator_CV'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerCRYO", true);
		UpdateChemthrowerModels(AllItems.FindItemTemplate('XcomCryolator_MG'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerCRYO", true);
		UpdateChemthrowerModels(AllItems.FindItemTemplate('XcomCryolator_BM'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerCRYO", true);
	}

	if (default.bUseTintableChemthrowerModels_Xeno)
	{
		//================	try and find this mods xenolators	=================
		UpdateChemthrowerModels(AllItems.FindItemTemplate('Xcom_Xenolator_CV'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerXENO");
		UpdateChemthrowerModels(AllItems.FindItemTemplate('Xcom_Xenolator_MG'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerXENO");
		UpdateChemthrowerModels(AllItems.FindItemTemplate('Xcom_Xenolator_BM'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerXENO");
	}

	if (default.bUseTintableChemthrowerModels_Bio)
	{
		//================	try and find this mods corr/toxilators	=================
		UpdateChemthrowerModels(AllItems.FindItemTemplate('Xcom_Xenolator_AC'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerACID");
		UpdateChemthrowerModels(AllItems.FindItemTemplate('Xcom_Xenolator_PO'), "WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerACID");
	}
	
	//WP_XCOMChemthrowerMKII.Archetypes.WP_ChemthrowerADVT = a red unused base, blood ?

	UpdateCanistersToDeck(AllItems.FindItemTemplate('MZBlastCanister'),		default.bPGCanisters);
	UpdateCanistersToDeck(AllItems.FindItemTemplate('MZFireCanister'),		default.bPGCanisters);
	UpdateCanistersToDeck(AllItems.FindItemTemplate('MZIceCanister'),		default.bPGCanisters);
	UpdateCanistersToDeck(AllItems.FindItemTemplate('MZPoisonCanister'),	default.bPGCanisters);
	UpdateCanistersToDeck(AllItems.FindItemTemplate('MZAcidCanister'),		default.bPGCanisters);
	UpdateCanistersToDeck(AllItems.FindItemTemplate('MZCurseCanister'),		default.bPGCanisters);
	UpdateCanistersToDeck(AllItems.FindItemTemplate('MZSmokeCanister'),		default.bPGCanisters);
	UpdateCanistersToDeck(AllItems.FindItemTemplate('MZMedicCanister'),		default.bPGCanisters);
	UpdateCanistersToDeck(AllItems.FindItemTemplate('MZBluescreenCanister'),default.bPGCanisters);

	UpdateCryolatorToExperimentalDeck();

	//update claus' sparkthrowers ... code provided by Iridar
	if (default.bUpdateClausSPARKthrowers)
	{
		UpdateClausSPARKthrowers(AllItems.FindItemTemplate('SPARK_InfernoCannon'),class'X2Item_XCOM_Xenolator'.default.iXENOLATOR_SkillDamage_CV, class'X2Item_XCOM_Xenolator'.default.iXENOLATOR_CV_SLOTS);
		UpdateClausSPARKthrowers(AllItems.FindItemTemplate('SPARK_FlameStormCannon'),class'X2Item_XCOM_Xenolator'.default.iXENOLATOR_SkillDamage_MG, class'X2Item_XCOM_Xenolator'.default.iXENOLATOR_MG_SLOTS);
		UpdateClausSPARKthrowers(AllItems.FindItemTemplate('SPARK_ApocalypseCannon'),class'X2Item_XCOM_Xenolator'.default.iXENOLATOR_SkillDamage_BM, class'X2Item_XCOM_Xenolator'.default.iXENOLATOR_BM_SLOTS);

		foreach default.PatchSparkFlamethrowersAbilities(AbilityName)
		{
			Template = AbilityTemplateManager.FindAbilityTemplate(AbilityName);
			if (Template != none)
			{
				PatchSparkFlamethrowerAbility(Template);
			}
		}
	}

}
//*******************************************************************************************
//		End OPTC code 
//*******************************************************************************************

//this function swaps the loot tables of the listed enemies to new ones that have the chemthrower drops
static function AdjustLootTables(X2CharacterTemplate CurrentCharacter, name LTN)
{
	local LootReference NewLoot;

	if (CurrentCharacter != none)
	{
		//reset the loot ref
		CurrentCharacter.Loot.LootReferences.Length = 0;

		//add the new table
		NewLoot.ForceLevel = 0;
		NewLoot.LootTableName = LTN;
		CurrentCharacter.Loot.LootReferences.AddItem(NewLoot);
	}
}

//this function adds skill damage by tag to claus weapons
static function UpdateClausSPARKthrowers(X2ItemTemplate CurrentItem, array<WeaponDamageValue> SkillDamage, int NumSlots)
{
	local X2WeaponTemplate				CurrentWeapon;

	CurrentWeapon = X2WeaponTemplate (CurrentItem);
	if (CurrentWeapon != none)
	{	
		CurrentWeapon.ExtraDamage =	SkillDamage;
		CurrentWeapon.NumUpgradeSlots= NumSlots;
	}
}

static private function PatchSparkFlamethrowerAbility(X2AbilityTemplate Template)
{
	//	Yes, this is code from Iridar, magic unicorn code ;)
	if (X2AbilityMultiTarget_Cone(Template.AbilityMultiTargetStyle) != none)
	{
		X2AbilityMultiTarget_Cone(Template.AbilityMultiTargetStyle).AddBonusConeSize('MZWidthNozzleBsc', 2, 0);
		X2AbilityMultiTarget_Cone(Template.AbilityMultiTargetStyle).AddBonusConeSize('MZWidthNozzleAdv', 3, 0);
		X2AbilityMultiTarget_Cone(Template.AbilityMultiTargetStyle).AddBonusConeSize('MZWidthNozzleSup', 4, 0);
		X2AbilityMultiTarget_Cone(Template.AbilityMultiTargetStyle).AddBonusConeSize('MZLengthNozzleBsc', 0, 1);
		X2AbilityMultiTarget_Cone(Template.AbilityMultiTargetStyle).AddBonusConeSize('MZLengthNozzleAdv', 0, 2);
		X2AbilityMultiTarget_Cone(Template.AbilityMultiTargetStyle).AddBonusConeSize('MZLengthNozzleSup', 0, 3);
	}

	//	Adding these because they should be specified explicitly.
	Template.Hostility = eHostility_Offensive;
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealShotMax;

	// Allow critting so that SPARK Flamethrowers can benefit from the weapon upgrade that gives bonus crit.
	if (X2AbilityToHitCalc_StandardAim(Template.AbilityToHitCalc) != none)
	{
		X2AbilityToHitCalc_StandardAim(Template.AbilityToHitCalc).bAllowCrit = true;
	}
}

//this function adds some stuff to 	canisters
static function UpdateCanistersToDeck(X2ItemTemplate CurrentItem, bool bAddToPG = false)
{
	local X2WeaponTemplate				CurrentWeapon;

	CurrentWeapon = X2WeaponTemplate (CurrentItem);
	if (CurrentWeapon != none)
	{	
		if (CurrentWeapon.WeaponPanelImage == "")
		{
			CurrentWeapon.WeaponPanelImage = "_ConventionalCannon";									//weapon panel ui?
		}
		
		if (CurrentWeapon.UIArmoryCameraPointTag == '')
		{
			CurrentWeapon.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Shotgun';			//viewpoint for armory camera, root bone
		}

		if(bAddToPG)
		{
			CurrentWeapon.CanBeBuilt = false;
			CurrentWeapon.RewardDecks.AddItem('ExperimentalCanisterRewards');
		}
	}
}

//this function swaps chemthrower archetypes/models	
static function UpdateChemthrowerModels(X2ItemTemplate CurrentItem, string ArchetypePath, bool bAddLight = false)
{
	local X2WeaponTemplate				CurrentWeapon;

	CurrentWeapon = X2WeaponTemplate (CurrentItem);
	if (CurrentWeapon != none)
	{	
		CurrentWeapon.GameArchetype = ArchetypePath	;												//updates the weapon model
		CurrentWeapon.bIsLargeWeapon = true;														//tells UI camera to back off

		if (CurrentWeapon.WeaponPanelImage == "")
		{
			CurrentWeapon.WeaponPanelImage = "_ConventionalCannon";									//weapon panel ui?
		}

		if (CurrentWeapon.UIArmoryCameraPointTag == '')
		{
			CurrentWeapon.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon';			//viewpoint for armory camera, root bone
		}

		if(bAddLight)
		{
			CurrentWeapon.AddDefaultAttachment('Light', "ConvAttachments.Meshes.SM_ConvFlashLight");	//adds a flashlight
		}
	}
}

//this function puts the cryolator into the experimental deck - after beam cannon research is done, when the deck is available
static function UpdateCryolatorToExperimentalDeck()
{
	local X2ItemTemplateManager				AllItems;
	local X2ItemTemplate					CurrentItem;
	local X2WeaponTemplate					CurrentWeapon;

	local X2StrategyElementTemplateManager	AllStratElems;
	local X2TechTemplate					CurrentTech;

	AllItems		= class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	AllStratElems	= class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	if (default.bMergeCryolatorToExperimental)
	{
		//put just the superior in the deck
		CurrentItem = AllItems.FindItemTemplate('XcomCryolator_BM');
		CurrentWeapon = X2WeaponTemplate (CurrentItem);
		if (CurrentWeapon != none)
		{	
			CurrentWeapon.RewardDecks.AddItem('ExperimentalChemthrowerRewards');
		}

		//hide the other proving grounds projects on beam cannon complete
		//experimental deck has beam cannon required
		CurrentTech = X2TechTemplate(AllStratElems.FindStrategyElementTemplate('MZBuildCryolator'));
		if (CurrentTech != none)
		{
			CurrentTech.UnavailableIfResearched = 'HeavyPlasma';
		}

		CurrentTech = X2TechTemplate(AllStratElems.FindStrategyElementTemplate('MZBuildCryolatorMG'));
		if (CurrentTech != none)
		{
			CurrentTech.UnavailableIfResearched = 'HeavyPlasma';
		}

		CurrentTech = X2TechTemplate(AllStratElems.FindStrategyElementTemplate('MZBuildCryolatorBM'));
		if (CurrentTech != none)
		{
			CurrentTech.UnavailableIfResearched = 'HeavyPlasma';
		}
	}


}

//*******************************************************************************************
//		Add Project Code -- borrowed from Mitzruti's Immolator mod
//*******************************************************************************************

static function bool IsResearchInHistory(name ResearchName)
{
	local XComGameState_Tech TechState;
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Tech', TechState)
	{
		if ( TechState.GetMyTemplateName() == ResearchName )
		{
			return true;
		}
	}
	return false;
}

// Add tech template if not injected
static function AddToHistoryIfMissing(name ResearchName, XComGameState NewGameState) 
{
	local X2StrategyElementTemplateManager StrategyElementTemplateManager;
	local X2TechTemplate TechTemplate;

	if ( !IsResearchInHistory(ResearchName) )
	{
		StrategyElementTemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
		TechTemplate = X2TechTemplate(StrategyElementTemplateManager.FindStrategyElementTemplate(ResearchName));
		NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
	}
}

//Update the projects in the current campaign
static function AddProjectToHistory() 
{
	local XComGameState NewGameState;

	//Create a pending game state change
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Experimental Chemthrowers");

	AddToHistoryIfMissing('ExperimentalChemthrower', NewGameState);

	if(default.bPGCanisters)
	{
		AddToHistoryIfMissing('ExperimentalCanisters', NewGameState);
	}
	
	//Commit the state change into the history.
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

//////////////////////////////////////////////////////////////////////////////////////////
// ADD THE ITEMS TO THE HQ INVENTORY BY CONSOLE COMMAND
//////////////////////////////////////////////////////////////////////////////////////////

exec function RustyFix_ToolBox_Alchemists()
{
	RustyFix_AlchemistsToolBox_AddItem("MZImmolator_CV", 5);
	RustyFix_AlchemistsToolBox_AddItem("MZImmolator_MG", 5);
	RustyFix_AlchemistsToolBox_AddItem("MZImmolator_BM", 5);

	RustyFix_AlchemistsToolBox_AddItem("XcomCryolator_CV", 5);
	RustyFix_AlchemistsToolBox_AddItem("XcomCryolator_MG", 5);
	RustyFix_AlchemistsToolBox_AddItem("XcomCryolator_BM", 5);

	RustyFix_AlchemistsToolBox_AddItem("Xcom_Xenolator_CV", 5);
	RustyFix_AlchemistsToolBox_AddItem("Xcom_Xenolator_MG", 5);
	RustyFix_AlchemistsToolBox_AddItem("Xcom_Xenolator_BM", 5);

	RustyFix_AlchemistsToolBox_AddItem("Xcom_Xenolator_PO", 5);
	RustyFix_AlchemistsToolBox_AddItem("Xcom_Xenolator_AC", 5);

	RustyFix_AlchemistsToolBox_AddItem("MZBlastCanister", 5);
	RustyFix_AlchemistsToolBox_AddItem("MZFireCanister", 5);
	RustyFix_AlchemistsToolBox_AddItem("MZIceCanister", 5);
	RustyFix_AlchemistsToolBox_AddItem("MZPoisonCanister", 5);
	RustyFix_AlchemistsToolBox_AddItem("MZAcidCanister", 5);
	RustyFix_AlchemistsToolBox_AddItem("MZBluescreenCanister", 5);
	RustyFix_AlchemistsToolBox_AddItem("MZCurseCanister", 5);
	RustyFix_AlchemistsToolBox_AddItem("MZSmokeCanister", 5);
	RustyFix_AlchemistsToolBox_AddItem("MZMedicCanister", 5);
}

static function RustyFix_AlchemistsToolBox_AddItem(string strItemTemplate, optional int Quantity = 1, optional bool bLoot = false)
{
	local X2ItemTemplateManager ItemManager;
	local X2ItemTemplate ItemTemplate;
	local XComGameState NewGameState;
	local XComGameState_Item ItemState;
	local XComGameState_HeadquartersXCom HQState;
	local XComGameStateHistory History;
	local bool bWasInfinite;

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = ItemManager.FindItemTemplate(name(strItemTemplate));

	if (ItemTemplate == none)
	{
		`log("No item template named" @ strItemTemplate @ "was found.");
		return;
	}

	if (ItemTemplate.bInfiniteItem)
	{
		bWasInfinite = true;
		ItemTemplate.bInfiniteItem = false;
	}

	History = `XCOMHISTORY;
	HQState = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	`assert(HQState != none);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Add Item Cheat: Create Item");
	ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
	ItemState.Quantity = Quantity;

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Add Item Cheat: Complete");
	HQState = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(HQState.Class, HQState.ObjectID));
	HQState.PutItemInInventory(NewGameState, ItemState, bLoot);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	`log("Added item" @ strItemTemplate @ "object id" @ ItemState.ObjectID);

	if (bWasInfinite)
	{
		ItemTemplate.bInfiniteItem = true;
	}
}
