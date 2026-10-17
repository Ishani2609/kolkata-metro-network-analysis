-- Kolkata Metro Network Analysis: SQLite starter schema and queries
-- Load data/processed/metro_station_records_cleaned.csv into this table.
-- Preserve all source rows. Review line/name issues rather than auto-correcting them.

CREATE TABLE IF NOT EXISTS metro_stations (
    "Station ID" INTEGER,
    "Station Name" TEXT,
    "Distance from Start (km)" REAL,
    "Line" TEXT,
    "Opening Date" TEXT,
    "Station Layout" TEXT,
    "Latitude" REAL,
    "Longitude" REAL,
    "Opening Date Raw" TEXT,
    "Opening Date Parsed" TEXT,
    "Date Status" TEXT,
    "Opening Year" INTEGER,
    "Name Appears Across Lines" INTEGER,
    "Coordinate Missing" INTEGER,
    "Distance Missing" INTEGER,
    "Date Needs Review" INTEGER,
    "Opening Date ISO" TEXT
);

-- 1. Source record count by line (record counts, not passenger demand).
SELECT "Line", COUNT(*) AS station_records,
       COUNT(DISTINCT "Station Name") AS distinct_station_names
FROM metro_stations
GROUP BY "Line"
ORDER BY station_records DESC;

-- 2. Layout mix by line.
SELECT "Line", "Station Layout", COUNT(*) AS station_records
FROM metro_stations
GROUP BY "Line", "Station Layout"
ORDER BY "Line", station_records DESC;

-- 3. Date-status audit.
SELECT "Date Status", COUNT(*) AS record_count
FROM metro_stations
GROUP BY "Date Status"
ORDER BY record_count DESC;

-- 4. Station IDs that occur more than once.
SELECT "Station ID", COUNT(*) AS record_count
FROM metro_stations
GROUP BY "Station ID"
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- 5. Station names recorded against multiple line labels.
-- This may represent interchanges; validate with a trusted source.
SELECT "Station Name",
       COUNT(DISTINCT "Line") AS line_count,
       GROUP_CONCAT(DISTINCT "Line") AS lines
FROM metro_stations
GROUP BY "Station Name"
HAVING COUNT(DISTINCT "Line") > 1
ORDER BY line_count DESC, "Station Name";

-- 6. Parsed opening records by year. Upcoming records are excluded.
SELECT "Opening Year", COUNT(*) AS station_records
FROM metro_stations
WHERE "Date Status" = 'Parsed'
GROUP BY "Opening Year"
ORDER BY "Opening Year";

-- 7. CTE: within-line layout percentage.
WITH layout_counts AS (
    SELECT "Line", "Station Layout", COUNT(*) AS records
    FROM metro_stations
    GROUP BY "Line", "Station Layout"
),
line_totals AS (
    SELECT "Line", COUNT(*) AS total_records
    FROM metro_stations
    GROUP BY "Line"
)
SELECT l."Line", l."Station Layout", l.records, t.total_records,
       ROUND(100.0 * l.records / NULLIF(t.total_records, 0), 2) AS pct_within_line
FROM layout_counts l
JOIN line_totals t ON t."Line" = l."Line"
ORDER BY l."Line", l.records DESC;

-- 8. Window function: exploratory distance differences after sorting by distance.
-- WARNING: this is NOT verified route adjacency. Validate route order/segments first.
WITH ordered AS (
    SELECT
        "Station ID", "Station Name", "Line", "Distance from Start (km)",
        LAG("Distance from Start (km)") OVER (
            PARTITION BY "Line" ORDER BY "Distance from Start (km)", "Station ID"
        ) AS previous_distance
    FROM metro_stations
    WHERE "Distance from Start (km)" IS NOT NULL
)
SELECT *,
       "Distance from Start (km)" - previous_distance AS exploratory_distance_difference_km
FROM ordered
WHERE previous_distance IS NOT NULL
ORDER BY "Line", "Distance from Start (km)";

-- 9. Missing or implausible coordinate audit (broad bounds only).
SELECT "Station ID", "Station Name", "Line", "Latitude", "Longitude"
FROM metro_stations
WHERE "Latitude" IS NULL OR "Longitude" IS NULL
   OR "Latitude" NOT BETWEEN 22.0 AND 23.0
   OR "Longitude" NOT BETWEEN 87.5 AND 89.0;

-- 10. Reconcile row counts by line with Python output before publishing.
SELECT "Line", COUNT(*) AS station_records
FROM metro_stations
GROUP BY "Line"
ORDER BY "Line";
