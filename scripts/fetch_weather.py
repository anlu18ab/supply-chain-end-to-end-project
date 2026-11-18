import io, json, time
from datetime import date, datetime, timezone
import requests
from databricks.sdk import WorkspaceClient

CATALOG = "supply_chain_dev"
# State-level approximate coordinates (M5 does not disclose store locations)
STATES = {"CA": (36.78, -119.42), "TX": (31.00, -100.00), "WI": (44.50, -89.50)}
START, END = "2011-01-29", "2016-06-19"   # M5 calendar range
URL = "https://archive-api.open-meteo.com/v1/archive"

w = WorkspaceClient()
today = date.today().isoformat()

for state, (lat, lon) in STATES.items():
    params = {
        "latitude": lat, "longitude": lon,
        "start_date": START, "end_date": END,
        "daily": "temperature_2m_max,temperature_2m_min,precipitation_sum",
        "timezone": "America/Los_Angeles",
    }
    for attempt in range(3):                       # simple retry with backoff
        r = requests.get(URL, params=params, timeout=60)
        if r.status_code == 200:
            break
        time.sleep(2 ** attempt)
    r.raise_for_status()

    payload = r.json()
    payload["_state"] = state                      # keep context inside the file
    payload["_extracted_at"] = datetime.now(timezone.utc).isoformat()

    path = (f"/Volumes/{CATALOG}/landing/raw/open_meteo/daily/"
            f"ingest_date={today}/state={state}_{START}_{END}.json")
    w.files.upload(path, io.BytesIO(json.dumps(payload).encode()), overwrite=True)
    print("landed", path)
    time.sleep(1)                                  # be polite to the API