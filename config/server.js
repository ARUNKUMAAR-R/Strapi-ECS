module.exports = ({ env }) => ({
  host: env('HOST', '0.0.0.0'),
  port: env.int('PORT', 1337),
  app: {
    keys: ['17eb64b24507b14aeaba36af8b006b5f625616d71cb960ee708339c087f212a3', '325386aa3b6dc9f4649e81f2a19d99c723bd84056620531f37a5dc1f537f061a'],
  },
  webhooks: {
    populateRelations: env.bool('WEBHOOKS_POPULATE_RELATIONS', false),
  },
});
