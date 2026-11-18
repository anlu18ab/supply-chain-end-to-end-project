from databricks.connect import DatabricksSession

CATALOG = "supply_chain_dev"
spark = DatabricksSession.builder.serverless().getOrCreate()

statements = [
    f"CREATE CATALOG IF NOT EXISTS {CATALOG}",
    f"CREATE SCHEMA IF NOT EXISTS {CATALOG}.landing",
    f"CREATE SCHEMA IF NOT EXISTS {CATALOG}.bronze",
    f"CREATE SCHEMA IF NOT EXISTS {CATALOG}.silver",
    f"CREATE SCHEMA IF NOT EXISTS {CATALOG}.gold",
    f"CREATE VOLUME IF NOT EXISTS {CATALOG}.landing.raw",     # raw files
    f"CREATE VOLUME IF NOT EXISTS {CATALOG}.landing._state",  # checkpoints
]
for s in statements:
    spark.sql(s)