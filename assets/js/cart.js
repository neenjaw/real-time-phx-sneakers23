const Cart = {}

export default Cart

Cart.setupCartChannel = (socket, cartId, { onCartChange }) => {
  const cartChannel = socket.channel(`cart:${cartId}`, channelParams)
  const onCartChangeFn = (cart) => {
    console.debug('Cart received', cart)
    localStorage.storedCart = cart.serialized
    onCartChange(cart)
  }

  cartChannel.on('cart', onCartChangeFn)
  cartChannel.join().receive('error', () => {
    console.error('Cart join failed')
  })

  return { cartChannel, onCartChange: onCartChangeFn }
}

function channelParams() {
  return {
    serialized: localStorage.storedCart,
  }
}
