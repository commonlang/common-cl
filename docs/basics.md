# Common: the basics of building a website

A walk through the features a website needs, one at a time, with the Common
for each. Every word is in the full reference, `docs/dictionary.md`, and
`examples/hello.html` shows several of them in one page.

---

## Design Rules

These rules keep the language readable and simple to interpret.

1. **One statement per line.** No semicolons.
2. **Lowercase keywords.** `show`, `set`, `if`, `repeat`, `end`.
3. **Blocks end with `end`.** No braces, no indentation rules.
4. **Text goes in double quotes.** `"like this"`. Use `\"` for a quote inside text and `\n` for a new line.
5. **Names are plain words.** `name`, `total`, `page_title`. A name cannot be a Common word; see `docs/dictionary.md`.
6. **Comments start with `#`.**
7. **Code lives in `<cl> ... </cl>` tags** inside normal HTML. Everything outside the tags is sent to the browser untouched.

---

## 1. Output

Every website needs to write text into the page.

```
show "Hello World!"
```

`show` shows any value. Text typed by a visitor is made safe automatically, so a visitor can never inject tags into your page. HTML you wrote yourself in quotes is shown as HTML. `show raw` turns the safety off for one value.

```
show "<p>Hello, [visitor_name]</p>"   # visitor_name is made safe, the <p> is not
```

---

## 2. Variables

Store a value and use it later: a page title, a username, a count.

```
set name to "World"
set count to 3
show name
```

Rules: `set X to VALUE` creates or replaces a variable. Values are text, numbers, or lists. A variable is readable anywhere later in the same page.

---

## 3. Putting Values in Text

Building sentences from pieces is the most common thing a web page does.

a value goes inside the text in brackets. Numbers and lists turn into text automatically. A list reads `apple, banana, cherry`. Any value works inside the brackets, including math and `count of`.

```
set name to "World"
show "Hello, [name]!"
show "You have [count of messages] new messages. Half: [count of messages / 2]"
```

---

## 4. Numbers and Math

Prices, totals, page numbers, "x items in cart".

```
set price to 4.50
set quantity to 3
set total to price * quantity
show "Total: [total]"
```

Operators: `+ - * /`, on numbers only. Parentheses group as usual. Numbers can have decimals.

---

## 5. Conditions

Show one thing to logged-in visitors and another to everyone else. Show "no results" when a list is empty.

```
if count is 0
  show "No messages."
otherwise if count is 1
  show "One message."
otherwise
  show "[count of messages] messages."
end
```

Comparisons in English: `is`, `is not`, `is more than`, `is less than`, `is at least`, `is at most`, `is empty`, `is not empty`. Combine with `and`, `or`, `not`. The values `yes` and `no` are built in.

---

## 6. Lists

Menus, blog posts, products, search results. Almost every page shows a list of something.

```
set fruits to "apple", "banana", "cherry"
show first of fruits
show last of fruits
show item 2 of fruits
show count of fruits
add "date" to fruits
```

---

## 7. Loops

Print every item in a list, or repeat something a set number of times.

```
for each fruit in fruits
  show "<li>[fruit]</li>"
end

repeat 3 times
  show "<hr>"
end
```

---

## 8. Reading the Request

A website is interactive only if it can read what the visitor sent: the URL, a search box, a form.

**Partly done:** `query` and `path` work. `form` (POST data) is next.

```
set q to query "q"            # from ?q=shoes in the URL
set email to form "email"     # from a submitted form field
set page to path              # the URL path, like /about
```

A missing value is empty text, so pages do not crash when a field is left out.

---

## 9. Including Other Files

Every page shares a header, navigation, and footer. Writing them once matters.

```
include "header.html"
show "<h1>About us</h1>"
include "footer.html"
```

Included files can contain their own `<cl>` blocks and see the same variables.

---

## 10. Comments

```
# This line is ignored.
```

---

## Putting It Together

A complete small page using everything above:

```html
<!DOCTYPE html>
<html>
<body>
<cl>
  include "header.html"

  set name to query "name"
  if name is ""
    set name to "stranger"
  end
  show "<h1>Hello, [name]!</h1>"

  set fruits to "apple", "banana", "cherry"
  show "<p>We have [count of fruits] fruits today:</p>"
  show "<ul>"
  for each fruit in fruits
    show "<li>[fruit]</li>"
  end
  show "</ul>"

  include "footer.html"
</cl>
</body>
</html>
```

---

## Build Order

Each step is small and testable on its own.

1. ~~Variables and text joining~~ Done.
2. ~~Numbers and math~~ Done.
3. ~~Conditions~~ Done.
4. ~~Lists and loops~~ Done.
5. Reading the request. `query` and `path` done; `form` for POST data is next.
6. ~~Including files~~ Done.
7. ~~Safe output~~ Done, automatic.

After `form`, Common can serve a real multi-page site with forms. Later topics
not covered here: saving data to files or a database, sessions and logins,
sending email, dates and times, and user-defined commands.
