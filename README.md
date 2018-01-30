# egwebsite

The static website of easeglass.

## Development

- Watch for changes and automatically refresh across devices

```sh
$ gulp serve
```
- Build & Optimize

```sh
$ gulp
```

- Serve the Fully Built & Optimized Site

```sh
$ gulp serve:dist
```

> Please note,
>
> * `serve` uses a no-op `service-worker.js` and cannot run offline.
> * `serve:dist` uses the `sw-precache`-generated output and can run offline.

- Performance Insights

```sh
$ gulp pagespeed
```
