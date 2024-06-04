FROM busybox:1.35

RUN adduser -D stud
USER stud
WORKDIR /home/stud

COPY src/ .

ENTRYPOINT ["busybox"]
<<<<<<< HEAD
CMD ["httpd", "-f", "-v", "-p", "8081"]
=======
CMD ["httpd", "-f", "-v", "-p", "8081"]
EXPOSE 8081
>>>>>>> 53d668d (changes)
