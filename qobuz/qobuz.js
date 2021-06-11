const puppeteer = require('puppeteer-core');
const http = require("http");
const fs = require('fs');

const port = 9223;
const host = "localhost";

const playButtonSelector = ".player__action-play";
const pauseButtonSelector = ".player__action-pause";
const nextButtonSelector = ".player__action-next";
const prevButtonSelector = ".player__action-prev";

// Convert a time such as 'hh:mm:ss' or 'mm:ss' or 'ss' to seconds
function timeToSeconds(time) {
    var seconds=0;
    splited = time.split(':').reverse().map(a => parseInt(a))
    for (let i = 0; i < splited.length; i++) {
        seconds += splited[i] * 60**i
    }
    return seconds
}

function webServer(qobuzPage) {
    const requestListener = async function (req, res) {
        switch (req.url) {
        case "/toggle":
            res.writeHead(200);
            const playing = await qobuzPage.$(playButtonSelector).catch(() => null);
            if (playing != null) {
                qobuzPage.click(playButtonSelector);
                res.end("play");
            } else {
                qobuzPage.click(pauseButtonSelector);
                res.end("pause");
            }
            break
        case "/next":
            res.writeHead(200);
            qobuzPage.click(nextButtonSelector);
            res.end("next");
            break
        case "/prev":
            res.writeHead(200);
            qobuzPage.click(prevButtonSelector);
            res.end("prev");
            break
        default:
            res.writeHead(404);
            res.end("Resource not found");
        };
    };

    const server = http.createServer(requestListener);
    server.listen(port, host, () => {
        console.log(`Server is running on http://${host}:${port}`);
    });
}

var previousLog = {}

function log(page){
    (async () => {
        const play = await page.$(".player__action-play");
        const playerStatus = play == null ? "playing" : "stopped"
        const artist = await page.$(".player__track-album > a:nth-child(1)")
        const artistText = await page.evaluate(artist => artist.textContent, artist);
        const album = await page.$(".player__track-album > a:nth-child(3)");
        const albumText = await page.evaluate(album => album.textContent, album);
        const track = await page.$(".player__track-overflow");
        const trackText = await page.evaluate(track => track.textContent, track);
        const time = await page.$("span.player__track-time-text:nth-child(1)");
        const timeText = await page.evaluate(time => time.textContent, time);
        const duration = await page.$("span.player__track-time-text:nth-child(3)");
        const durationText = await page.evaluate(e => e.textContent, duration);

        currentLog = {
            // Date.now returns milliseconds from epoch
            date: Math.floor(Date.now()/1000),
            status: playerStatus,
            album: albumText,
            artist: artistText,
            time: timeToSeconds(timeText),
            track: trackText,
            duration: timeToSeconds(durationText),
            source: "qobuz",
        }
        if (currentLog.status != previousLog.status ||
            currentLog.album != previousLog.album ||
            currentLog.track != previousLog.track ||
            currentLog.artist != previousLog.artist) {
            json = JSON.stringify(currentLog);
            console.log(json);

            fs.appendFileSync('/home/lewo/Documents/music.log', json + "\n");

        }
        previousLog = currentLog;
    })()
}

(async () => {
    const browser = await puppeteer.connect({
        browserURL: "http://localhost:9222",
        defaultViewport: null});
    const pages = await browser.pages();
    console.log("List of tabs:")
    pages.forEach(function(page, index, array) {
        console.log("  ", page._target._targetInfo.url)
    })
    const page = pages.find(page => page._target._targetInfo.url.startsWith("https://play.qobuz.com"));

    await webServer(page);
    
    setInterval(() => log(page), 1000);
})();
