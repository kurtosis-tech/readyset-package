DEFAULT_IMAGE_NAME = "public.ecr.aws/readyset/readyset:beta-2023-02-15"
DEFAULT_READYSET_PORT_NUMBER = 5433
APPLICATION_PROTOCOL = "postgresql"

# default required enviornment variables 
SERVICE_NAME = "readyset"
STANDALONE = "1"
LISTEN_ADDRESS = "0.0.0.0:" + str(DEFAULT_READYSET_PORT_NUMBER)
QUERY_CACHING = "explicit"
DATABASE_TYPE = "postgresql"
DEPLOYMENT = "kurtosis-readyset-deployment"