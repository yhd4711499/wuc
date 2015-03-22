@Router.configure layoutTemplate: 'layout'

@Router.map ->
  # @route 'home', path: '/'
  @route 'join', path: '/join/:_id'
  @route 'new', path: '/new'
  @route 'games', path: '/'
  @route 'play', path: '/play/:_id'
  @route 'user', path: '/user'
  @route 'items', path: '/items'