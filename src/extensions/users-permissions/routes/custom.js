module.exports = {
  type: 'content-api',
  routes: [
    {
      method: 'POST',
      path: '/auth/local/register-with-invite',
      handler: 'auth.registerWithInvite',
      config: { auth: false }
    }
  ]
}; 