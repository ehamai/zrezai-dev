---
title: Der Walrus-Operator (Python 3.8)
author: Zadjad Rezai
type: post
date: 2019-10-29T20:56:27+00:00
excerpt: 'Der Walrus-Operator ist mein persönliches Highlight, da ich ihn immer gebraucht habe - nur vorher wusste ich nicht wie sehr ich ihn gebraucht habe.'
url: /python/walrus-operator/
featured_image: /img/tusk.webp
cover: /img/tusk.webp
eael_transient_elements:
  - 'a:0:{}'
eael_uid:
  - cbfg8041573678329
categories:
  - PEP
  - Python
tags:
  - pep-572
  - walrus

---
Endlich ist er da. Der Walrus-Operator, eingeführt mit <a href="https://www.python.org/dev/peps/pep-0572/" target="_blank" rel="noreferrer noopener" aria-label=" (öffnet in neuem Tab)">PEP 572 &#8212; Assignment Expressions</a>.

Der Walrus-Operator ist mein persönliches Highlight, da ich ihn immer gebraucht habe &#8211; nur vorher wusste ich nicht wie sehr ich ihn gebraucht habe.

Er bringt eine riesen Erleichterung, macht unseren Code kompakter, lesbarer und natürlicher schöner (das Auge liest mit) 😬

PEP 572 beschreibt die <a href="https://www.python.org/dev/peps/pep-0572/#id9" target="_blank" rel="noreferrer noopener" aria-label=" (öffnet in neuem Tab)">Syntax des Walrus-Operators</a> meiner Meinung nach perfekt:

<blockquote class="wp-block-quote">
  <p>
    In most contexts where arbitrary Python expressions can be used, a&nbsp;<strong>named expression</strong>&nbsp;can appear. This is of the form&nbsp;NAME := expr&nbsp;where&nbsp;expr&nbsp;is any valid Python expression other than an unparenthesized tuple, and&nbsp;NAME&nbsp;is an identifier.
  </p>

  <p><br>
    The value of such a named expression is the same as the incorporated expression, with the additional side-effect that the target is assigned that value:
  </p>

  <cite><a href="https://www.python.org/dev/peps/pep-0572/#id9" target="_blank" rel="noreferrer noopener" aria-label=" (öffnet in neuem Tab)"><br>‒ PEP 572 # Syntax and semantics</a></cite>
</blockquote>

### Anwendungsbeispiele

Das Beispiel direkt aus dem PEP:

```python
# Handle a matched regex
if (match := pattern.search(data)) is not None:
    # Do something with match

# A loop that can't be trivially rewritten using 2-arg iter()
while chunk := file.read(8192):
   process(chunk)

# Reuse a value that's expensive to compute
[y := f(x), y**2, y**3]

# Share a subexpression between a comprehension filter clause and its output
filtered_data = [y for x in data if (y := f(x)) is not None]
```

Ein schönes Beispiel von <a rel="noreferrer noopener" aria-label=" (öffnet in neuem Tab)" href="https://twitter.com/VictorStinner/status/1014988580282912770" target="_blank">Victor Stinner</a> (leicht angepasst):

```python
># Without Walrus-Operator

while True:
    line = fp.readline()
    if not line:
        break
    match = pattern.search(line)

    if match:
        do_something_with_match(match)
    else:
        match = other_pattern.search(line)
        if match:
            do_something_with_match(match)
```

```python
# With Walrus-Operator

while (line := fp.readline()):
    if (match := pattern.search(line)):
        do_something_with_match(match)
    elif (match := other_pattern.search(line)):
        do_something_with_match(match)
```

Aufwendige Berechnungen in <a href="https://www.python.org/dev/peps/pep-0202/" target="_blank" rel="noreferrer noopener" aria-label="List Comprehensions  (öffnet in neuem Tab)">List Comprehensions </a>nicht wiederholen:

```python
# Without Walrus-Operator

filtered_data = [
  complex_func(x) for x in data
  if complex_func(x) is not None
]

# With Walrus-Operator

filtered_data = [
  y for x in data
  if (y := complex_func(x)) is not None
]
```

Daten einer API erhalten:

```python
# Without Walrus-Operator

import requests

book_information = requests.get(
    "https://openlibrary.org/api/books?bibkeys=ISBN:0201558025,LCCN:93005405&format=json"
)

for book_id in book_information.json():
    thumbnail_url = book_id['thumbnail_url']
    if thumbnail_url:
        print(f'Here is the thumbnail: {thumbnail_url}')
```

```python
# With Walrus-Operator

import requests

book_information = requests.get(
    "https://openlibrary.org/api/books?bibkeys=ISBN:0201558025,LCCN:93005405&format=json"
)

for book_id in book_information.json():
    if (thumbnail_url := book_id['thumbnail_url']):
        print(f'Here is the thumbnail: {thumbnail_url}')
```
