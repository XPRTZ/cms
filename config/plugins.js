module.exports = ({ env }) => ({
  email: {
    config: {
      provider: 'strapi-provider-email-azure',
      providerOptions: {
        endpoint: env('AZURE_ENDPOINT'),
      },
      settings: {
        defaultFrom: env('FALLBACK_EMAIL'),
      },
    },
  },
  upload: {
    config: {
      provider: 'aws-s3',
      providerOptions: {
        credentials: {
          accessKeyId: env('MINIO_ACCESS_KEY'),
          secretAccessKey: env('MINIO_SECRET_KEY'),
        },
        region: 'eu-central-1',
        baseUrl: `http://localhost:9000/${env('MINIO_BUCKET')}`,
        endpoint: env('MINIO_ENDPOINT'),
        params: {
          Bucket: env('MINIO_BUCKET'),
        },
      },
    },
  },
});
