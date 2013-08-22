scripts
=======

Just some random scripts I made in order to make my life easy.

Currently this is:

* atags:

  Intented to be a etags dropin actually usable for project like the
  Linux kernel and U-Boot.  It uses "nm" and "addr2line" tools (with
  ${CROSS_COMPILE}-prefix) to search for a function name inside a
  binary. Especially usefull if you don't know which one of the
  quazillion instances of i.e. "board_eth_init" are getting really called ;-)

* stacktrace:

  Basically the same idea, but to decode the stacktraces of kernel
  Oops messages to find the offending line. 
