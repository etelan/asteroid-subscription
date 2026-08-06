### schema.md (Updated with Examples)
# Database Schema

## Table: `users`
| Column | Type | Description | Notes | Example |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | Primary Key | Auto-increment | `1` |
| `name` | `TEXT` | User Name | Required | `"John Doe"` |
| `address` | `TEXT` | Physical Address | | `"123 Space Lane"` |
| `email` | `TEXT` | Contact Email | Unique | `"john@nasa.gov"` |
| `is_admin` | `BOOLEAN` | Admin Status | `true`/`false` | `false` |

## Table: `asteroids`
| Column | Type | Description | Notes | Example |
| :--- | :--- | :--- | :--- | :--- |
| `spkid` | `TEXT` | SPK ID | **Primary Key** | `"20001221"` |
| `full_name` | `TEXT` | Name | Official name | `"1221 Amor (1932 EA1)"` |
| `kind` | `TEXT` | Object type | `an`, `au`, `cn`, `cu` | `"an"` |
| `diameter` | `REAL` | Diameter | In km | `1.0` |
| `diameter_sigma` | `REAL` | Uncertainty | 1σ in km | `null` |
| `first_obs` | `TEXT` | First observation | ISO 8601 | `"1932-03-12"` |
| `last_obs` | `TEXT` | Last observation | ISO 8601 | `"2025-02-19"` |
| `user_id` | `INTEGER` | Assigned user | FK to `users(id)` | `1` |

## Table: `subscriptions`
| Column | Type | Description | Notes | Example |
| :--- | :--- | :--- | :--- | :--- |
| `user_id` | `INTEGER` | User ID | FK to `users(id)` | `1` |
| `asteroid_id` | `TEXT` | Asteroid ID | FK to `asteroids(spkid)` | `"20001221"` |
| `upcoming_asteroid_id` | `TEXT` | Upcoming ID | FK to `asteroids(spkid)` | `"20001566"` |
| `max_diameter` | `REAL` | Max filter | User pref | `50.0` |
| `min_diameter` | `REAL` | Min filter | User pref | `0.5` |
| `perMonth` | `INTEGER` | Frequency | Notifications/mo | `4` |

**Note:** Rails `references` helper used for foreign keys. `spkid` is string-based key from NASA data.