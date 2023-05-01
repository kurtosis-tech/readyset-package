# NOTE: If you're a VSCode user, you might like our VSCode extension: https://marketplace.visualstudio.com/items?itemName=Kurtosis.kurtosis-extension

default = import_module("github.com/kurtosis-tech/readyset-package/default.star")

UPSTREAM_DB_URL = "upstream_db_url"
STANDALONE = "standalone"
QUERY_CACHING = "query_caching"
DATABASE_TYPE = "database_type"
DEPLOYMENT = "deployment"
LISTEN_PORT = "listen_port"
SERVICE_NAME = "service_name"

READYSET_PORT_NAME = "ready_set_port"
def run(plan, args):
    # Parsing arguments
    upstream_url = args.get(UPSTREAM_DB_URL, "")
    if upstream_url == "":
        return "Required parameter `UPSTREAM_DB_URL` is missing"
    
    standalone = args.get(STANDALONE, default.STANDALONE)
    query_caching = args.get(QUERY_CACHING, default.QUERY_CACHING)
    database_type = args.get(DATABASE_TYPE, default.DATABASE_TYPE)
    deployment = args.get(DEPLOYMENT, default.DEPLOYMENT)
    service_name = args.get(SERVICE_NAME, default.SERVICE_NAME)
    listen_port = args.get(LISTEN_PORT, default.LISTEN_PORT)

    # Create Service Config object for ReadySet
    ready_set_service_config = ServiceConfig(
        image=default.DEFAULT_IMAGE_NAME,
        ports={
            READYSET_PORT_NAME: PortSpec(
                number=listen_port, 
                application_protocol=default.APPLICATION_PROTOCOL,
            )
        },
        env_vars={
            "STANDALONE": standalone,
            "LISTEN_ADDRESS": "0.0.0.0:" + str(listen_port),
            "QUERY_CACHING": query_caching,
            "DATABASE_TYPE": database_type,
            "UPSTREAM_DB_URL": upstream_url,
            "DEPLOYMENT": deployment,
        }
    )
    
    readyset = plan.add_service(
        name=service_name, 
        config=ready_set_service_config
    )

    token1 = upstream_url.find("@")
    token2 = upstream_url.rfind("/")
    
    port_string = ":" + str(readyset.ports[READYSET_PORT_NAME].number)
    readyset_url = upstream_url[:token1+1] + readyset.ip_address + port_string + upstream_url[token2:]
    return readyset_url
