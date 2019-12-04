#!/usr/bin/env bash

agent_version="2.160.1"
agent_archive="vsts-agent-linux-x64-${agent_version}.tar.gz"
agent_url="https://vstsagentpackage.azureedge.net/agent/${agent_version}/${agent_archive}"

function usage {
  echo "$0 <options>"
  echo "  options:"
  echo "    -c | --count <n> number of agents to create (required)"
  echo "    -u | --url <url> Url of the Azure DevOps Org (required) "
  echo "    -x | --prefix <name> agent prefix (optional - default: agent)"
  echo "    -t | --token <token> Azure DevOps PAT Token (required)"
  echo "    -p | --pool <agent_pool_name> Azure DevOps Agent Pool (required)"
}

if [ $# -le 1 ]; then
  usage
  exit 1
fi

declare count number
declare url string
prefix=agent
declare token string
declare pool string

while [ "$1" != "" ]; do
    case $1 in
        -c | --count )          shift
                                count=$1
                                ;;
        -u | --url )            shift
                                url=$1
                                ;;
        -x | --prefix )         shift
                                prefix=$1
                                ;;
        -t | --token )          shift
                                token=$1
                                ;;
        -p | --pool )           shift
                                pool=$1
                                ;;
        -h | --help )           usage
                                exit 0
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

echo "count $count"
echo "url $url"
echo "prefix $prefix"
echo "token $token"
echo "pool $pool"

function create_agent {
  agent_name="$prefix$1"
  echo "creating $agent_name"
  mkdir -p "agents/$agent_name"
  pushd "agents/$agent_name"
    tar zxvf "../${agent_archive}"
    sudo ./bin/installdependencies.sh
    ./config.sh --unattended --url $url --auth pat --token $token --pool $pool --agent $agent_name
    sudo ./svc.sh install
    sudo ./svc.sh start
  popd
}

mkdir agents
pushd agents
  wget $agent_url
popd

for i in {1..5}; do create_agent $i; done
