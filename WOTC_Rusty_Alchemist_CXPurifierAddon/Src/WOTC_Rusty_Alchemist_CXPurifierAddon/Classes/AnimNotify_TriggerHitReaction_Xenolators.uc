//---------------------------------------------------------------------------------------
//  FILE:   AnimNotify_TriggerHitReaction_Xenolator.uc                                    
//  
//	File created by RustyDios	31/03/20	18:00
//	LAST UPDATED				31/03/20	18:00
//
//	literally a carbon copy of the one from CX's Purifiers ALL credit to them
//		okay I adjusted the LOG lines... woooaahhh
//
//*******************************************************************************************
class AnimNotify_TriggerHitReaction_Xenolators extends AnimNotify_Scripted config (Xenolator);

var() editinline name ReactionAnimSequence <ToolTip="Sequence name of the damage reaction to play">;
var() editinline bool RandomReactionAnimSequence <ToolTip="Play a random sequence of HL_HurtFront, HL_HurtLeft or HL_HurtRight Overides ReactionAnimSequence">;
var() editinline int BloodAmount <ToolTip="Virtual damage amount that calculates the amount of blood effect">;
var() name DamageTypeName  <ToolTip="Virtual damage type used in hit effect. Possible values are DefaultProjectile, Acid, Electrical, Poison, Psi and Fire">;
var() EAbilityHitResult HitResult <ToolTip="Virtual hit result used in the hit effect container">;

var config bool bEnableTriggerHitLogging;

event Notify(Actor Owner, AnimNodeSequence AnimSeqInstigator)
{
	local XComUnitPawn Pawn, TargetPawn;
	local XGUnitNativeBase OwnerUnit;
	local X2Action_Fire FireAction;
	local XComGameStateVisualizationMgr VisualizationManager;
	local CustomAnimParams AnimParams;
	local XGUnit TargetUnit;
	local array<name> RandomSequences;

	RandomSequences.AddItem('HL_HurtFront');
	RandomSequences.AddItem('HL_HurtLeft');
	RandomSequences.AddItem('HL_HurtRight');

	Pawn = XComUnitPawn(Owner);
	if (Pawn != none)
	{
		OwnerUnit = Pawn.GetGameUnit();
		if (OwnerUnit != none)
		{
			`LOG("AnimNotify_TriggerHitReaction Owner" @ String(OwnerUnit),default.bEnableTriggerHitLogging, 'WOTC_Xenolators');
			VisualizationManager = `XCOMVISUALIZATIONMGR;
			FireAction = X2Action_Fire(VisualizationManager.GetCurrentActionForVisualizer(OwnerUnit));
			if (FireAction != none)
			{
				TargetUnit = XGUnit(FireAction.PrimaryTarget);
				TargetPawn = TargetUnit.GetPawn();
				`LOG("AnimNotify_TriggerHitReaction Target" @ TargetUnit @ TargetPawn @ FireAction,default.bEnableTriggerHitLogging, 'WOTC_Xenolators');
				if (TargetPawn != none)
				{
					
					if (RandomReactionAnimSequence)
					{
						AnimParams.AnimName = RandomSequences[`SYNC_RAND_STATIC(3)];
					}
					else
					{
						AnimParams.AnimName = ReactionAnimSequence;
					}

					//DamageTypeName = class'X2Item_DefaultDamageTypes'.default.DefaultDamageType;
					TargetPawn.GetAnimTreeController().PlayFullBodyDynamicAnim(AnimParams);
					TargetPawn.PlayHitEffects(
						BloodAmount,
						OwnerUnit,
						TargetPawn.GetHeadshotLocation(),
						DamageTypeName,
						Normal(TargetPawn.GetHeadshotLocation()) * 500.0f,
						false,
						HitResult
					);

					`LOG("AnimNotify_TriggerHitReaction triggered" @ AnimParams.AnimName @ DamageTypeName @ HitResult @ BloodAmount,default.bEnableTriggerHitLogging, 'WOTC_Xenolators');
					
				}
			}
		}
	}
	super.Notify(Owner, AnimSeqInstigator);
}

defaultproperties 
{
	ReactionAnimSequence = "HL_HurtFront"
	DamageTypeName = "DefaultProjectile"
	RandomReactionAnimSequence = true
	BloodAmount = 1
	HitResult = eHit_Success
}