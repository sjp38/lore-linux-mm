Subject: Memory Test Suite v0.0.2
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 28 Apr 2000 00:34:07 +0200
Message-ID: <yttitx3cgww.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi
        this version contains a bug-fix to two test and a new test for
        ipc operations.


Memory test suite v0.0.2
------------------------

This is the second version.

This intends to be a set of programs to test the memory management
system.  I am releasing this version with the idea of gather more
programs for the suite.  If you have some program to test the system,
please send it to me (quintela@fi.udc.es).

If you found values/combinations of tests for what the system
crash/Oops/whatever please report it to me.  Then I can include it in
the tests and the people who tune the MM system can test it next time.

This version has added support for ipc001 test and solved a couple of
bugs in mmap* tests.

Any comments/suggestions/code are welcome.

Thanks for your time,
        Juan Quintela
        quintela@fi.udc.es

The home of this package is:

http://carpanta.dc.fi.udc.es/~quintela/memtest/


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
 LocalWords:  Quintela
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
