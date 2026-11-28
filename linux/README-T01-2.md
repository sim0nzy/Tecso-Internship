# Nginx Log Report

## 1. Total Requests
240

## 2. Top 5 IP Addresses
| Count | IP Address |
| --- | --- |
| 62 | 185.12.4.17 |
| 53 | 5.160.22.9 |
| 35 | 91.98.31.200 |
| 25 | 37.152.180.3 |
| 22 | 2.180.7.44 |

## 3. HTTP Status Codes
| Count | Status Code |
| --- | --- |
| 201 | 200 |
| 15 | 401 |
| 10 | 403 |
| 7 | 500 |
| 3 | 404 |
| 2 | 503 |
| 2 | 502 |

## 4. Server Error Paths (5XX)
| Count | Path |
| --- | --- |
| 9 | /api/report |
| 1 | /tasks/42 |
| 1 | /static/app.js |

## 5. Peak Traffic Hour
| Count | Hour |
| --- | --- |
| 83 | 09:00 |

## 6. Failed Requests
16.2%

## 7. Suspicious IP Addresses
| Failed Logins | IP Address |
| --- | --- |
| 9 | 45.155.205.233 |

## Server Error Analysis

The /api/report endpoint accounts for 9 of
the 11 server-side errors. Possible causes
include database issues, backend exceptions,
or upstream service failures.

Further investigation of application and
Nginx error logs is required.

## Security Recommendations

The IP address 45.155.205.233 received
9 HTTP 401 responses, suggesting a possible
brute-force attempt.

- Enable Nginx rate limiting.
- Use Fail2ban for temporary IP blocking.
- Limit login attempts.
- Monitor authentication logs.

## Testing

- Bash syntax validation: Passed
- Missing file handling: Passed
- All six reports: Passed
- Markdown output: Passed
- Suspicious IP detection: Passed
