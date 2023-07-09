APP_NAME=cli
docker build -t ${APP_NAME}-loongarch64 .
docker run --rm -v "$(pwd)"/dist:/dist ${APP_NAME}-loongarch64
ls -al "$(pwd)"/dist