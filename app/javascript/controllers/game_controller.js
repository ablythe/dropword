import { Controller } from "@hotwired/stimulus"
import { put } from "@rails/request.js"

export default class extends Controller {
  static values = { id: String }

  connect() {
    // setInterval(() => {
    //   this.advanceGame()
    // }, 5000)

    document.addEventListener("keydown", (e) => {
        // if (e.key === ) {
        //   this.pause()
        // }
        if (e.key === 'ArrowDown') {
          this.advanceGame('down')
        }
        if (e.key === 'ArrowRight') {
          this.advanceGame('right')
        }
        if (e.key === 'ArrowLeft') {
          this.advanceGame('left')
        }
        if (e.key === 'ArrowUp') {
          this.advanceGame('rotate')
        }
      })
  }


  advanceGame(move) {
    put(`/games/${this.idValue}/advance`, {body: {move}})
      .then(response => response.text)
      .then((html => this.element.innerHTML = html))
  }
}