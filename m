Subject: Memtest suite 0.0.4
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 12 Sep 2000 02:43:14 +0200
Message-ID: <yttits2tp7h.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Memory test suite v0.0.4
------------------------

This intends to be a set of programs to test the memory management
system.  I am releasing this version with the idea of gather more
programs for the suite.  If you have some program to test the system,
please send it to me (quintela@fi.udc.es).

Thanks to Tom Hull and Arjan van de Ven for fixing the C++ warnings.

If you found values/combinations of tests for what the system
crash/Oops/whatever please report it to me.  Then I can include it in
the tests and the people who tune the MM system can test it next time.

This version has:
        An improved README
        new shm test
        removing several compilations warnings
        added Tests file
	Now RAMSIZE is a parameter that you can change at runtime
        	test <size in megabytes>  (this patch has been done by 
	        Marcelo Tosatti <marcelo@conectiva.com.br> and then
                extended by me)

I have been having requests for people for the Linux Test Project
<http://oss.sgi.com/projects/ltp/> about merging the two test suites,
comments about that are welcome.

Any comments/suggestions/code are welcome.

<help wanted>
If some C++, thread guru wants to change shm-stress to use something
more portable than <asm/bitops.h>, help is welcome.
</help wanted>

This tests can be made possible thanks to the collaboration of:
	Conectiva <http://www.conectiva.com/>
	LFCIA (my University group) <http://www.lfcia.org>
that kindly donated to me an SMP machine.

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
