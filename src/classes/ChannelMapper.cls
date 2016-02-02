/**
* @author Ragnar
* @date 02/02/2016
* @description Used to help assign brand and channel to customers and itineraries.
*/

public with sharing class ChannelMapper
{

	public KaptioTravel__Channel__c defaultChannel { get; private set; }
	public Map<String, KaptioTravel__Channel__c> channelByCode { get; private set; }

	public ChannelMapper()
	{

		this.defaultChannel = new KaptioTravel__Channel__c();
		this.channelByCode = new Map<String, KaptioTravel__Channel__c>();
		init();
	}


	// returns a Channel instance by channel code. If code doesn't exist we return default channel
	public KaptioTravel__Channel__c getInstance(String channelCode)
	{

		KaptioTravel__Channel__c output = defaultChannel;
		if(channelByCode.containsKey(channelCode)){
			output = channelByCode.get(channelCode);
		}
		return output;

	}


	//--------------------------------------------------------------
	// Helper methods
	//--------------------------------------------------------------

	// Popuplates the defaultChannel and channelByCode map. If defaultChannel does't exist, we insert it.
	private void init()
	{

		List<KaptioTravel__Channel__c> allChannels = [select Id, CurrencyIsoCode, KaptioTravel__DefaultDeposit__c, KaptioTravel__ChannelCode__c, KaptioTravel__Brand__c from KaptioTravel__Channel__c];
		for(KaptioTravel__Channel__c c : allChannels)
		{
			channelByCode.put(c.KaptioTravel__ChannelCode__c, c);
		}

		if(channelByCode.containsKey('generic'))
		{
			defaultChannel = channelByCode.get('generic');

		} else
		{
			KaptioTravel__Brand__c defaultBrand = new KaptioTravel__Brand__c(
				Name = 'KT-DEFAULT',
				KaptioTravel__SupplierInvoicePrefix__c = 'DEF',
				KaptioTravel__BookingPrefix__c = 'DF',
				KaptioTravel__CreditInvoicePrefix__c = 'DEC',
				KaptioTravel__CreditInvoiceSequence__c = 10000,
				KaptioTravel__BookingNumberSequence__c = 10000,
				KaptioTravel__SalesInvoicePrefix__c = 'DES',
				KaptioTravel__SalesInvoiceSequence__c = 10000
			);
			insert defaultBrand;

			defaultChannel = new KaptioTravel__Channel__c(
				Name = 'DEFAULT', KaptioTravel__ChannelCode__c = 'default', KaptioTravel__Brand__c = defaultBrand.Id);
			insert defaultChannel;
			channelByCode.put(defaultChannel.Id, defaultChannel);
		}
	}

}