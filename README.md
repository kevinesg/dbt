# dbt

## Introduction
This git repository contains all dbt-core files post-installation and some dbt models. dbt is responsible for the transformation step of the ELT pipelines. The current (work in progress) lineage graph is shown below. The data catalog can be accessed at [dbt.kevinesg.com/data-catalog.html](https://dbt.kevinesg.com/data-catalog.html) (updated every hour).

![dbt lineage graph](https://i.imgur.com/dRfcUVQ.png)

##
## Table of Contents
1. [Release Notes](#release-notes)
2. [Pre-installation Notes](#pre-installation-notes)
3. [Installation](#installation)
4. [Folder Structure](#folder-structure)

##
## Release Notes
* 2024-09-10    created initial setup of dbt repo and installation
* 2024-09-15    added `_is_deleted` logic in finance models
* 2024-09-15    deployed data catalog to [dbt.kevinesg.com/data-catalog.html](https://dbt.kevinesg.com/data-catalog.html)

##
## Pre-installation Notes
* Only `dbt-core` is used here (no `dbt cloud`).

##
## Installation
1. Open your Linux terminal and `cd` to the directory where you want to install dbt. In my case, I created `github/` under the home directory, such that `pwd` command shows `/home/kevinesg/github`. Then I `git clone` this git repository, which then creates `/home/kevinesg/github/dbt`. I `cd` into it.
    * Enter `sudo apt update && sudo apt upgrade` if you are using a freshly-created Linux distro to make sure everything is updated (you might have to restart).
    * Don't forget to activate your virtual environment.
2. Enter `pip install dbt-core dbt-bigquery`. Replace `dbt-bigquery` by the proper connector package based on the cloud provider that you use.
3. Enter `dbt --version` to verify if installation went successfully.
4. Enter `dbt init` to initialize a dbt project. Take note that you should be in the directory where you want to save your dbt project. For reference, here are my answers during this step:
    ````
    Enter a name for your project (letters, digits, underscore): data_warehouse
    Which database would you like to use?
    [1] bigquery
    Enter a number: 1
    [1] oauth
    [2] service_account
    Desired authentication method option (enter a number): 2
    keyfile (/path/to/bigquery/keyfile.json): /home/kevinesg/credentials/google-service-account.json
    project (GCP project id): <enter your project id>
    dataset (the name of your dbt dataset): dev_dbt
    threads (1 or more): 4
    job_execution_timeout_seconds [300]: 
    [1] US
    [2] EU
    Desired location option (enter a number): 1
    ````
5. `cd` into your project (in my case it is `cd data_warehouse`) then run `dbt debug`. Check the logs if everything says "OK" or "valid". Follow the instructions if an error is encountered.
6. Navigate to `/home/kevinesg/.dbt/` and edit `profiles.yml` either via terminal or VS Code.
    * Add another environment so that you will have a dev/test and prod environments. In my case, I initially have this:
    ````
    data_warehouse:
    outputs:
        dev:
        dataset: dev_dbt
        job_execution_timeout_seconds: 300
        job_retries: 1
        keyfile: /home/kevinesg/credentials/google-service-account.json
        location: US
        method: service-account
        priority: interactive
        project: <project id>
        threads: 4
        type: bigquery
    target: dev
    ````

    * I added a prod environment and the final content is this:
    ````
    data_warehouse:
    outputs:
        dev:
        dataset: dev_dbt
        job_execution_timeout_seconds: 300
        job_retries: 1
        keyfile: /home/kevinesg/credentials/google-service-account.json
        location: US
        method: service-account
        priority: interactive
        project: <project id>
        threads: 4
        type: bigquery
        prod:
        dataset: staging_dbt
        job_execution_timeout_seconds: 300
        job_retries: 1
        keyfile: /home/kevinesg/credentials/google-service-account.json
        location: US
        method: service-account
        priority: interactive
        project: <project id>
        threads: 4
        type: bigquery
    target: dev
    ````
7. As you go along while creating dbt models, whenever you create a new folder inside `models/`, you might want to specify it in `models` inside `dbt_project.yml` as well. For example, if you want to create a finance dataset, it is good practice to create `/finance/` under several folders (if you follow medallion architecture) which will store all finance dbt models. Then `dbt_project.yml` may contain this:
````
models:
  data_warehouse:

    staging_dbt:
      finance:
        +materialized: view
        +schema: "{% if target.name == 'dev' %} dev_dbt {% else %} staging_dbt {% endif %}"
    
    silver:
      finance:
        +materialized: view
        +schema: "{% if target.name == 'dev' %} dev_dbt {% else %} silver {% endif %}"
    
    gold:
      finance:
        +materialized: view
        +schema: "{% if target.name == 'dev' %} dev_dbt {% else %} finance {% endif %}"
    
    utils:
      +materialized: view
      +schema: "{% if target.name == 'dev' %} dev_dbt {% else %} utils {% endif %}"
````
* where `data_warehouse` is your dbt project. You can decide about the default table materialization (view, table, incremental, materialized view, etc.) and schema of the dbt models that will be inside these folders. These are just defaults and you can override them if needed by specifying `config {{ }}` at the top of a dbt model.

    ## Optional but recommended steps: 
#
1. Add a `generate_schema_name` macro (dbt docs reference: [Understanding custom schemas](https://docs.getdbt.com/docs/build/custom-schemas#understanding-custom-schemas)). Inside your project folder, find the `macros` folder and create a `generate_schema_name.sql` file with the following contents:
    ````
    {% macro generate_schema_name(custom_schema_name, node) -%}

        {%- set default_schema = target.schema -%}
        {%- if custom_schema_name is none -%}

            {{ default_schema }}

        {%- else -%}

            {{ custom_schema_name | trim }}

        {%- endif -%}

    {%- endmacro %}
    ````
    * This makes it so that dbt won't create a `dbt_finance` dataset and just use `finance` dataset as expected. The explanation on why dbt adds a prefix in the first place is explained in their documentation linked above.
2. Add "sources" in `model-paths` in `dbt-project.yml` so you can create a `sources/` directory inside your dbt project, which will contain all raw source tables from different sources, which can be grouped into different yml files for clarity (finance raw tables are all inside `finance.yml`, etc.).

##
## Folder Structure
````
.
├── LICENSE
├── README.md
├── data_warehouse                      # main dbt project directory
│   ├── analyses                        # SQL files for ad-hoc analysis
│   ├── dbt_project.yml                 # dbt project configuration file
│   ├── logs                            # logs generated from dbt runs
│   ├── macros                          # custom Jinja macros for dbt
│   ├── models                          # dbt models folder (contains SQL transformations)
│   │   ├── gold                        # gold-tier models (final outputs)
│   │   ├── silver                      # silver-tier models (intermediate transformations)
│   │   ├── staging_dbt                 # staging models (raw data processing)
│   │   └── utils                       # utility models (helper SQL scripts)
│   ├── seeds                           # static CSV data for dbt seed commands
│   ├── snapshots                       # snapshot definitions for historical data tracking
│   ├── sources                         # source tables and external data definitions
│   ├── target                          # files/logs here are generated during dbt runs
│   └── tests                           # dbt tests to validate model logic
└── logs                                # general logs (outside of the dbt project)
````
Some files and folders might be missing because they are included in `.gitignore` for privacy purposes.
##
For more information, feel free to check [dbt-core Installation Documentation](https://docs.getdbt.com/docs/core/installation-overview) or their [Github](https://github.com/dbt-labs/dbt-core). Let me know if you have any questions! You can contact me at kevinlloydesguerra@gmail.com.