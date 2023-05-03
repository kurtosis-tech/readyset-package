Readyset Package
============
This is a [Kurtosis package](https://docs.kurtosis.com/concepts-reference/packages). It allows you to run [`readyset`](https://readyset.io/) cache which can improve performance for your `SQL` queries.

Run this package
----------------

Assuming that you have either `postgres` or `mysql` database running, replace `UPSTREAM_DB_URL_CONNECTION_STRING` with your connection string. 

**IMPORTANT: Do not use `localhost` or `127.0.0.1`, instead use the IP Address as `hostname` for `upstream_db_url`.**

The schema for creating a connection string is shown below. For more information regarding `upstream_db_url` , refer to the documentation [here](https://docs.readyset.io/reference/cli/readyset/#-upstream-db-url). 

```
[postgresql|mysql]://<user>:<password>@<hostname>[:<port>]/<database>[?<extra_options>]
```

If you have [Kurtosis installed][install-kurtosis], run:

```bash
kurtosis run github.com/kurtosis-tech/readyset-package '{"upstream_db_url": "UPSTREAM_DB_URL_CONNECTION_STRING"}'
```

To blow away the created [enclave][enclaves-reference], run `kurtosis clean -a`.

#### Configuration

<details>
    <summary>Click to see configuration</summary>

You can configure this package using the JSON structure below. The default values for each parameter are shown. 

NOTE: the `//` lines are not valid JSON; you will need to remove them!

```javascript
// See https://docs.readyset.io/reference/cli/readyset/ to learn more about these parameters.
{
    // the underlying database url (required)
    "upstream_db_url": "mysql://root:password@hostname/database", // replace with your database url
    "standalone": "1",
    "query_caching": "explicit",
    "deployment": "kurtosis-readyset-deployment",
    "listen_port": "3307",
    "service_name": "readyset"
}
```

You can store the JSON args in a file, and use command expansion to slot them in:

```bash
kurtosis run github.com/kurtosis-tech/readyset-package "$(cat args.json)"
```

The arguments can then be passed in to `kurtosis run` like:

For example:

<!-- TODO replace YOURUSER and THISREPO with the correct values -->
```bash
kurtosis run github.com/kurtosis-tech/readyset-package '{"upstream_db_url": "mysql://root:password@hostname/database", "service_name": "readyset_mysql"}'
```

</details>

Use this package in your package
--------------------------------
Kurtosis packages can be composed inside other Kurtosis packages. To use this package in your package:

<!-- TODO Replace YOURUSER and THISREPO with the correct values! -->
First, import this package by adding the following to the top of your Starlark file:

```python
this_package = import_module("github.com/kurtosis-tech/readyset-package/main.star")
```

Then, call the this package's `run` function somewhere in your Starlark script:

```python
this_package_output = this_package.run(plan, args)
```

Develop on this package
-----------------------
1. [Install Kurtosis][install-kurtosis]
1. Clone this repo
1. For your dev loop, run `kurtosis clean -a && kurtosis run .` inside the repo directory


<!-------------------------------- LINKS ------------------------------->
[install-kurtosis]: https://docs.kurtosis.com/install
[enclaves-reference]: https://docs.kurtosis.com/concepts-reference/enclaves
