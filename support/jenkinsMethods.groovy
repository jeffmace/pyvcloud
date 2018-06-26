credentialsArray = []
environmentArray = []

def init() {
    println "${env.WORKSPACE}"
    println env.getEnvironment()

    def vcdConnectionCredentialsID = params.VCD_CONNECTION_CREDENTIALS_ID
    if (vcdConnectionCredentialsID.toLowerCase() == 'default') {
        vcdConnectionCredentialsID = env.DEFAULT_VCD_CONNECTION_CREDENTIALS_ID
    }

    if (vcdConnectionCredentialsID.toLowerCase() != "") {
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
        // Run the default system test list. 
        sh "system_tests/run_system_tests.sh cleanup_test.py"
    }
}

return this