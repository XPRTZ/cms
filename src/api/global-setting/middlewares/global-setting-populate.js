'use strict';

/**
 * `global-setting-populate` middleware
 */

const populate = {
  createdBy: true,
  updatedBy: true,
  pages: {
    fields: ['title_website', 'slug']
  },
  algemeneVoorwaarden: {
    fields: ['url'],
  },
  socials: {
    populate: {
      icon: {
        fields: ['url'],
      },
    },
  }
}


module.exports = (config, { strapi }) => {
  return async (ctx, next) => {
    strapi.log.info('In global-setting-populate middleware.');
    ctx.query.populate = populate;

    await next();
  };
};
