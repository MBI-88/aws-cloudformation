import express, { Request, Response } from 'express'
import path from 'path';
import swig from 'swig'

const app = express()
const port = 80

app.engine('html', swig.renderFile);
app.set('view engine', 'html');
app.set('views', path.join(__dirname, 'views'));


app.get("/", (req: Request, res: Response) => {
    res.render('index',{ip: req.ip})
})


app.listen(port, () => {
    console.log(`Server running on 0.0.0.0:${port} `)
})