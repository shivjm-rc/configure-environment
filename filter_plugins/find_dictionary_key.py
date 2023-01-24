# from jinja2.exceptions import AnsibleFilterError


def find_dictionary_key(candidates, d):
    for c in candidates:
        v = d.get(c, None)

        if v != None:
            return c, v

    return None


class FilterModule(object):
    def filters(self):
        return {"find_dictionary_key": find_dictionary_key}
