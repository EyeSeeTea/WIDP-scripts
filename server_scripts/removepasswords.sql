update keyjsonvalue set jbvalue = jsonb_set(jbvalue, '{password}', '""', false)  where namespacekey like 'instances-%' and jbvalue ? 'password';

