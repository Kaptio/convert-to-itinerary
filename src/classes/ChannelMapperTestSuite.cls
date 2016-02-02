/**
* @author Ragnar
* @date 2015/09/15
* @description Test class for ChannelMapperTestSuite
*/

@isTest
private with sharing class ChannelMapperTestSuite {

	@isTest
	private static void testChannelMapper1() {

		ChannelMapper mapper = new ChannelMapper();

		System.assertEquals('GENERIC', mapper.defaultChannel.Name,
			'mapper class automatically creates the GENERIC channel');

		System.assertEquals(1, mapper.channelByCode.size(),
			'Should have at least GENERIC channel');

		ChannelMapper mapper2 = new ChannelMapper();

		System.assertEquals(1, mapper2.channelByCode.size(),
			'mapper 2 should only return the GENERIC channel as well');
	}


}