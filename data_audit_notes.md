# Data audit notes

The following are observed from the supplied source file; they are not claims about the full current network.

- Source shape: 52 rows × 8 original columns.
- Original fields contain no null values in the loaded CSV.
- `Station ID` values are unique in this source snapshot.
- Six records have `Opening Date` equal to `Upcoming`; these are kept out of parsed historical-date analysis.
- Three station names appear against more than one line label: Esplanade, Howrah Maidan, and Kavi Subhash. This may reflect interchange/line assignment or data-source issues; it is a verification task, not an automatic correction.
- The distance field is monotonic after sorting by distance within each line, but sorting by distance is not proof of route order or physical adjacency.
- Broad coordinate bounds are used only as a plausibility check, not as an official study-area polygon.

Before public release, record the source publisher, URL, access date, and license. Reconcile any questionable station-line assignment or opening date with a reliable source.
