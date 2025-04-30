export default {
  bootstrap(/* app: StrapiApp */) {
    // Remove once https://github.com/strapi/strapi/issues/23358 is fixed
    const style = document.createElement("style")
    style.textContent = `
    [role="dialog"] [data-radix-scroll-area-viewport] [role="tabpanel"] > div > div:last-child {
      position: relative;
      z-index: 1;
    }`
    document.head.appendChild(style)
  },
}
