FROM swiftdocker/swift:4.1

RUN mkdir /app
WORKDIR /app
COPY . /app
RUN swift build -c release


FROM swiftdocker/swift:4.1
WORKDIR /root/
COPY --from=0 /app/.build/release/Run ./app
EXPOSE 8080
CMD SQLITE_DB_PATH=/stor/mensa.db ./app -H 0.0.0.0
