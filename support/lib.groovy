// Declare this as a global variable so it can be used in all pipeline methods. 
credentialsArray = []
environmentArray = []

def init() {
    // Determine if a credentials ID has been provided, or if the default should be used.
    def vcdConnectionCredentialsID = params.VCD_CONNECTION_CREDENTIALS_ID
    if (vcdConnectionCredentialsID.toLowerCase() == 'default') {
        vcdConnectionCredentialsID = env.DEFAULT_VCD_CONNECTION_CREDENTIALS_ID
    }

    // Check for a parameter containing the VCD_CONNECTION content
    // Write that to a file if available, or use a Jenkins credential file
    if (env.VCD_CONNECTION_CONTENTS != "") {
        def tmpdir = pwd(tmp:true)
        writeFile(file: "${tmpdir}/jenkins_vcd_connection", text: env.VCD_CONNECTION_CONTENTS)
        environmentArray << "VCD_CONNECTION=${tmpdir}/jenkins_vcd_connection"
    } else if (vcdConnectionCredentialsID.toLowerCase() != "") {
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
    withEnv(environmentArray) {
        sh "support/install.sh"
    }
}

def runToxFlake8() {
    // Run tox. 
    withEnv(environmentArray) {
        sh "support/tox.sh"
    }
}

def runSamples() {
    withCredentials(credentialsArray) {
        // Execute samples. 
        withEnv(environmentArray) {
            sh "examples/run_examples.sh"
        }
    }
}

def runSystemTests() {
    withCredentials(credentialsArray) {
        // Run the default system test list. 
        withEnv(environmentArray) {
            sh "system_tests/run_system_tests.sh"
        }
    }
}

def cleanupSystemTests() {
    withCredentials(credentialsArray) {
        // Cleanup all system tests.  
        withEnv(environmentArray) {
            sh "system_tests/run_system_tests.sh cleanup_test.py"
        }
    }
}

// Call the init method to ensure the environment and credentials are ready. 
init()

// Return a reference to this file to allow the pipeline to call methods. 
return this