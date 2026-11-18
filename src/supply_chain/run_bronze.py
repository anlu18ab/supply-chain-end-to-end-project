import sys
import uuid
from pathlib import Path

import yaml
from pyspark.sql import SparkSession

CONFIG_NAME = "bronze_sources.yml"


def _config_from_argv() -> Path | None:
    if len(sys.argv) > 1 and sys.argv[1].endswith((".yml", ".yaml")):
        return Path(sys.argv[1])
    return None


def _bundle_root() -> Path:
    """Bundle root (the folder that contains config/ and src/), without using __file__."""
    cfg = _config_from_argv()
    if cfg is not None:
        return cfg.parents[1]  # <root>/config/<file>.yml -> <root>

    # Fallback: search upward from the working directory
    # (on Databricks this is the script's folder, .../src/supply_chain)
    cwd = Path.cwd()
    for d in [cwd, *cwd.parents]:
        if (d / "config" / CONFIG_NAME).exists():
            return d
    raise FileNotFoundError(
        f"Could not locate bundle root from argv={sys.argv[1:]} or cwd={cwd}"
    )


ROOT = _bundle_root()
SRC_DIR = ROOT / "src"
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from supply_chain.bronze import ingest_table  # noqa: E402


def main() -> None:
    config_path = _config_from_argv() or (ROOT / "config" / CONFIG_NAME)
    if not config_path.exists():
        raise FileNotFoundError(f"Config not found: {config_path}")
    print(f"Using config: {config_path}")
    cfg = yaml.safe_load(config_path.read_text())

    spark = SparkSession.builder.getOrCreate()
    batch_id = str(uuid.uuid4())
    print(f"Batch id: {batch_id}")

    for t in cfg["tables"]:
        print(f"Ingesting {t['source']}.{t['entity']} ...")
        ingest_table(
            spark, cfg["catalog"], t["source"], t["entity"], t["format"], batch_id
        )


main()