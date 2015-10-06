# -*- coding: utf-8 -*-
'''
Module for handling Heat stacks.

:depends:   - python-heatclient>=0.2.3 Python module
:configuration: This module is not usable until the following are specified
    either in a pillar or in the minion's config file::

        keystone.user: admin
        keystone.password: verybadpass
        keystone.tenant: admin
        keystone.tenant_id: f80919baedab48ec8931f200c65a50df
        keystone.insecure: False   #(optional)
        keystone.auth_url: 'http://127.0.0.1:5000/v2.0/'

    If configuration for multiple openstack accounts is required, they can be
    set up as different configuration profiles:
    For example::

        openstack1:
          keystone.user: admin
          keystone.password: verybadpass
          keystone.tenant: admin
          keystone.tenant_id: f80919baedab48ec8931f200c65a50df
          keystone.auth_url: 'http://127.0.0.1:5000/v2.0/'

        openstack2:
          keystone.user: admin
          keystone.password: verybadpass
          keystone.tenant: admin
          keystone.tenant_id: f80919baedab48ec8931f200c65a50df
          keystone.auth_url: 'http://127.0.0.2:5000/v2.0/'

    With this configuration in place, any of the heat functions can make
    use of a configuration profile by declaring it explicitly.
    For example::

        salt '*' heat.stack_list profile=openstack1

'''

from __future__ import absolute_import
import logging
LOG = logging.getLogger(__name__)

# Import third party libs
HAS_HEAT = False
try:
    from heatclient.v1 import client
    HAS_HEAT = True
except Exception, e:
    LOG.trace("heatclient or keystone is not installed %s" % e)

import json
import glob
from os.path import basename
from yaml import load, dump

HEAT_ROOT = "/srv/heat/env"

TEMPLATE_PATH = "template"
ENV_PATH ="env"

HOT = ".hot"
ENV = ".env"

HOT_MASK = "*%s" % HOT
ENV_MASK = "*%s" % ENV


def _autheticate(func_name):
    '''
    Authenticate requests with the salt keystone module and format return data
    '''
    @wraps(func_name)
    def decorator_method(*args, **kwargs):
        '''
        Authenticate request and format return data
        '''
        connection_args = {'profile': kwargs.get('profile', None)}
        nkwargs = {}
        for kwarg in kwargs:
            if 'connection_' in kwarg:
                connection_args.update({kwarg: kwargs[kwarg]})
            elif '__' not in kwarg:
                nkwargs.update({kwarg: kwargs[kwarg]})
        kstone = __salt__['keystone.auth'](**connection_args)
        token = kstone.auth_token
        endpoint = kstone.service_catalog.url_for(
            service_type='orchestration',
            endpoint_type='publicURL')
        heat_interface = client.Client(
            endpoint_url=endpoint, token=token)
        return_data = func_name(heat_interface, *args, **nkwargs)
        if isinstance(return_data, list):
            # format list as a dict for rendering
            return {data.get('name', None) or data['id']: data
                    for data in return_data}
        return return_data
    return decorator_method


def _filename(path):
    """
    helper
    return filename without extension
    """
    return basename(path).split(".")[0]


def _get_templates(choices=True):
    """
    if choices is False return array of full path
    """

    path = "/".join([HEAT_ROOT, TEMPLATE_PATH])
    
    templates = []

    for path in glob.glob("/".join([path, HOT_MASK])):
        name = filename(path)
        templates.append((name, name.replace("_", " ").capitalize()))

    return sorted(templates)


def _get_environments(template_name=None):
    """return environments choices
    """
    path = "/".join([HEAT_ROOT, ENV_PATH])

    environments = []

    if template_name:
        join = [path, template_name, ENV_MASK]
    else:
        join = [path, ENV_MASK]

    for path in glob.glob("/".join(join)):
        name = filename(path)        
        environments.append((name, name.replace("_", " ").capitalize()))

    return sorted(environments)


def _get_template_data(name):
    """
    load and return template data
    """

    path = "/".join([
        HEAT_ROOT,
        TEMPLATE_PATH,
        "".join([name, HOT])
        ])

    try:
        f = open(path, 'r')
        data = load(f)
    except Exception, e:
        raise e

    return data


def _get_environment_data(template_name, name):
    """
    load and return parameters data
    """

    path = "/".join([
        HEAT_ROOT,
        ENV_PATH,
        template_name,
        "".join([name, ENV])
        ])

    try:
        f = open(path, 'r')
        data = load(f)
    except Exception, e:
        raise e

    return data


def __virtual__():
    '''
    Only load this module if Heat
    is installed on this minion.
    '''
    if HAS_HEAT:
        return 'heat'
    return False

__opts__ = {}


def stack_list(tenant=None, **kwargs):
    
    heat = heatclient()

    ret = {}
    ret["result"] = heat.stacks.list()

    return ret


def stack_create(template, environment=None, name=None, parameters=None, timeout_mins=5,
                 enable_rollback=True, **kwargs):
    '''
    Return a specific endpoint (gitlab endpoint-get)

    :params template: template name
    :params name: if not provided template will be used

    CLI Example:

    .. code-block:: bash

        salt '*' heat.stack_create template_name
    '''

    heat = heatclient()

    # get template

    template_data = get_template_data(template)

    # Validate the template and get back the params.
    kwargs = {}
    kwargs['template'] = str(json.dumps(template_data, cls=CustomEncoder))

    try:
        validated = heat.stacks.validate(**kwargs)
    except Exception as e:
        LOG.error("Template not valid %s" % e)

    fields = {
        'stack_name': name,
        'template': json.dumps(template_data, cls=CustomEncoder),
        'environment': parameters,
        'parameters': parameters,
        'timeout_mins': timeout_mins,
        'disable_rollback': enable_rollback,
    }
    #LOG.debug(dir(heat))
    
    heat.stacks.create(**fields)
    
    return {'status': result}


def stack_delete(template, name=None, parameters=None, **kwargs):

    return {'Error': 'Could not delete stack.'}

