'use strict';

const { createCoreRouter } = require('@strapi/strapi').factories;

module.exports = createCoreRouter('api::global-setting.global-setting', {
  config: {
    find: {
      middlewares: ['api::global-setting.global-setting-populate'],
    },
  },
});
