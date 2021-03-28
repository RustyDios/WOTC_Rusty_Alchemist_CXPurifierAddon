//---------------------------------------------------------------------------------------
//  FILE:   X2StratElem_RandomExpChem.uc                                    
//  
//	File created by RustyDios	08/06/20	15:00
//	LAST UPDATED				24/07/20	05:00
//
//	Creates and add the random experimental project for one of the chemthrowers
//	Creates and add the random experimental project for one of the canisters
//
//*******************************************************************************************
class X2StrategyElements_RandomExpChems extends X2StrategyElement_DefaultTechs config(Xenolator);

var config array<name> 	strEX_CHEM_RESOURCE_COST_TYPE, strEX_CAN_RESOURCE_COST_TYPE;
var config array<int> 	iEX_CHEM_RESOURCE_COST_AMOUNT, iEX_CAN_RESOURCE_COST_AMOUNT;
var config int EXPERIMENTAL_CHEMTHROWER_BUILD_TIME_DAYS, EXPERIMENTAL_CANISTER_BUILD_TIME_DAYS;
var config bool bRepeatExpChemTech;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Techs;

	// Proving Grounds Projects
	Techs.AddItem(CreateExperimentalChemthrower());

	if (class'X2DownloadableContentInfo_WOTC_Rusty_Alchemist_CXPurifierAddon'.default.bPGCanisters)
	{
		Techs.AddItem(CreateExperimentalCanisters());
	}

	return Techs;
}

static function X2DataTemplate CreateExperimentalChemthrower()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources;
	local int i;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'ExperimentalChemthrower');

	Template.PointsToComplete = StafferXDays(1, default.EXPERIMENTAL_CHEMTHROWER_BUILD_TIME_DAYS);
	Template.strImage = "img:///UILibrary_RustyXenolator.Tech_ExperimentalChemthrower";
	Template.SortingTier = 3;
	Template.bProvingGround = true;
	Template.bRepeatable = default.bRepeatExpChemTech;
	
	Template.ResearchCompletedFn = GiveDeckedItemReward;
	Template.RewardDeck = 'ExperimentalChemthrowerRewards';

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('HeavyPlasma');

	// Costs array provided by Iridar
	for (i = 0; i < default.strEX_CHEM_RESOURCE_COST_TYPE.Length; i++)
	{
		if (default.iEX_CHEM_RESOURCE_COST_AMOUNT[i] > 0)
		{
			Resources.ItemTemplateName = default.strEX_CHEM_RESOURCE_COST_TYPE[i];
			Resources.Quantity = default.iEX_CHEM_RESOURCE_COST_AMOUNT[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}
	
	return Template;
}

static function X2DataTemplate CreateExperimentalCanisters()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources;
	local int i;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'ExperimentalCanisters');

	Template.PointsToComplete = StafferXDays(1, default.EXPERIMENTAL_CANISTER_BUILD_TIME_DAYS);
	Template.strImage = "img:///UILibrary_RustyXenolator.Tech_ExperimentalCanister";
	Template.SortingTier = 3;
	Template.bProvingGround = true;
	Template.bRepeatable = true;
	
	Template.ResearchCompletedFn = GiveDeckedItemReward;
	Template.RewardDeck = 'ExperimentalCanisterRewards'; //'ExperimentalChemCanister' in MZ's mod.. but he doesn't link it to a project anywhere ? so my mod does ;)

	// Requirements
	//Template.Requirements.RequiredTechs.AddItem('HeavyPlasma');

	// Costs array provided by Iridar
	for (i = 0; i < default.strEX_CAN_RESOURCE_COST_TYPE.Length; i++)
	{
		if (default.iEX_CAN_RESOURCE_COST_AMOUNT[i] > 0)
		{
			Resources.ItemTemplateName = default.strEX_CAN_RESOURCE_COST_TYPE[i];
			Resources.Quantity = default.iEX_CAN_RESOURCE_COST_AMOUNT[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}
	
	return Template;
}
