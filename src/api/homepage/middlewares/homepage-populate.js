'use strict';

/**
 * `homepage-populate` middleware
 */

const populate = {
  components: {
    on: {
      "ui.hero": {
        populate: {
          CTO: {
            populate: {
              page: {
                fields: ['title_website', 'slug']
              }
            }
          },
          link: {
            populate: '*'
          },
          images: {
            fields: ['url', 'alternativeText']
          }
        }
      },
      "ui.missie-met-statistieken": {
          populate: '*'
      },
    }
  }
}

module.exports = (config, { strapi }) => {
  // Add your own logic here.
  return async (ctx, next) => {
    strapi.log.info('In homepage-populate middleware.');

    ctx.query.populate = populate;

    await next();
  };
};
