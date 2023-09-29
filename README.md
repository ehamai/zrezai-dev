# Website in Hugo

## Build your website

Customize the [config.toml](./dev/config.toml) according to your needs.

```shell
export BASEURL="https://zops.top/"

docker run -it --rm -v $(pwd)/dev:/tmp xcalizorz/hugo:v0.95.0-alpine \
  hugo --minify \
  --baseUrl ${BASEURL} \
  --destination public

                   | DE
-------------------+-----
  Pages            | 74
  Paginator pages  |  3
  Non-page files   |  0
  Static files     | 43
  Processed images |  0
  Aliases          | 30
  Sitemaps         |  1
  Cleaned          |  0
```

Now the new files are stored at `dev/public/`, you can upload them to your server and enjoy. :)
