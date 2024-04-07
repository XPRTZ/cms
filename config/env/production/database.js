module.exports =  ({ env }) => ({
	connection: {
		client: 'postgres',
		connection: {
		host: env('POSTGRES_HOST', 'localhost'),
			port: env.int('POSTGRES_PORT', 5432),
			database: env('POSTGRES_DATABASE', 'strapi'),
			user: env('POSTGRES_USERNAME', 'strapi'),
			password: env('POSTGRES_PASSWORD', 'strapi'),
			ssl: env.bool('POSTGRES_SSL', false)
		}
	}
});
/*
POSTGRES_HOST=pgsql-xprtzbv-cms
POSTGRES_PORT=5432
POSTGRES_DATABASE=postgres
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=n8wvwh8dngApLj6zxMQFTGBX7QLT7QuO00Zkewho
POSTGRES_SSL=disable
POSTGRES_CONNECTION_STRING=host=pgsql-xprtzbv-cms database=postgres user=postgres password=n8wvwh8dngApLj6zxMQFTGBX7QLT7QuO00Zkewho
POSTGRES_URL=postgres://postgres:n8wvwh8dngApLj6zxMQFTGBX7QLT7QuO00Zkewho@pgsql-xprtzbv-cms:5432/postgres?sslmode=disable

PGSQL_XPRTZBV_CMS_POSTGRES_HOST=pgsql-xprtzbv-cms
PGSQL_XPRTZBV_CMS_POSTGRES_PORT=5432
PGSQL_XPRTZBV_CMS_POSTGRES_DATABASE=postgres
PGSQL_XPRTZBV_CMS_POSTGRES_USERNAME=postgres
PGSQL_XPRTZBV_CMS_POSTGRES_PASSWORD=n8wvwh8dngApLj6zxMQFTGBX7QLT7QuO00Zkewho
PGSQL_XPRTZBV_CMS_POSTGRES_SSL=disable
PGSQL_XPRTZBV_CMS_POSTGRES_CONNECTION_STRING=host=pgsql-xprtzbv-cms database=postgres user=postgres password=n8wvwh8dngApLj6zxMQFTGBX7QLT7QuO00Zkewho
PGSQL_XPRTZBV_CMS_POSTGRES_URL=postgres://postgres:n8wvwh8dngApLj6zxMQFTGBX7QLT7QuO00Zkewho@pgsql-xprtzbv-cms:5432/postgres?sslmode=disable
*/
