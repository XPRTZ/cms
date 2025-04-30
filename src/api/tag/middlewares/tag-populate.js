'use strict';

/**
 * `tag-populate` middleware
 */

const populate = {
  createdBy: true,
  updatedBy: true
}

module.exports = (config, { strapi }) => {
  // Add your own logic here.
  return async (ctx, next) => {
    strapi.log.info('In tag-populate middleware.');

    ctx.query.populate = populate;

    await next();
  };
};
