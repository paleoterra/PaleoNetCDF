/*
 * $Id: ncio.c,v 1.1 2003/03/17 17:09:54 tmoore Exp $
 */

#if defined(_CRAY)
#   include "ffio.c"
#else
#   include "posixio.c"
#endif
