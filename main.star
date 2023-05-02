# NOTE: If you're a VSCode user, you might like our VSCode extension: https://marketplace.visualstudio.com/items?itemName=Kurtosis.kurtosis-extension

default = import_module("github.com/kurtosis-tech/readyset-package/default.star")
postgres = import_module("github.com/kurtosis-tech/postgres-package/main.star")

UPSTREAM_DB_URL_KEY = "upstream_db_url"
STANDALONE_KEY = "standalone"
QUERY_CACHING_KEY = "query_caching"
DATABASE_TYPE_KEY = "database_type"
DEPLOYMENT_KEY = "deployment"
LISTEN_PORT_KEY = "listen_port"
SERVICE_NAME_KEY = "service_name"

READYSET_PORT_NAME_KEY = "ready_set_port"

def run(plan, args):
    # Parsing arguments

    upstream_url = args.get(UPSTREAM_DB_URL_KEY, None)
    if upstream_url == None:
        fail("Required parameter `UPSTREAM_DB_URL` is missing")

    conn_token1 = upstream_url.find("@")
    conn_token2 = upstream_url.rfind("/")

    if conn_token1 < 0 or conn_token2 < 0 or conn_token2 < conn_token1:
        fail("Misconfigured `upstream_url` - The `upstream_url` should look like `postgresql://<user>:<password>@<hostname>:<port>/<database?[?<extra_options>]`")
    
    standalone = args.get(STANDALONE_KEY, default.STANDALONE)
    query_caching = args.get(QUERY_CACHING_KEY, default.QUERY_CACHING)
    database_type = args.get(DATABASE_TYPE_KEY, default.DATABASE_TYPE)
    deployment = args.get(DEPLOYMENT_KEY, default.DEPLOYMENT)
    service_name = args.get(SERVICE_NAME_KEY, default.SERVICE_NAME)
    listen_port = args.get(LISTEN_PORT_KEY, default.LISTEN_PORT)

    # Create Service Config object for ReadySet
    ready_set_service_config = ServiceConfig(
        image=default.DEFAULT_IMAGE_NAME,
        ports={
            READYSET_PORT_NAME_KEY: PortSpec(
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
 
    port_string = ":" + str(readyset.ports[READYSET_PORT_NAME_KEY].number)
    readyset_url = upstream_url[:conn_token1+1] + readyset.ip_address + port_string + upstream_url[conn_token2:]
     
    return struct(
        service=readyset,
        url=readyset_url
    )
