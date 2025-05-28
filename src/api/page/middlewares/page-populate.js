'use strict';

/**
 * `page-populate` middleware
 */

const populate = {
  components: {
    on: {
      'ui.artikelen': {
        fields: ['title'],
      },
      'ui.text': {
        fields: ['content'],
      },
      'ui.page-image': {
        populate: {
          image: {
            fields: ['url', 'alternativeText'],
          },
        },
      },
      'ui.opsomming': {
        populate: {
          items: {
            fields: ['text'],
          },
        },
      },
      'ui.titel': {
        fields: ['title', 'content'],
      },
      'ui.quote': {
        fields: ['quote', 'name', 'jobTitle'],
      },
      'ui.directeuren': {
        populate: {
          directeuren: {
            populate: {
              avatar: {
                fields: ['url', 'alternativeText'],
              },
            },
          },
        },
      },
    },
  },
};

module.exports = (config, { strapi }) => {
  // Add your own logic here.
  return async (ctx, next) => {
    strapi.log.info('In page-populate middleware.');

    ctx.query.populate = populate;

    await next();
  };
};
