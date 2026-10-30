# Security policy

## Reporting a vulnerability

Please report security problems **privately**. Do not open a public issue,
pull request or discussion about an unfixed vulnerability.

- **Preferred:** use GitHub's private vulnerability reporting: on this
  repository, open the **Security** tab and choose **Report a vulnerability**.
  This works once the maintainers have enabled it.
- **If that is not available:** email **[info@commonlang.org](mailto:info@commonlang.org)**.

A useful report includes:

- the version (`cl version`) and how you built it (`make`, compiler, OS),
- the smallest page or request that shows the problem,
- what happens, and what you expected,
- whether it needs `cl serve`, `cl cgi`, SQLite, Postgres or email.

## What counts

Examples of what we consider a vulnerability in Common:

- a way for a visitor to run code, read files, or reach the database through
  a Common page that follows the documented rules,
- a way around a visitor-value rule (a visitor's value reaching SQL text,
  `include`, `open database`, an off-site `go to`, or an email recipient),
- forging or tampering with a remembered value (the signed session cookie),
- escaping the `try` sandbox, or making it use unbounded time or memory,
- the server sending a private file (`.db`, `.sql`, `.secret`, `outbox/`, `mail.log`),
- sending email a page did not intend, or header injection in email.

These are by design and are not vulnerabilities: `show raw` shows HTML as
written; a page's own author can read any file the page can; and the
development server (`cl serve`) is meant for development, not as a hardened
public web server.

## What to expect

Reports are read and evaluated by volunteers, as their time allows. **There is
no guaranteed response time, no guaranteed fix, and no guaranteed release
date.** Nobody monitors this project continuously, and there is no promise of
security updates for any version.

When a report is confirmed, the maintainers aim to fix it in a private branch,
publish a fixed release, and then publish an advisory that credits the
reporter (unless you prefer not to be named). Please give a reasonable amount
of time for a fix before disclosing details publicly.

## Supported versions

Only the newest release is considered for fixes. Common is before version 1.0,
so upgrading may change behavior; see [CHANGELOG.md](CHANGELOG.md).

See also [DISCLAIMER.md](DISCLAIMER.md).
