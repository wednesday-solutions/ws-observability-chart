const express = require("express");
const Prometheus = require("prom-client");
const httpRequestDurationMicroseconds = new Prometheus.Histogram({
  name: "http_request_duration_ms",
  help: "Duration of HTTP requests in ms",
  labelNames: ["method", "route", "status"],
  // buckets for response time from 0.1ms to 500ms
  buckets: [0.1, 5, 15, 50, 100, 200, 300, 400, 500],
});

const app = express();
app.use((req, res, next) => {
  console.log("middleware ");
  res.locals.startEpoch = Date.now();
  next();
});
app.get("/", function (req, res, next) {
  console.log("health check API called");

  setTimeout(() => {
    res.send({ data: "ok - minikube1" }).status(200);
    return next();
  }, Math.random() * 1000);
});

// Metrics endpoint
app.get("/metrics", async (req, res, next) => {
  console.log("metrics-------");
  const metrics = await Prometheus.register.metrics();
  res.set("Content-Type", Prometheus.register.contentType);
  res.end(metrics);
  next();
});

app.get("/test", async () => {
  console.log("metrics-------");
  const metrics = await Prometheus.register.metrics();
  res.set("Content-Type", Prometheus.register.contentType);
  res.end(metrics);
  next();
});

app.use(function middleware1(req, res, nex) {
  console.log("Inside middleware1");
  nex();
});

app.use(function middleware2(req, res, nex) {
  console.log("Inside middleware2");
  nex();
});

app.use(function middleware3(req, res, nex) {
  console.log("Inside middleware3");
  nex();
});

app.post("/eks", (req, res, next) => {
  for (let i = 0; i < 1000000; i++) {}
  res.json({ message: "Jaegar testing" });
});

app.use((req, res, next) => {
  // console.log("observing", req, res);
  const responseTimeInMs = Date.now() - res.locals.startEpoch;
  httpRequestDurationMicroseconds
    .labels(req.method, req.path, res.statusCode)
    .observe(responseTimeInMs);

  next();
});
app.listen(9000, function () {
  console.log("server is listening on 9000");
});

