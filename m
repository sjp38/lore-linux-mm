Subject: Memtest suite v0.0.3
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 29 Apr 2000 02:25:11 +0200
Message-ID: <yttr9bpbvo8.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vgers.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi
        new version of memtest suite.  If you have any more tests they
        are welcome.

Later, Juan.

Memory test suite v0.0.3
------------------------

This intends to be a set of programs to test the memory management
system.  I am releasing this version with the idea of gather more
programs for the suite.  If you have some program to test the system,
please send it to me (quintela@fi.udc.es).

If you found values/combinations of tests for what the system
crash/Oops/whatever please report it to me.  Then I can include it in
the tests and the people who tune the MM system can test it next time.

This version has:
        An improved README
        new shm test
        removing several compilations warnings
        added Tests file

Any comments/suggestions/code are welcome.

Note:  I am not a C++ programmer, if somebody knows how to remove the
       warnings in the c++ test (shm-stresser) I will be grateful.


Thanks for your time,
        Juan Quintela
        quintela@fi.udc.es

The home of this package is:

http://carpanta.dc.fi.udc.es/~quintela/memtest/


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
