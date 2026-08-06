# Asteroid Database Schema


## Data Source

Asteroid data is retrieved from the NASA/JPL Small-Body Database (SBDB) Query API. We also include user_id, as no two users can get the same asteroid to their doorstep.

## Table
| Column           | Type      | Description            | Notes                                                                                                 |
| ---------------- | --------- | ---------------------- | ----------------------------------------------------------------------------------------------------- |
| `spkid`          | `TEXT`    | SPK ID                 | **Primary Key**. Unique identifier assigned by JPL.                                                   |
| `full_name`      | `TEXT`    | Name                   | Full designation or official name of the object.                                                      |
| `kind`           | `TEXT`    | Object type            | `an` = numbered asteroid, `au` = unnumbered asteroid, `cn` = numbered comet, `cu` = unnumbered comet. |
| `diameter`       | `REAL`    | Diameter               | Measured in kilometres (km).                                                                          |
| `diameter_sigma` | `REAL`    | Diameter uncertainty   | One standard deviation (1σ) uncertainty, in kilometres (km).                                          |
| `first_obs`      | `TEXT`    | First observation date | Stored as ISO 8601 (`YYYY-MM-DD`). Partial dates use `?`, e.g. `1998-??-??`.                          |
| `last_obs`       | `TEXT`    | Last observation date  | Stored as ISO 8601 (`YYYY-MM-DD`). Partial dates use `?`, e.g. `2025-??-??`.                          |
| `user_id`        | `INTEGER` | Assigned user          | Foreign key referencing `users(id)`. `NULL` if the asteroid is unassigned.                            |

## API Endpoint

```text
https://ssd-api.jpl.nasa.gov/sbdb_query.api?fields=spkid,full_name,diameter,diameter_sigma,first_obs,last_obs,kind&sb-kind=a&sb-cdata=%7B%22AND%22%3A%5B%22diameter%7CRG%7C0.5%7C1%22%5D%7D
```

This query returns all asteroids with a diameter between **0.5 km** and **1.0 km**, along with the fields used by the application.

## Response

```json
{
  "signature": {
    "source": "NASA/JPL SBDB (Small-Body DataBase) Query API",
    "version": "1.0"
  },
  "fields": [
    "spkid",
    "full_name",
    "diameter",
    "diameter_sigma",
    "first_obs",
    "last_obs",
    "kind"
  ],
  "data": [
    [
      20001221,
      "  1221 Amor (1932 EA1)",
      "1.0",
      null,
      "1932-03-12",
      "2025-02-19",
      "an"
    ],
    [
      20001566,
      "  1566 Icarus (1949 MA)",
      "1.0",
      null,
      "1949-07-01",
      "2025-08-18",
      "an"
    ]
  ]
}
```