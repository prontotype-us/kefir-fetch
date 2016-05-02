Kefir = require 'kefir'

defaults = (o1, o2) ->
    for k, v of o2
        if !o1[k]?
            o1[k] = v
    return o1

makeQueryString = (query) ->
    s = "?"
    for k, v of query
        if v?
            s += k + "=" + v + "&"
    return s

default_options =
    headers:
        'Accept': 'application/json'
        'Content-Type': 'application/json'
    credentials: 'same-origin'

fetch$ = (method, url, options={}) ->
    options.method = method

    if options.query?
        url += makeQueryString options.query
        delete options.query

    if options.body?
        options.body = JSON.stringify options.body

    options = defaults options, default_options

    Kefir.fromPromise fetch(url, options).then (res) -> res.json()

module.exports = fetch$
