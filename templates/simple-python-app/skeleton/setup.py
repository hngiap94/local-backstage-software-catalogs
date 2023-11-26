from distutils.core import setup 

setup( 
	name='${{ values.application_name }}', 
	version='0.1', 
	description='${{ values.description }}', 
	author='${{ values.author }}',
    {% if values.authorEmail %}
	author_email='${{ values.authorEmail }}', 
    {% endif %}
	packages=['${{ values.application_name }}']
) 
