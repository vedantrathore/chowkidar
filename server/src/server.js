const express = require("express")
const bodyParser = require("body-parser")

const app = express()
const PORT = 3030

app.use(bodyParser.json())


app.use(bodyParser.json())

app.post("/hook", (req, res) => {
  console.log(req.body) 
  res.status(200).end() 
})

app.listen(PORT, () => console.log(`🚀 Server running on port http://localhost:${PORT}`))