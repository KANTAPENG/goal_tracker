import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: "[data-drag-handle]",
      onEnd: () => {
        this.updateOrder()
      }
    })
  }

  updateOrder() {
    const ids = [...this.element.querySelectorAll("[data-id]")]
      .map((el) => el.dataset.id)

    fetch("/subtasks/reorder", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ order: ids })
    })
  }
}

