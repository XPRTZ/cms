'use strict';

/**
 * tag router
 */

const { createCoreRouter } = require('@strapi/strapi').factories;

module.exports = createCoreRouter('api::tag.tag', {
  config: {
    find: {
      middlewares: ['api::tag.tag-populate'],
    },
    findOne: {
      middlewares: ['api::tag.tag-populate'],
    },
  },
});
