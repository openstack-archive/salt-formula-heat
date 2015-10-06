# -*- coding: utf-8 -*-
'''
Management of Heat stacks
==============================

:depends:   - python-heatclient>=0.2.3 Python module
:configuration: See :py:mod:`salt.modules.heat` for setup instructions.

.. code-block:: yaml
    
    heat.keystone_endpoint: 'http://icehouse.cloudlab.cz:5000/v2.0'
    heat.url: 'http://10.0.106.19:8004/v1/fc015a00cda344e9b66e3d99e0a0591a'
    heat.username: 'admin'
    heat.tenant_id: 'fc015a00cda344e9b66e3d99e0a0591a'
    heat.password: 'cloudlab'

'''

def __virtual__():
    '''
    Only load if the gitlab module is in __salt__
    '''
    return 'heat' if 'python-heatclient' in __salt__ else False


def stack_absent(name):

    pass

def stack_present(name, template_file=None, environment_file=None):
    ''''
    Enforces stack

    :param:name: The name of the stack to create
    :param:template_file: Template file
    '''

    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Stack "{0}" already exists'.format(name)}

    # Create project
    __salt__['gitlab.project_create'](name, description, enabled,
                                       profile=profile,
                                       **connection_args)
    ret['comment'] = 'Tenant "{0}" has been added'.format(name)
    ret['changes']['Tenant'] = 'Created'

    return ret
