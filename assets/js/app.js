// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "./vendor/some-package.js"
//
// Alternatively, you can `npm install some-package` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.Socket = Socket

// Code that connects to socket and retrieves messages

let socket = new Socket("/socket", { params: { token: "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJCU1BLIiwiY29tcGFueV9pZCI6IjciLCJleHAiOjE3MTgxMjYwMzYsImlhdCI6MTY1NzY0NjAzNiwiaXNzIjoiQlNQSyIsImp0aSI6ImEyZDIwMjA0LTk4NGEtNDUwNy1iNDhjLTQxMDFmY2ZlZTkwNCIsIm5iZiI6MTY1NzY0NjAzNSwic2FsZXNfYXNzb2NpYXRlX2lkIjoiMSIsInN0b3JlX2lkIjoiMyIsInN1YiI6IjEiLCJ0eXAiOiJhY2Nlc3MifQ.II2Htkvh2SABr4WoWELFGqi-s18FLYWxcVDh0jKtOeGiBv86o4g5EUQFzLbgN0bDUsOhaBn9rBfh7aO_RMA5rw" } })

socket.connect()

let channel = socket.channel("stream:companies:7", {})

let messagesContainer = document.querySelector("#messages")

channel.on("stream:messages", payload => {
  console.log(payload)
  let messageItem = document.createElement("p")
  messageItem.innerText = `[${Date()}] ${payload.body}`
  messagesContainer.prepend(messageItem)
})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })
