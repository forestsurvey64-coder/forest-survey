import TomSelect from "tom-select"

const TomSelectHook = {
  mounted() {
    const event = this.el.dataset.event
    const key = this.el.dataset.key

    this.ts = new TomSelect(this.el, {
      create: false,
      plugins: [],
    })

    this.ts.on("change", (value) => {
      this.pushEvent(event, { [key]: value })
    })
  },

  destroyed() {
    this.ts?.destroy()
  },
}

export default TomSelectHook
