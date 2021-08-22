import css from '../css/app.css'

import { productSocket } from './socket'
import dom from './dom'
import Cart from './cart'

const productIds = dom.getProductIds()
productSocket.connect()
productIds.forEach((id) => setupProductChannel(productSocket, id))

const cartChannel = Cart.setupCartChannel(productSocket, window.cartId, {
  onCartChange: (newCart) => {
    dom.renderCartHtml(newCart)
  },
})

function setupProductChannel(socket, productId) {
  const productChannel = socket.channel(`product:${productId}`)
  productChannel.join().receive('error', () => {
    console.error('Channel join failed')
  })

  productChannel.on('released', ({ size_html }) => {
    dom.replaceProductComingSoon(productId, size_html)
  })

  productChannel.on('stock_change', ({ product_id, item_id, level }) => {
    dom.updateItemLevel(item_id, level)
  })
}
