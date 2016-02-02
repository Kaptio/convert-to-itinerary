/*
Name:  OnLeads.trigger
Copyright © 2016 Kaptio
======================================================
======================================================
Purpose:
-------
Single Trigger pattern - all actions are delegated to the handler class.
Enforces the single trigger per action optimisations.
Multiple triggers defined for an action share the same context - and therefore execution limits.
======================================================
======================================================
History
-------
Ver. Author        Date        Detail
1.0  Ragnar    	2016-02-12  Initial Development.
*/
trigger OnLeads on Lead (after insert, after update)
{

	if ( Trigger.isInsert && Trigger.isAfter)
	{
		LeadsService.autoConverter(trigger.new);
		LeadsService.postConversionUpdate(trigger.new);
	}

	if ( Trigger.isUpdate && Trigger.isAfter)
	{
		LeadsService.postConversionUpdate(trigger.new);
	}

}