import type { Schema, Struct } from '@strapi/strapi';

export interface ElementsButton extends Struct.ComponentSchema {
  collectionName: 'components_elements_buttons';
  info: {
    displayName: 'Button';
    icon: 'link';
  };
  attributes: {
    href: Schema.Attribute.Text & Schema.Attribute.Required;
    title: Schema.Attribute.String & Schema.Attribute.Required;
    variant: Schema.Attribute.Enumeration<['primary', 'secondary']>;
  };
}

export interface UiHero extends Struct.ComponentSchema {
  collectionName: 'components_ui_heroes';
  info: {
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

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'elements.button': ElementsButton;
      'ui.hero': UiHero;
    }
  }
}
