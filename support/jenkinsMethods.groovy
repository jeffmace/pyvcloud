def buildCredentialsArray() {
    println env
    println params
    println credentialsArray
}

def install() {
    // Set up Python virtual environment and install pyvcloud. 
    sh "support/install.sh"
}

def tox() {
    // Run tox. 
    sh "support/tox.sh"
}

def runSamples(credentialsArray) {
    withCredentials(credentialsArray) {
        // Execute samples. 
        sh "examples/run_examples.sh"
    }
}

def runSystemTests(credentialsArray) {
    withCredentials(credentialsArray) {
        // Run the default system test list. 
        sh "system_tests/run_system_tests.sh"
    }
}

def cleanupSystemTests(credentialsArray) {
    withCredentials(credentialsArray) {
        // Run the default system test list. 
        sh "system_tests/run_system_tests.sh cleanup_test.py"
    }
}

return this