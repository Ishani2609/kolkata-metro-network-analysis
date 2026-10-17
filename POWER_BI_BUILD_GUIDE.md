# Power BI build guide

## Import
1. Open Power BI Desktop.
2. Get Data → Text/CSV → select `data/processed/metro_station_records_cleaned.csv`.
3. Verify data types:
   - Station ID: whole number (do not use as a measure).
   - Distance from Start (km), Latitude, Longitude: decimal number.
   - Opening Date Parsed: Date (blank for Upcoming or unresolved values).
   - Opening Year: whole number.
   - Date Status, Line, Station Layout: text.
4. Rename the imported table `MetroStations`.
5. Set Latitude data category to Latitude and Longitude to Longitude.
6. Check that totals match `reports/station_records_by_line.csv` and the notebook.

## Page 1 — Network overview
- KPI card: station records (`Station Records`).
- Bar chart: station records by Line.
- Stacked bar: station records by Line and Station Layout.
- Column chart: records by Opening Year, filtered to Date Status = Parsed.
- Map: Latitude and Longitude, with Line in Legend and Station Name in Tooltips.
- Slicers: Line, Station Layout, Date Status.

## Page 2 — Station explorer
- Table: Station ID, Station Name, Line, Station Layout, Distance from Start (km), Opening Date Raw, Date Status.
- Scatter chart: Longitude and Latitude, colored by Line.
- Bar chart: records by Date Status.
- Add a note that distance differences are exploratory until route order/segments are verified.

## DAX starter measures
Create these measures after confirming the column names and imported types:

```dax
Station Records =
COUNTROWS(MetroStations)

Distinct Station Names =
DISTINCTCOUNT(MetroStations[Station Name])

Upcoming Records =
CALCULATE(
    [Station Records],
    MetroStations[Date Status] = "Upcoming"
)

Missing Coordinate Records =
CALCULATE(
    [Station Records],
    FILTER(
        MetroStations,
        ISBLANK(MetroStations[Latitude])
            || ISBLANK(MetroStations[Longitude])
    )
)

Records With Date Review =
CALCULATE(
    [Station Records],
    MetroStations[Date Status] = "Needs review"
)
```

## Design and validation
- Use consistent colors per line and avoid decorative 3D charts.
- Label units and explain what each KPI counts.
- Add a source note and the date the dataset was reviewed.
- Do not call record counts "passenger demand" or imply this is a complete operational network census.
- Before publishing, reconcile all key counts with the Python and SQL outputs.
- Save the report as `powerbi/kolkata_metro_network_analysis.pbix` and export screenshots to `reports/figures/`.
