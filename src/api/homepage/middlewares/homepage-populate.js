'use strict';

/**
 * `homepage-populate` middleware
 */

const populate = {
  createdBy: true,
  updatedBy: true,
  components: {
    on: {
      'ui.hero': {
        populate: {
          CTO: {
            populate: {
              page: {
                fields: ['title_website', 'slug'],
              },
            },
          },
          link: {
            populate: '*',
          },
          images: {
            fields: ['url', 'alternativeText'],
          },
        },
      },
      'ui.missie-met-statistieken': {
        populate: '*',
      },
      'ui.image': {
        populate: {
          image: {
            fields: ['url', 'alternativeText'],
          },
        },
      },
      'ui.image-met-titel': {
        populate: {
          image: {
            fields: ['url', 'alternativeText'],
          },
        },
      },
      'ui.kernwaarden': {
        populate: {
          items: {
            populate: {
              image: {
                fields: ['url', 'alternativeText'],
              },
            },
          },
        },
      },
      'ui.klant-logo-s': {
        populate: {
          klant: {
            populate: {
              image: {
                fields: ['url', 'alternativeText'],
              },
            },
          },
        },
      },
      'ui.team': {
        populate: {
          members: {
            populate: {
              avatar: {
                fields: ['url', 'alternativeText'],
              },
            },
          },
        },
      },
      'ui.artikelen-overzicht': {
        fields: ['title', 'description'],
      },
    },
  },
};

module.exports = (config, { strapi }) => {
  return async (ctx, next) => {
    strapi.log.info('In homepage-populate middleware.');

    ctx.query.populate = populate;

    await next();
  };
};
