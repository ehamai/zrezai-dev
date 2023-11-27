FROM xcalizorz/hugo:1.0-alpine as builder

ARG BASE_URL

WORKDIR /app/dev
COPY dev /app/dev/

RUN hugo --minify --baseUrl azure-test.zops.top --destination public

FROM nginx:1.21

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf.template /etc/nginx/conf.d/default.conf.template
COPY --from=builder /app/dev/public /usr/share/nginx/html

CMD /bin/bash -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'
