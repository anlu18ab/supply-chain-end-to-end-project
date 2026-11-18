from pyspark.sql import SparkSession, functions as F


def ingest_table(spark: SparkSession, catalog: str, source: str,
                 entity: str, fmt: str, batch_id: str) -> None:
    table = f"{catalog}.bronze.{source}_{entity}"
    src = f"/Volumes/{catalog}/landing/raw/{source}/{entity}/"
    state = f"/Volumes/{catalog}/landing/_state/{source}_{entity}"

    reader = (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", fmt)
        .option("cloudFiles.schemaLocation", f"{state}/schema")
        .option("cloudFiles.schemaEvolutionMode", "addNewColumns")
    )
    if fmt == "csv":
        # No type inference: every column is a string. Types are applied in silver.
        # multiLine/escape handle Olist review comments that contain line breaks and quotes.
        reader = (reader.option("header", "true")
                        .option("multiLine", "true")
                        .option("escape", '"'))
    else:
        reader = reader.option("cloudFiles.inferColumnTypes", "true")

    df = (
        reader.load(src)
        .select(
            "*",
            F.col("_metadata.file_path").alias("_source_file"),
            F.col("_metadata.file_modification_time").alias("_source_modified_at"),
            F.current_timestamp().alias("_ingested_at"),
            F.lit(batch_id).alias("_batch_id"),
        )
    )

    (df.writeStream
        .option("checkpointLocation", f"{state}/checkpoint")
        .option("mergeSchema", "true")
        .trigger(availableNow=True)
        .toTable(table)
        .awaitTermination())