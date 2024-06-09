FROM busybox:1.35

WORKDIR /app

COPY src/ .

ARG ip
RUN sed -i "s/localhost/$ip/g" /app/index.js
RUN sed -i "s/localhost/$ip/g" /app/game.js

ENTRYPOINT ["busybox"]

CMD ["httpd", "-f", "-v", "-p", "8081"]