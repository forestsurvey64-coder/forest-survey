export const CopyToClipboard = {
  mounted() {
    this.el.addEventListener("click", () => {
      const url = this.el.dataset.url;
      navigator.clipboard.writeText(url).then(() => {
        const original = this.el.textContent;
        this.el.textContent = "¡Copiado!";
        setTimeout(() => {
          this.el.textContent = original;
        }, 2000);
      });
    });
  }
};
