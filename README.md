# IBD WEEK 6 ASSIGNMENTS
**Problem Statement**

Use Google Cloud Dataproc and SparkSQL to analyze customer data and demonstrate the handling of Slowly Changing Dimensions (SCD).

All data is provided to you through Google Drive links. Download the files and upload them to your Google Cloud Storage (GCS) bucket before starting the analysis. (done)

1. Aggregation Queries: Using the transactions data, write SparkSQL queries to compute:
  - Top 5 customers by total transaction amount
  - Number of customers per city
  - Average transaction value overall
2. Save each query result as a separate CSV in GCS.
  - Slowly Changing Dimensions (SCD): Use the Customer Master and Customer Updates datasets to demonstrate:
    - SCD Type I
    - SCD Type II
  - Show before and after states of the Customer Master table for both SCD Type I and Type II.
  - Output and Validation: Print or log query outputs and table previews in the driver logs.
  - Ensure all updated tables or query results are written back to GCS.

**Notes:**
 - Use only SparkSQL (no PySpark DataFrame API).
 - All tasks must be executed on GCP Cluster using GCS for input and output.

## Concepts to Learn

### GCP / Dataproc
- GCP project, region, billing, IAM roles
- GCS buckets, `gs://` paths, upload/download
- Dataproc cluster lifecycle: create, submit job, view logs, delete
- Job submission with `gcloud dataproc jobs submit spark-sql` or PySpark wrapper
- Driver logs vs executor logs
- GCS input/output paths and overwrite behavior

### Spark / SparkSQL
- SparkSession and temp views
- Reading CSV into SQL tables/views: headers, schema inference, data types
- Writing query results to CSV in GCS
- Aggregations: `SUM`, `AVG`, `COUNT`, `GROUP BY`, `ORDER BY`, `LIMIT`
- Top-N per customer: aggregate then sort
- Distinct customer counts per city
- Date handling for SCD effective/expiry dates
- SQL DDL/DML: `CREATE TABLE`, `INSERT`, `UPDATE`, `MERGE INTO` if supported
- Before/after table snapshots with `SELECT`

### SCD
- Dimension table vs fact table basics
- SCD Type I: overwrite changed attributes, no history
- SCD Type II: expire old record, insert new version, track `effective_date`, `expiry_date`, `current_flag`
- Natural key vs versioned rows
- Handling changed vs unchanged customer updates
- Validation: row counts, current flags, date ranges, before/after diffs

## Suggested Learning Order
1. Local SparkSQL setup
2. Load and inspect CSV data locally
3. SparkSQL CSV read/write
4. Aggregation queries
5. SCD Type I
6. SCD Type II
7. Logging and validation
8. GCS path handling
9. Dataproc cluster + job submission
10. Run pipeline on GCP
11. Cleanup cluster/resources
