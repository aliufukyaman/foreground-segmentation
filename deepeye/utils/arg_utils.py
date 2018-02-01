'''
arg_utils.py

Argument treatment utilities.
'''


def cast_arg(arg):
    '''
    Cast args to the correct type.

    @param arg argument to be casted.

    @return arg with the correctly parsed type.
    '''

    # Test each type
    try:
        # int
        return int(arg)
    except ValueError:
        pass
    try:
        # float
        return float(arg)
    except ValueError:
        pass
    if arg in ['True', 'False']:
        # boolean
        return arg == 'True'
    # A string
    return arg


def parse_kwparams(kwlst):
    '''
    Parses key-worded parameters.

    @param kwstr key-worded parameters list to be parsed.

    @return dictionary with the key-worded parameters.
    '''

    # Set in dictionary form
    kwparams = {}
    for param in kwlst:
        k, v = param.split('=')
        kwparams[k] = v
    return kwparams
