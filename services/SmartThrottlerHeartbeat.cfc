/**
 * @presideService true
 * @singleton      true
 */
component extends="preside.system.services.concurrency.AbstractHeartBeat" {

	/**
	 * @requestQueueService.inject         smartThrottlerRequestQueueService
	 * @scheduledThreadpoolExecutor.inject presideScheduledThreadpoolExecutor
	 * @hostname.inject                    coldbox:setting:heartbeats.taskmanager.hostname
	 *
	 */
	public function init(
		  required any    requestQueueService
		, required any    scheduledThreadpoolExecutor
		, required string hostname
	){
		super.init(
			  threadName                  = "Preside Heartbeat: Smart Throttler queue manager"
			, intervalInMs                = 20
			, feature                     = "smartThrottler"
			, scheduledThreadpoolExecutor = arguments.scheduledThreadpoolExecutor
			, hostname                    = arguments.hostname
		);

		_setRequestQueueService( arguments.requestQueueService );

		return this;
	}

	// PUBLIC API METHODS
	public void function $run() {
		try {
			_getRequestQueueService().processQueue();
		} catch( any e ) {
			$raiseError( e );
		}
	}


// GETTERS AND SETTERS
	private any function _getRequestQueueService() {
	    return _requestQueueService;
	}
	private void function _setRequestQueueService( required any requestQueueService ) {
	    _requestQueueService = arguments.requestQueueService;
	}

}