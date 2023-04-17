component {

	public void function configure( required struct config ) {
		var conf     = arguments.config;
		var settings = conf.settings ?: {};

		_setupFeatures( settings );
		_setupExtensionSettings( settings );
		_setupInterceptors( conf );
	}

	private void function _setupFeatures( settings ) {
		settings.features.smartThrottler = { enabled=true }; // will be enabled afterConfigurationLoad() if maxActiveRequests is non-zero
	}

	private void function _setupExtensionSettings( settings ) {
		var env = settings.env ?: {};

		settings.smartThrottler = settings.smartThrottler ?: {};

		settings.smartThrottler.maxActiveRequests = settings.smartThrottler.maxActiveRequests ?: ( env.SMARTTHROTTLER_MAX_ACTIVE_REQUESTS ?: 0   );
		settings.smartThrottler.queueSize         = settings.smartThrottler.queueSize         ?: ( env.SMARTTHROTTLER_QUEUE_SIZE          ?: 0   );
		settings.smartThrottler.queueTimeout      = settings.smartThrottler.queueTimeout      ?: ( env.SMARTTHROTTLER_QUEUE_TIMEOUT       ?: 50  );
		settings.smartThrottler.failureStatusCode = settings.smartThrottler.failureStatusCode ?: ( env.SMARTTHROTTLER_FAILURE_STATUS_CODE ?: 503 );
		settings.smartThrottler.sleepInterval     = settings.smartThrottler.sleepInterval     ?: ( env.SMARTTHROTTLER_SLEEP_INTERVAL      ?: 50  );
		settings.smartThrottler.skipPaths         = settings.smartThrottler.skipPaths         ?: ( env.SMARTTHROTTLER_SKIP_PATHS          ?: ""  );
		settings.smartThrottler.skipAgents        = settings.smartThrottler.skipAgents        ?: ( env.SMARTTHROTTLER_SKIP_AGENTS         ?: ""  );
		settings.smartThrottler.priorityPaths     = settings.smartThrottler.priorityPaths     ?: ( env.SMARTTHROTTLER_PRIORITY_PATHS      ?: ""  );
		settings.smartThrottler.priorityAgents    = settings.smartThrottler.priorityAgents    ?: ( env.SMARTTHROTTLER_PRIORITY_AGENTS     ?: ""  );
		settings.smartThrottler.failPaths         = settings.smartThrottler.failPaths         ?: ( env.SMARTTHROTTLER_FAIL_PATHS          ?: ""  );
		settings.smartThrottler.failAgents        = settings.smartThrottler.failAgents        ?: ( env.SMARTTHROTTLER_FAIL_AGENTS         ?: ""  );
		settings.smartThrottler.prioritiseUsers   = settings.smartThrottler.prioritiseUsers   ?: ( env.SMARTTHROTTLER_PRIORITISE_USERS    ?: true );
		settings.smartThrottler.prioritiseAdmins  = settings.smartThrottler.prioritiseAdmins  ?: ( env.SMARTTHROTTLER_PRIORITISE_ADMINS   ?: false );
		settings.smartThrottler.failStatelessReqs = settings.smartThrottler.failStatelessReqs ?: ( env.SMARTTHROTTLER_FAIL_STATELESS_REQS ?: false );

		if ( IsSimpleValue( settings.smartThrottler.skipPaths ) ) {
			settings.smartThrottler.skipPaths = ListToArray( settings.smartThrottler.skipPaths );
		}
		if ( IsSimpleValue( settings.smartThrottler.skipAgents ) ) {
			settings.smartThrottler.skipAgents = ListToArray( settings.smartThrottler.skipAgents );
		}
		if ( IsSimpleValue( settings.smartThrottler.priorityPaths ) ) {
			settings.smartThrottler.priorityPaths = ListToArray( settings.smartThrottler.priorityPaths );
		}
		if ( IsSimpleValue( settings.smartThrottler.priorityAgents ) ) {
			settings.smartThrottler.priorityAgents = ListToArray( settings.smartThrottler.priorityAgents );
		}
		if ( IsSimpleValue( settings.smartThrottler.failPaths ) ) {
			settings.smartThrottler.failPaths = ListToArray( settings.smartThrottler.failPaths );
		}
		if ( IsSimpleValue( settings.smartThrottler.failAgents ) ) {
			settings.smartThrottler.failAgents = ListToArray( settings.smartThrottler.failAgents );
		}

		settings.smartThrottler.prioritiseUsers   = !IsBoolean( settings.smartThrottler.prioritiseUsers  ) || settings.smartThrottler.prioritiseUsers;
		settings.smartThrottler.prioritiseAdmins  = IsBoolean( settings.smartThrottler.prioritiseAdmins  ) && settings.smartThrottler.prioritiseAdmins;
		settings.smartThrottler.failStatelessReqs = IsBoolean( settings.smartThrottler.failStatelessReqs ) && settings.smartThrottler.failStatelessReqs;
	}

	private void function _setupInterceptors( conf ) {
		conf.interceptors = conf.interceptors ?: [];

		ArrayAppend( conf.interceptors, { class="app.extensions.preside-ext-smart-throttler.interceptors.SmartThrottlerInterceptors", properties={} } );
	}
}
