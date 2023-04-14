component extends="coldbox.system.Interceptor" {

	property name="requestQueueService"     inject="delayedInjector:smartThrottlerRequestQueueService";
	property name="smartThrottlerHeartbeat" inject="delayedInjector:smartThrottlerHeartbeat";

// PUBLIC
	public void function configure() {}

	public void function afterConfigurationLoad() {
		_disableFeatureIfNoMaxRequestsSet();
	}

	public void function onApplicationStart() {
		_setupHeartbeat();
	}

	public void function onRequestCapture() {
		if ( isFeatureEnabled( "smartThrottler" ) ) {
			requestQueueService.enterQueue();
		}
	}

// PRIVATE HELPERS
	private void function _disableFeatureIfNoMaxRequestsSet() {
		var settings = getController().getSettingStructure();

		if ( isBoolean( settings.features.smartThrottler.enabled ?: "" ) && settings.features.smartThrottler.enabled ) {
			settings.features.smartThrottler.enabled = Val( settings.smartThrottler.maxActiveRequests ?: "" ) > 0;
		}
	}

	private void function _setupHeartbeat() {
		if ( isFeatureEnabled( "smartThrottler" ) ) {
			smartThrottlerHeartbeat.start();
		}
	}
}