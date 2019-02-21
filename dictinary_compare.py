#!/bin/env python
from ansible.module_utils.basic import *
import os, json
import re, sys
KEYNOTFOUND = 'DEPLOY'       # KeyNotFound for dictDiff


def dict_diff(src, dest):
    diff = {}
    # Check all keys in src dict
    for key in src.keys():
        if (not dest.has_key(key)):
            diff[key] = (src[key], KEYNOTFOUND)
        elif (src[key] != dest[key]):
            if src[key] > dest[key]:
                diff[key] = (src[key], KEYNOTFOUND )
            else:
                diff[key] = (src[key], dest[key] )
    # Check all keys in dest dict to find missing
    return diff


if __name__ == '__main__':
  fields = {
  "src1": {"required": True, "type": "str"},
  "dest1": {"required": True, "type": "str"}
  }
  module = AnsibleModule(argument_spec=fields)
  src = os.path.expanduser(module.params['src1'])
  dest = os.path.expanduser(module.params['dest1'])
  newName = dict_diff(src, dest)
  module.exit_json(msg=newName)


#src = sys.argv[1]
#dest = sys.argv[2]
#data1=json.loads(src)
#data2=json.loads(dest)


#data = dict_diff(data1,data2)
#print data
