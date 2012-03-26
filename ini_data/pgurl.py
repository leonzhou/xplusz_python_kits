import os, sys, urlparse

def get_db_settings():
    urlparse.uses_netloc.append('postgres')
    urlparse.uses_netloc.append('mysql')
    try:
        dbs = dict()
        if os.environ.has_key('DATABASE_URL'):
            url = urlparse.urlparse(os.environ['DATABASE_URL'])
            dbs['default'] = {
                'NAME':     url.path[1:],
                'USER':     url.username,
                'PASSWORD': url.password,
                'HOST':     url.hostname,
                'PORT':     url.port,
            }
            if url.scheme == 'postgres':
                dbs['default']['ENGINE'] = 'django.db.backends.postgresql_psycopg2'
            if url.scheme == 'mysql':
                dbs['default']['ENGINE'] = 'django.db.backends.mysql'
        else:
            dbs['default'] = {
                'NAME': 'app_name',
                'USER': 'app_name',
                'PASSWORD': 'app_name',
                'HOST': 'localhost',
                'PORT': '',
            }
            dbs['default']['ENGINE'] = 'django.db.backends.postgresql_psycopg2'
        return dbs
    except:
        print "Unexpected error:", sys.exc_info()
