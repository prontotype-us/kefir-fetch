# kefir-fetch

[Kefir](https://github.com/rpominov/kefir)  wrapper around [`fetch`](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) with JSON-friendly defaults

## Installation

```
npm install kefir-fetch
```

## Usage

`fetch$(method, path, options?)`

The optional `options` argument may include:

* `body`: JSON request body
* `query`: JSON query object, which is encoded and appended to the URL
* `headers`: Override HTTP headers, which by default are:
    * `"Accept": "application/json"`
    * `"Content-Type": "application/json"`
* `base_url`: Base URL to prepend path to, useful for non-web apps

### Default options

`fetch$.setDefaultOptions(options)`

To override the default options for all requests, use `setDefaultOptions`.

## Examples

```coffee
fetch$ = require 'kefir-fetch'

# Get an item

fetch$('get', '/item/55.json').onValue (item) ->
    console.log "Got item:", item

# Update some item, using the body option

update = {score: 0.43}

fetch$('put', '/items/55.json', {body: update}).onValue (updated) ->
    console.log "Updated item:", updated

# Search for some items, using the query option

search = {q: "some"}

fetch$('get', '/items.json', {query: search}).onValue (items) ->
    console.log "Found items:", items
```
