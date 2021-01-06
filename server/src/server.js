const express = require("express")
const morgan = require('morgan')
const bodyParser = require("body-parser")
const geohash = require('ngeohash')
const Influx = require("influx")
const config = require('./config')

const influx = new Influx.InfluxDB({
  host: config.influxHost,
  database: config.influxDatabase,
  username: config.influxUsername,
  password: config.influxPassword,
  schema: [{
    measurement: 'chowkidar_events',
    fields: {
      message: Influx.FieldType.STRING,
    },
    tags: [
      'chowkidar'
    ]
  }]
});

const app = express()
const PORT = 3030

app.use(bodyParser.json())
app.use(morgan('combined'))

app.post("/hook", (req, res) => {
  console.log(req.body);
  // influx.writePoints(
  //   [{
  //     measurement: "geossh",
  //     fields: {
  //       value: 1
  //     },
  //     tags: {
  //       geohash: geohash.encode(apiResponse.latitude, apiResponse.longitude),
  //       username: message.username,
  //       port: message.port,
  //       ip: message.ip
  //     }
  //   }]
  // );
  res.json({'acknowledged': 'true'})
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

