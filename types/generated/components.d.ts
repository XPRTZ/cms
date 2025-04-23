import type { Schema, Struct } from '@strapi/strapi';

export interface ElementsButton extends Struct.ComponentSchema {
  collectionName: 'components_elements_buttons';
  info: {
    description: '';
    displayName: 'Button';
    icon: 'link';
  };
  attributes: {
    page: Schema.Attribute.Relation<'oneToOne', 'api::page.page'>;
    title: Schema.Attribute.String & Schema.Attribute.Required;
    variant: Schema.Attribute.Enumeration<
      ['primary', 'secondary', 'button', 'link']
    >;
  };
}

export interface ElementsListItem extends Struct.ComponentSchema {
  collectionName: 'components_elements_list_items';
  info: {
    displayName: 'List Item';
    icon: 'bulletList';
  };
  attributes: {
    description: Schema.Attribute.String & Schema.Attribute.Required;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface ElementsListItemWithIcon extends Struct.ComponentSchema {
  collectionName: 'components_elements_list_item_with_icons';
  info: {
    displayName: 'List Item with Icon';
    icon: 'bulletList';
  };
  attributes: {
    description: Schema.Attribute.Text & Schema.Attribute.Required;
    image: Schema.Attribute.Media<'images'> & Schema.Attribute.Required;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface ElementsSocial extends Struct.ComponentSchema {
  collectionName: 'components_elements_socials';
  info: {
    displayName: 'Social';
    icon: 'heart';
  };
  attributes: {
    isEnabled: Schema.Attribute.Boolean &
      Schema.Attribute.Required &
      Schema.Attribute.DefaultTo<false>;
    link: Schema.Attribute.String & Schema.Attribute.Required;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface UiHero extends Struct.ComponentSchema {
  collectionName: 'components_ui_heroes';
  info: {
    description: '';
    displayName: 'Hero';
    icon: 'landscape';
  };
  attributes: {
    CTO: Schema.Attribute.Component<'elements.button', false>;
    description: Schema.Attribute.Text & Schema.Attribute.Required;
    images: Schema.Attribute.Media<'images', true> & Schema.Attribute.Required;
    link: Schema.Attribute.Component<'elements.button', false>;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface UiImage extends Struct.ComponentSchema {
  collectionName: 'components_ui_images';
  info: {
    description: '';
    displayName: 'Image';
    icon: 'landscape';
  };
  attributes: {
    image: Schema.Attribute.Media<'images'> & Schema.Attribute.Required;
  };
}

export interface UiImageMetTitel extends Struct.ComponentSchema {
  collectionName: 'components_ui_image_met_titels';
  info: {
    description: '';
    displayName: 'Image met titel';
    icon: 'landscape';
  };
  attributes: {
    description: Schema.Attribute.Text & Schema.Attribute.Required;
    image: Schema.Attribute.Media<'images'> & Schema.Attribute.Required;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface UiKernwaarden extends Struct.ComponentSchema {
  collectionName: 'components_ui_kernwaardens';
  info: {
    description: '';
    displayName: 'Kernwaarden';
    icon: 'star';
  };
  attributes: {
    description: Schema.Attribute.Text & Schema.Attribute.Required;
    items: Schema.Attribute.Component<'elements.list-item-with-icon', true> &
      Schema.Attribute.Required &
      Schema.Attribute.SetMinMax<
        {
          max: 5;
          min: 1;
        },
        number
      >;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface UiKlantLogoS extends Struct.ComponentSchema {
  collectionName: 'components_ui_klant_logo_s';
  info: {
    displayName: "Klant logo's";
    icon: 'chartCircle';
  };
  attributes: {
    klant: Schema.Attribute.Component<'elements.list-item-with-icon', true> &
      Schema.Attribute.Required &
      Schema.Attribute.SetMinMax<
        {
          max: 5;
          min: 1;
        },
        number
      >;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface UiMissieMetStatistieken extends Struct.ComponentSchema {
  collectionName: 'components_ui_missie_met_statistiekens';
  info: {
    description: '';
    displayName: 'Missie met statistieken';
    icon: 'apps';
  };
  attributes: {
    description: Schema.Attribute.Text & Schema.Attribute.Required;
    extraDescription: Schema.Attribute.Text & Schema.Attribute.Required;
    statistieken: Schema.Attribute.Component<'elements.list-item', true> &
      Schema.Attribute.Required &
      Schema.Attribute.SetMinMax<
        {
          max: 3;
          min: 1;
        },
        number
      >;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface UiTeam extends Struct.ComponentSchema {
  collectionName: 'components_ui_teams';
  info: {
    description: '';
    displayName: 'Team';
    icon: 'rocket';
  };
  attributes: {
    description: Schema.Attribute.Text & Schema.Attribute.Required;
    members: Schema.Attribute.Relation<'oneToMany', 'api::author.author'>;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'elements.button': ElementsButton;
      'elements.list-item': ElementsListItem;
      'elements.list-item-with-icon': ElementsListItemWithIcon;
      'elements.social': ElementsSocial;
      'ui.hero': UiHero;
      'ui.image': UiImage;
      'ui.image-met-titel': UiImageMetTitel;
      'ui.kernwaarden': UiKernwaarden;
      'ui.klant-logo-s': UiKlantLogoS;
      'ui.missie-met-statistieken': UiMissieMetStatistieken;
      'ui.team': UiTeam;
    }
  }
}
