import { Presence } from 'phoenix'
import adminCss from '../css/admin.css'
import css from '../css/app.css'
import { adminSocket } from './admin/socket'
import dom from './admin/dom'

adminSocket.connect()

const cartTracker = adminSocket.channel('admin:cart_tracker')
const presence = new Presence(cartTracker)
window.presence = presence

cartTracker.join().receive('error', () => {
  console.error('Channel join failed')
})
