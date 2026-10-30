# Putting a Common site on the internet

The built-in server (`cl serve`) is for development. It is fine for a personal
site behind a reverse proxy, and it forks one process per request so a slow or
broken page cannot take it down, but it speaks HTTP/1.0 and knows nothing about
TLS. For hosting, run Common the way PHP was first run: as a CGI program behind
a real web server.

## How CGI mode works

`cl cgi` reads the standard CGI variables the web server sets, runs the page
named by `SCRIPT_FILENAME`, and prints the response:

- `REQUEST_METHOD`, `QUERY_STRING` and the request body feed `query` and `form`.
- `PATH_INFO` (or `SCRIPT_NAME`) is what the page sees as `path`.
- `go to` becomes a `Status: 303` with a `Location` header.

## cPanel shared hosting (HawkHost and similar)

Shared cPanel plans (64-bit Linux with CGI allowed) are all Common needs. Build
a static `cl` with SQLite inside it, so the server needs no libraries. On any
Linux x86-64 machine, or in a container (`docker run --rm -v "$PWD":/w -w /w gcc:13 ...`):

```sh
gcc -O2 -std=c11 -DCL_SQLITE -static -o cl src/cl.c -lsqlite3 -lpthread -ldl -lm
./cl version     # check it is the version you expect before uploading
```

Rebuild and upload again after every release: a binary does not update itself.
That build is SQLite only. A static Postgres build is not worth the trouble on
shared hosting; use a normal `make` on a server where you control the packages.

1. **Upload the interpreter.** In cPanel's File Manager (or over SFTP), open
   `public_html/cgi-bin/` (create it if needed), upload `cl`, and set its
   permissions to `755`.
2. **Upload the site.** Put your pages in `public_html/`.
3. **Add the `.htaccess`** below to `public_html/`, or append its lines to the
   one you have.
4. **Open the site.** The first request creates `cl.secret` next to the pages.
   Then lock down the data: `chmod 600 site.db cl.secret`. Shared hosts run CGI
   as your own account (suEXEC), so `600` keeps other customers out.

```apache
# Run every .html page through Common
Action common /cgi-bin/cl
AddHandler common .html

# Clean addresses: /about -> about.html, /blog/hello-world -> blog.html
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^([^.]+)/.*$ $1.html [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^([^.]+)$ $1.html [L]

# Never serve the database, its seed, or the session secret (any case)
<FilesMatch "(?i)\.(db|sqlite|sqlite3|sql|secret|eml|log)$|\.db-(journal|wal|shm)$">
  Require all denied
</FilesMatch>
```

Over SSH instead: `mkdir -p ~/public_html/cgi-bin && cp cl ~/public_html/cgi-bin/ && chmod 755 ~/public_html/cgi-bin/cl`.
If the host has gcc and SQLite headers, you can also build there: `gcc -O2 -std=c11 -DCL_SQLITE -o cgi-bin/cl src/cl.c -lsqlite3`.

**If it does not work**

- **Raw `<cl>` text on the page.** The handler is not applied. Check that
  `.htaccess` is in the pages' folder or a parent, and that `/cgi-bin/cl` in
  the `Action` line matches where the binary is.
- **500 error.** Usually permissions: `cl` must be `755`, and the folders above
  it must not be group-writable (`755`, not `775`). cPanel's Error Log has the reason.
- **Database is locked / cannot open.** The folder must be writable by your
  account, and the `.db` file `600` or `644`.
- **Sign-in forgets everyone.** `cl.secret` could not be written: make the
  folder writable, or create the file yourself with 64 random hex characters.

## Apache (shared hosting, .htaccess)

Copy the `cl` binary into `cgi-bin/` and add to `.htaccess` (also add the
`FilesMatch` block from the cPanel section, so the database and `cl.secret` are never sent):

```
Action common /cgi-bin/cl
AddHandler common .html
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^([^.]+)$ $1.html [L]
```

The last two lines give you clean URLs. `/blog/hello-world` needs one more:

```
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^blog/ blog.html [L]
```

## nginx with fcgiwrap

```
location ~ \.html$ {
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_pass unix:/run/fcgiwrap.socket;
}
location / {
    try_files $uri $uri.html /index.html;
}
```

and point fcgiwrap at `cl cgi`.

## Caddy, reverse proxy to cl serve

The simplest option for a small personal site on your own machine:

```
example.com {
    reverse_proxy localhost:8000
}
```

with `cl serve 8000 /var/www/site` kept running by systemd. Caddy adds TLS.

Inside a container the dev server must listen on every interface, not just the
machine itself: `cl serve 0.0.0.0:8000 /site`.

## Postgres instead of SQLite

When Common is built on a machine with the Postgres client library (`brew
install libpq` on macOS, `apt install libpq-dev` on Debian and Ubuntu), the
same three words also talk to a Postgres server:

```
open database "postgres://app:secret@localhost/site"
set posts to ask database "select * from posts where slug = ?" with slug
tell database "insert into notes (body) values (?)" with note
```

Write `?` for each value as with SQLite; Common turns them into `$1`, `$2`
for Postgres.

Numbers, booleans and nulls come back as numbers, yes/no and
empty text. Keep the address line in an included `.html` file: Common runs
pages instead of sending them, so the password never reaches a browser.

## Email from forms

`send email` (see the dictionary) works with no setup on most hosts. Under
`cl cgi` it hands each email to the server's `sendmail` program, which cPanel
and nearly every Linux host provide.

- **The from address.** Write one on your own domain, like
  `from: "website@yourdomain.com"`. Mail from a domain you do not own is
  usually marked as spam. On cPanel, the domain's email settings should show
  SPF and DKIM as valid.
- **sendmail somewhere else?** Set `CL_SENDMAIL` to its path, with
  `SetEnv CL_SENDMAIL /path/to/sendmail` in `.htaccess` on Apache.
- **Testing on the live site without sending:** `SetEnv CL_MAIL outbox` saves
  emails in `outbox/` as files instead, like the development server does.
- **Keep the files private.** `outbox/` and `mail.log` sit next to the pages.
  The built-in server never sends them. Behind Apache, the `FilesMatch` block
  above covers `.eml` and `.log` files. On nginx, add
  `location ~ (/outbox/|\.(eml|log)$) { deny all; }`.
- **The speed limit** is 20 emails an hour for the site, counted in
  `mail.log`. `SetEnv CL_MAIL_PER_HOUR 50` raises it.

Sending through a mail service such as Postmark or Mailgun over SMTP, without
sendmail, is not built in yet.

## Things to know

- The built-in server never sends `.db`, `.sqlite` or `.sql` files, so the
  database can sit next to the pages. Behind Apache or nginx it is the web
  server that sends static files, so add the same rule there, or keep the
  database in a folder above the site and `open database "../data/site.db"`.
  Apache: `<FilesMatch "\.(db|sqlite|sql)$">Require all denied</FilesMatch>`.
  nginx: `location ~ \.(db|sqlite|sql)$ { deny all; }`.
- The file must be writable by the user the web server runs as, and readable
  by nobody else: `chmod 600 site.db`. On hosts where every site runs as the
  same user, other customers' scripts can read anything that user can read.
- Use a local disk. SQLite's locking is unreliable on NFS and some network
  storage. Common waits up to three seconds for a write lock, which is plenty
  for a small site.
- Back up with `sqlite3 site.db ".backup copy.db"`, not `cp`, so you never
  copy a file mid-write.
- `cl.secret` in the site folder signs session cookies. Common creates it on
  first use and never serves it. Keep it with the site, `chmod 600`, and if it
  ever leaks, delete it: everyone is signed out and a new one is made.
- Common escapes output and binds database parameters. It has no rate limiting
  except on email, so a public guestbook will collect spam.
- Common refuses a form posted from another site (the browser's `Origin`
  header names a different host than the request). Behind a reverse proxy
  that rewrites `Host`, pass the visitor's host on as `X-Forwarded-Host`
  (Caddy and most proxies do), or forms on your site will be refused too.
- Every response says `X-Frame-Options: SAMEORIGIN`, so your pages cannot be
  shown inside a frame on another site.
- Set the server's clock and timezone. `today` and `now` use the machine's
  local time.
