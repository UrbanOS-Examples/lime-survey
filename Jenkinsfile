library(
    identifier: 'pipeline-lib@4.3.2',
    retriever: modernSCM([$class: 'GitSCMSource',
                          remote: 'https://github.com/SmartColumbusOS/pipeline-lib',
                          credentialsId: 'jenkins-github-user'])
)

properties([
    pipelineTriggers([scos.dailyBuildTrigger()]),
])

def image
def doStageIf = scos.&doStageIf
def doStageIfRelease = doStageIf.curry(scos.changeset.isRelease)
def doStageUnlessRelease = doStageIf.curry(!scos.changeset.isRelease)
def doStageIfPromoted = doStageIf.curry(scos.changeset.isMaster)

node ('infrastructure') {
    ansiColor('xterm') {
        scos.doCheckoutStage()

        doStageUnlessRelease('Build') {
            image = docker.build("scos/lime-survey:${env.GIT_COMMIT_HASH}")
        }

        doStageUnlessRelease('Deploy to Dev') {
            scos.withDockerRegistry {
                image.push()
                image.push('latest')
            }
            deployLimeTo(environment: 'dev')
        }

        doStageIfPromoted('Deploy to Staging')  {
            def promotionTag = scos.releaseCandidateNumber()

            deployLimeTo(environment: 'staging')

            scos.applyAndPushGitHubTag(promotionTag)

            scos.withDockerRegistry {
                image.push(promotionTag)
            }
        }

        doStageIfRelease('Deploy to Production') {
            def releaseTag = env.BRANCH_NAME
            def promotionTag = 'prod'

            deployLimeTo(environment: 'prod', internal: false)

            scos.applyAndPushGitHubTag(promotionTag)

            scos.withDockerRegistry {
                image = scos.pullImageFromDockerRegistry("scos/lime-survey", env.GIT_COMMIT_HASH)
                image.push(releaseTag)
                image.push(promotionTag)
            }
        }
    }
}

def deployLimeTo(params = [:]) {
    def environment = params.get('environment')
    if (environment == null) throw new IllegalArgumentException("environment must be specified")

    def internal = params.get('internal', true)

    scos.withEksCredentials(environment) {

        def terraformOutputs = scos.terraformOutput(environment)
        sh "terraform init && terraform workspace new ${environment}"
            terraform.plan(terraform.defaultVarFile)
            terraform.apply()
            retry(20) {
                sleep(time: 30, unit: 'SECONDS')
                sh ("""#!/bin/bash
                    set -ex
                    ./smoketest.sh https://nifi.${environment}.internal.smartcolumbusos.com/nifi/
                    ./smoketest.sh https://kylo.${environment}.internal.smartcolumbusos.com/login.html
                """.trim())
            }



        def subnets = terraformOutputs.public_subnets.value.join(/\\,/)
        def allowInboundTrafficSG = terraformOutputs.allow_all_security_group.value
        def certificateARN = scos.terraformOutput(environment, internal ? 'operating-system' : 'prod').tls_certificate_arn.value
        def dns_zone = environment + '.internal.smartcolumbusos.com'
        def ingressScheme = internal ? 'internal' : 'internet-facing'
/* THIS PROBLEM PROBABLY GOES AWAY WHEN THIS IS TERRA-FIED
        def dbHost = terraformOutputs.lime_db_address.value
        def dbUser = terraformOutputs.<THIS SHOULD BE SET AS AN OUTPUT FOR EASE OF RETRIEVAL>
        def dbPassword = <HOW TO GET?>
        def dbName = terraformOutputs.<THIS SHOULD BE SET AS AN OUTPUT FOR EASE OF RETRIEVAL>
        def adminPassword = <HOW TO GET?>
*/
        sh("""#!/bin/bash
            set -e
            helm init --client-only
            helm upgrade --install lime-survey ./lime-survey \
                --namespace=lime-survey \
                --set ingress.annotations."alb\\.ingress\\.kubernetes\\.io\\/scheme"="${ingressScheme}" \
                --set ingress.annotations."alb\\.ingress\\.kubernetes\\.io\\/subnets"="${subnets}" \
                --set ingress.annotations."alb\\.ingress\\.kubernetes\\.io\\/security\\-groups"="${allowInboundTrafficSG}" \
                --set ingress.annotations."alb\\.ingress\\.kubernetes\\.io\\/certificate-arn"="${certificateARN}" \
                --set ingress.hosts[0]="survey\\.${dns_zone}" \
                --set db.host="${dbHost}" \
                --set db.user="${dbUser}" \
                --set db.password="${dbPassword}" \
                --set db.db_name="${dbName}" \
                --set lime.adminPassword="${adminPassword}" \
                --set image.tag="${env.GIT_COMMIT_HASH}"
        """.trim())
    }
}
