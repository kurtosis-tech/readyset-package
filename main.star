# NOTE: If you're a VSCode user, you might like our VSCode extension: https://marketplace.visualstudio.com/items?itemName=Kurtosis.kurtosis-extension

default = import_module("github.com/kurtosis-tech/readyset-package/default.star")
 
UPSTREAM_DB_URL_KEY = "upstream_db_url"
STANDALONE_KEY = "standalone"
QUERY_CACHING_KEY = "query_caching"
DEPLOYMENT_KEY = "deployment"
LISTEN_PORT_KEY = "listen_port"
SERVICE_NAME_KEY = "service_name"

READYSET_PORT_NAME_KEY = "ready_set_port"

ERROR_MESSAGE = "`upstream_db_url` is not configured properly. The `upstream_db_url` should match the pattern `[postgresql|mysql]://<user>:<password>@<hostname>[:<port>]/<database[?<extra_options>]`"

def run(plan, args):
    # Parsing arguments
    upstream_url = args.get(UPSTREAM_DB_URL_KEY, None)
    if upstream_url == None:
        fail("Required parameter `UPSTREAM_DB_URL` is missing: It should like: `[postgresql|mysql]://<user>:<password>@<hostname>[:<port>]/<database[?<extra_options>]`")

    conn_token1 = upstream_url.find("@")
    conn_token2 = upstream_url.rfind("/")
    conn_token3 = upstream_url.find(":")

    if conn_token1 < 0 or conn_token2 < 0 or conn_token2 < conn_token1 or conn_token3 < 0:
        fail(ERROR_MESSAGE)
    
    application_protocol = upstream_url[:conn_token3]
    if application_protocol != "postgresql" and application_protocol != "mysql":
        fail(ERROR_MESSAGE)

    listen_port = args.get(LISTEN_PORT_KEY, None):

    if listen_port == None:
        if application_protocol == "postgresql":
            listen_port = default.POSTGRES_DEFAULT_LISTEN_PORT
        else:
            listen_port = default.MYSQL_DEFAULT_LISTEN_PORT

    standalone = args.get(STANDALONE_KEY, default.STANDALONE)
    deployment = args.get(DEPLOYMENT_KEY, default.DEPLOYMENT)
    service_name = args.get(SERVICE_NAME_KEY, default.SERVICE_NAME)
    query_caching = args.get(QUERY_CACHING_KEY, default.QUERY_CACHING)

    # Create Service Config object for ReadySet
    ready_set_service_config = ServiceConfig(
        image=default.DEFAULT_IMAGE_NAME,
        ports={
            READYSET_PORT_NAME_KEY: PortSpec(
                number=listen_port, 
                application_protocol=application_protocol,
            )
        },
        env_vars={
            "STANDALONE": standalone,
            "LISTEN_ADDRESS": "0.0.0.0:" + str(listen_port),
            "QUERY_CACHING": query_caching,
            "DATABASE_TYPE": application_protocol,
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
