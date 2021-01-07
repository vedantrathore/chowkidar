const express = require("express")
const morgan = require('morgan')
const bodyParser = require("body-parser")
const geohash = require('ngeohash')
const axios = require('axios')
const Influx = require("influx")
const config = require('./config')

const influx = new Influx.InfluxDB({
  host: config.influxHost,
  database: config.influxDatabase,
  username: config.influxUsername,
  password: config.influxPassword,
});

const app = express()
const PORT = 3030

app.use(bodyParser.json())
app.use(morgan('combined'))

app.post("/hook", (req, res) => {
  const { ip, time, message } = req.body;
  if (message.remote_ip.length == 0) {
    res.json({ 'acknowledged': 'true' })
    return;
  }
  const instance = axios.create({
            baseURL: "http://api.ipstack.com"
        });
        instance
            .get(`/${message.remote_ip}?access_key=${config.ipStackAccessKey}`)
            .then(function(response) {
                const apiResponse = response.data;
                influx.writePoints(
                    [{
                        measurement: "chowkidar_events",
                        fields: {
                          remote_ip: message.remote_ip,
                          remote_port: message.remote_port,
                          user: message.user,
                          connection: message.type == 'connected' ? 1 : 0,
                          authentication_method: message.connection_type === '' ? 'publickey' : message.connection_type,
                        },
                        tags: {
                          ip: ip,
                          pid: message.pid,
                          host: message.host,
                          type: message.type,
                          connection_type: message.connection_type === '' ? 'publickey' : message.connection_type,
                          value: message.type == 'connected' ? 1 : 0,
                          geohash: geohash.encode(apiResponse.latitude, apiResponse.longitude),
                        }
                    }]
                    );
                console.log("Intruder added")
            })
            .catch(function(error) {
                console.log(error);
            });
  res.json({ 'acknowledged': 'true' })
})

influx.getDatabaseNames()
  .then(names => {
    if (!names.includes(config.influxDatabase)) {
      return influx.createDatabase(config.influxDatabase);
    }
  })
  .then(() => {
    app.listen(PORT, () => console.log(`🚀 Server running on port http://localhost:${PORT}`))
  })
  .catch(err => {
    console.error(`Error creating Influx database! :${err}`);
  })

