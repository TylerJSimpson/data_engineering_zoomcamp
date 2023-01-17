## 

## Docker and Postgres

Using MINGW64 Git Bash on Windows

```bash
winpty docker run -it  \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v /c/git/data-engineering-zoomcamp/week_1/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:13
```
