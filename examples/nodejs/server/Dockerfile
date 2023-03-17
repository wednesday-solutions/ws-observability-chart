FROM node:19-alpine3.15
ARG ENVIRONMENT_NAME
ENV ENVIRONMENT_NAME $ENVIRONMENT_NAME
RUN mkdir -p /app-build
ADD . /app-build
WORKDIR /app-build
RUN yarn
CMD ["yarn", "start"]
EXPOSE 9000