import { Socket } from "phoenix"

const socket = new Socket("/socket", {})

socket.connect()

const channel = socket.channel("ping")

channel.join()
  .receive("ok", (resp) => { console.log("Joined ping", resp) })
  .receive("error", (resp) => { console.log("Unable to join ping", resp) })

console.log("send ping")

channel.push("ping", {})
  .receive("ok", (resp) => console.log("receive", resp.ping))

console.log("send pong")

channel.push("pong", {})
  .receive("ok", (resp) => console.log("won't happen"))
  .receive("error", (resp) => console.error("won't happen yet"))
  .receive("timeout", (resp) => console.error("pong message timeout", resp))

channel.push("param_ping", { error: true })
  .receive("error", (resp) => console.error("param_ping error:", resp))
channel.push("param_ping", { error: false, arr: [1, 2] })
  .receive("ok", (resp) => console.log("param_ping ok:", resp))

channel.on("send_ping", (payload) => {
  console.log("ping requested", payload)
  channel.push("ping", {})
    .receive("ok", (resp) => console.log("ping:", resp.ping))
})

channel.push("invalid", {})
  .receive("ok", (resp) => console.log("won't happen"))
  .receive("error", (resp) => console.error("won't happen"))
  .receive("timeout", (resp) => console.error("invalid event timeout"))

export default socket