// Declare this as a global variable so it can be used in all pipeline methods. 
credentialsArray = []

def init() {
    // Determine if a credentials ID has been provided, or if the default should be used.
    def vcdConnectionCredentialsID = params.VCD_CONNECTION_CREDENTIALS_ID
    if (vcdConnectionCredentialsID.toLowerCase() == 'default') {
        vcdConnectionCredentialsID = env.DEFAULT_VCD_CONNECTION_CREDENTIALS_ID
    }

    if (vcdConnectionCredentialsID.toLowerCase() != "") {
        // Ensure the path to a VCD parameters file is loaded into the appropriate
        // environment variable for testing scripts to use.
        credentialsArray << [
            $class: 'FileBinding', 
            credentialsId: vcdConnectionCredentialsID,
            variable: 'VCD_CONNECTION'
        ]
    }
}

def install() {
    // Set up Python virtual environment and install pyvcloud. 
    sh "support/install.sh"
}

def runToxFlake8() {
    // Run tox. 
    sh "support/tox.sh"
}

def runSamples() {
    withCredentials(credentialsArray) {
        // Execute samples. 
        sh "examples/run_examples.sh"
    }
}

def runSystemTests() {
    withCredentials(credentialsArray) {
        // Run the default system test list. 
        sh "system_tests/run_system_tests.sh"
    }
}

def cleanupSystemTests() {
    withCredentials(credentialsArray) {
        // Cleanup all system tests.  
        sh "system_tests/run_system_tests.sh cleanup_test.py"
    }
}

// Call the init method to ensure the environment and credentials are ready. 
init()

// Return a reference to this file to allow the pipeline to call methods. 
return this