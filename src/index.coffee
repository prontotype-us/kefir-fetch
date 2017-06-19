require 'whatwg-fetch'
window?.Buffer ||= require('buffer').Buffer
deepExtend = require 'deep-extend'
Kefir = require 'kefir'

# Helpers

makeQueryString = (query) ->
    s = "?"
    for k, v of query
        if v?
            s += k + "=" + v + "&"
    return s

timeoutPromise = (context, p, ms) ->
    new Promise (resolve, reject) ->
        timeout_timeout = setTimeout ->
            response = {error: "Request timed out"}
            Object.assign response, context
            reject response
        , ms

        clear_res = (res) ->
            clearTimeout timeout_timeout
            resolve(res)
        clear_rej = (rej) ->
            clearTimeout timeout_timeout
            reject(rej)
        p.then clear_res, clear_rej

# ## Usage
# 
# fetch$(method, path, options?)
# 
# The optional options argument may include:
# 
# * body: JSON request body
# * query: JSON query object, which is encoded and appended to the URL
# * headers: Override HTTP headers, which by default are:
#     * "Accept": "application/json"
#     * "Content-Type": "application/json"

fetch$ = (method, url, options={}) ->

    # Build fetch options
    options.method = method

    if query = options.query
        url += makeQueryString query
        delete options.query

    if body = options.body
        options.body = JSON.stringify body

    if file = options.file
        post_data = new FormData()
        post_data.append 'upload_data', file
        options.body = post_data

        # Don't set the headers like other requests as this messes with the FormData
        options.headers = {
            'Accept': 'application/json'
        }
        options.credentials = 'same-origin'
        delete options.file

    else
        _options = deepExtend {}, fetch$.default_options, options
        options = _options

    context = {method, url, query, body}

    if base_url = options.base_url
        if !(url.match /^https?:/)
            url = base_url + url

    # fetch request as a promise
    fetch_promise = fetch(url, options).then (res) ->

        # Parse a good response
        # TODO: Handle non-json responses
        if res.status == 200
            if options.headers['Accept'] == 'application/json'
                res.json()
                    .catch (err) ->
                        Promise.reject("Could not parse response")
            else
                return res.text()

        # Parse an error response
        else
            res.text().then (json_string) ->

                if !json_string.length
                    return "Error #{res.status} with no response"

                try
                    json = JSON.parse json_string
                    return json

                catch e
                    return {error: json_string}

            # Turn into an error
            .then (response) ->
                Object.assign response, context
                Promise.reject response

    # Optionally wrap in promise helper
    if timeout = options.timeout
        fetch_promise = timeoutPromise context, fetch_promise, timeout

    # Return fetch request as stream
    Kefir.fromPromise fetch_promise

# Options

fetch$.default_options =
    headers:
        'Accept': 'application/json'
        'Content-Type': 'application/json'
    credentials: 'same-origin'

fetch$.setDefaultOptions = (options) ->
    deepExtend fetch$.default_options, options

module.exports = fetch$
