/**
 * @presideService true
 * @singleton      true
 */
component accessors=true {

	this.CLASSIFICATION_SKIP_QUEUE = 0;
	this.CLASSIFICATION_PRIORITY   = 1;
	this.CLASSIFICATION_STANDARD   = 2;

	property name="maxActiveRequests" type="numeric" inject="coldbox:setting:smartThrottler.maxActiveRequests";
	property name="queueSize"         type="numeric" inject="coldbox:setting:smartThrottler.queueSize";
	property name="queueTimeout"      type="numeric" inject="coldbox:setting:smartThrottler.queueTimeout";
	property name="failureStatusCode" type="numeric" inject="coldbox:setting:smartThrottler.failureStatusCode";
	property name="sleepInterval"     type="numeric" inject="coldbox:setting:smartThrottler.sleepInterval";
	property name="skipPaths"         type="array"   inject="coldbox:setting:smartThrottler.skipPaths";
	property name="priorityPaths"     type="array"   inject="coldbox:setting:smartThrottler.priorityPaths";
	property name="prioritiseUsers"   type="boolean" inject="coldbox:setting:smartThrottler.prioritiseUsers";
	property name="prioritiseAdmins"  type="boolean" inject="coldbox:setting:smartThrottler.prioritiseAdmins";

	property name="router" inject="delayedInjector:router@coldbox";

// CONSTRUCTOR
	public any function init() {
		variables._priorityQueue = [];
		variables._standardQueue = [];

		return this;
	}

// PUBLIC API METHODS
	public void function enterQueue() {
		if ( getActiveRequestCount() < getMaxActiveRequests() || $getRequestContext().isBackgroundThread() ) {
			return;
		}
		var r = {
			  started  = GetTickCount()
			, timeout  = GetTickCount()+( getQueueTimeout()*1000 )
			, class    = classifyRequest()
			, released = false
			, failed   = false
		};
		if ( r.class == this.CLASSIFICATION_SKIP_QUEUE ) {
			return;
		}

		insertRequestInQueue( r );

		do {
			sleep( getSleepInterval() );
			if ( !r.released ) {
				r.failed = r.timeout < GetTickCount();
			}
		} while( !r.released && !r.failed );

		$getRequestContext().setHTTPHeader( name="X-Preside-Queued-For", value=GetTickCount()-r.started );

		if ( r.failed ) {
			fail();
		}
	}

	public void function processQueue() {
		var queues = [ variables._priorityQueue, variables._standardQueue ];
		lock name="smartThrottlerQueueProcessor" type="exclusive" timeout=5 {
			for( var q in queues ) {
				for( var i=ArrayLen( q ); i>0; i-- ) {
					var r = q[ i ] ?: "";
					if ( IsBoolean( r.failed ?: "" ) && r.failed ) {
						ArrayDeleteAt( q, i );
					}
				}
			}

			if ( getActiveRequestCount() >= getMaxActiveRequests() ) {
				return;
			}

			do {
				for( var q in queues ) {
					if ( ArrayLen( q ) ) {
						var r = q[ 1 ] ?: "";
						if ( IsStruct( r ) ) {
							r.released = true;
							ArrayDeleteAt( q, 1 );
							break;
						}
					}
				}

			} while( getTotalQueuedSize() && getActiveRequestCount() < getMaxActiveRequests() );
		}
	}

	public void function insertRequestInQueue( r ) {
		var isPriority = arguments.r.class == this.CLASSIFICATION_PRIORITY;

		lock name="smartThrottlerQueueProcessor" type="exclusive" timeout=5 {
			if ( getTotalQueuedSize() < getQueueSize() ) {
				ArrayAppend( isPriority ? variables._priorityQueue : variables._standardQueue, arguments.r );
			} else if ( isPriority && ArrayLen( _standardQueue ) ) {
				ArrayAppend( variables._priorityQueue, arguments.r );
				failLatestStandardQueue();
			} else {
				fail();
			}
		}
	}

	public void function fail() {
		content reset=true type="text/plain";
		header statuscode=getFailureStatusCode();
		abort;
	}

	public void function failLatestStandardQueue() {
		var queueSize = ArrayLen( variables._standardQueue );
		var r = variables._standardQueue[ queueSize ] ?: "";
		if ( IsStruct( r ) ) {
			r.released = true;
			r.failed = true;

			ArrayDeleteAt( variables._standardQueue, queueSize );
		}
	}

	public numeric function classifyRequest() {
		var requestPath = request[ "preside.path_info" ] ?: router.pathInfoProvider( event=$getRequestContext() );

		for( var skipPath in getSkipPaths() ) {
			if ( Left( requestPath, Len( skipPath ) ) == skipPath ) {
				return this.CLASSIFICATION_SKIP_QUEUE;
			}
		}

		for( var priorityPath in getPriorityPaths() ) {
			if ( Left( requestPath, Len( priorityPath ) ) == priorityPath ) {
				return this.CLASSIFICATION_PRIORITY;
			}
		}

		if ( getPrioritiseUsers() && $isWebsiteUserLoggedIn() || getPrioritiseAdmins() && $isAdminUserLoggedIn() ) {
			return this.CLASSIFICATION_PRIORITY;
		}

		return this.CLASSIFICATION_STANDARD;
	}

	public numeric function getActiveRequestCount() {
		return getLuceeRequestCount() - getTotalQueuedSize();
	}

	public numeric function getLuceeRequestCount() {
		return getPageContext().getCFMLFactory().getActiveRequests();
	}

	public numeric function getTotalQueuedSize() {
		return ArrayLen( variables._priorityQueue ) + ArrayLen( variables._standardQueue );
	}

	public struct function getStats() {
		return {
			  priorityQueueSize = ArrayLen( variables._priorityQueue )
			, standardQueueSize = ArrayLen( variables._standardQueue )
			, maxActiveRequests = getMaxActiveRequests()
			, maxQueueSize      = getQueueSize()
		};
	}

}