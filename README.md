## Project Overview

This repository documents my hands-on learning journey with dbt, PostgreSQL, Docker, and Apache Airflow. The project builds an end-to-end analytics pipeline using a layered warehouse architecture.

The pipeline follows this data flow:

`CSV Seeds → RAW → STAGE → DEV → Tests and Automation`

## Key Skills and Concepts Learned

Throughout the weekly assignments, I practiced:

- Loading CSV data into PostgreSQL using dbt seeds.
- Building a two-layer warehouse architecture using `STAGE` and `DEV` schemas.
- Cleaning, casting, and standardizing source data in staging models.
- Creating dimension and fact tables using SQL and dbt references.
- Building incremental models with `is_incremental()` and `unique_key`.
- Capturing historical changes using dbt snapshots.
- Creating generic and custom data-quality tests.
- Configuring test severity and storing failed test records.
- Reusing business logic through dbt macros.
- Adding model-level and project-level hooks.
- Creating and measuring PostgreSQL indexes with `EXPLAIN ANALYZE`.
- Orchestrating the complete dbt pipeline with Apache Airflow.
- Configuring task dependencies, retries, retry delays, and `catchup`.
- Running the complete environment with Docker Compose.

## Repository Structure

- `dbt_learning/` — dbt project containing models, seeds, tests, macros, snapshots, and project configuration.
- `airflow/dags/` — Airflow DAGs used to automate the dbt pipeline.
- `scripts/` — assignment grading and supporting scripts.
- `week_1/` to `week_6/` — screenshots, notes, query results, and other evidence used for grading.
- `docker-compose.yml` — defines the PostgreSQL and Airflow services.
- `Dockerfile.airflow` — builds the Airflow image with compatible dbt dependencies.
- `Dockerfile.dbt` — defines the standalone dbt environment.

## Assignment Evidence and Grade Documentation

Each weekly folder contains supporting evidence demonstrating that the assignment requirements were completed. Depending on the week, the evidence includes:

- Screenshots of successful dbt and Airflow runs.
- Airflow Graph views showing successful pipeline tasks.
- Query results and PostgreSQL execution plans.
- Before-and-after index performance measurements.
- Implementation notes and result interpretations.
- Auto-grader results where applicable.

For example:

- `week_5/notes.md` records the index performance measurements and explains why PostgreSQL selected sequential or index scans.
- `week_6/` contains screenshots showing the successful Airflow DAG, including the final `dbt_build` task.

## Pipeline Automation

The Airflow DAG executes the pipeline in the following order:

1. `dbt_seed`
2. `dbt_test_sources`
3. `dbt_run_stage`
4. `dbt_test_stage`
5. `dbt_run_dev`
6. `dbt_test_dev`
7. `dbt_build`

The DAG includes automatic retries, a five-minute retry delay, and `catchup=False` to prevent unnecessary historical runs.