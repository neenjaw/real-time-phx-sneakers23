import { getCartHtml } from './cartRenderer'

const dom = {}

function getProductIds() {
  const products = document.querySelectorAll('.product-listing')
  return Array.from(products).map((el) => el.dataset.productId)
}
dom.getProductIds = getProductIds

function replaceProductComingSoon(productId, sizeHtml) {
  const name = `.product-soon-${productId}`
  const productSoonEls = document.querySelectorAll(name)

  productSoonEls.forEach((el) => {
    const fragment = document.createRange().createContextualFragment(sizeHtml)
    el.replaceWith(fragment)
  })
}
dom.replaceProductComingSoon = replaceProductComingSoon

function updateItemLevel(itemId, level) {
  Array.from(document.querySelectorAll('.size-container__entry'))
    .filter((el) => el.value == itemId)
    .forEach((el) => {
      removeStockLevelClasses(el)
      el.classList.add(`size-container__entry--level-${level}`)
      el.disabled = level === 'out'
    })
}
dom.updateItemLevel = updateItemLevel

dom.renderCartHtml = (cart) => {
  const cartContainer = document.getElementById('cart-container')
  cartContainer.innerHTML = getCartHtml(cart)
}

dom.onItemClick = (fn) => {
  document.addEventListener('click', (event) => {
    if (!event.target.matches('.size-container__entry')) {
      return
    }
    event.preventDefault()
    fn(event.target.value)
  })
}

dom.onItemRemoveClick = (fn) => {
  document.addEventListener('click', (event) => {
    if (!event.target.matches('.cart-item__remove')) {
      return
    }
    event.preventDefault()
    fn(event.target.dataset.itemId)
  })
}

function removeStockLevelClasses(el) {
  Array.from(el.classList)
    .filter((s) => s.startsWith('size-container__entry--level-'))
    .forEach((name) => el.classList.remove(name))
}

export default dom
