Message-ID: <3C63989D.5D973803@scs.ch>
Date: Fri, 08 Feb 2002 10:21:33 +0100
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: addresses returned by __get_free_pages()
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

In the 2.4.x kernel, can I apply the virt_to_page() macro to any address allocated by __get_free_pages() (i.e. when calling ret = __get_free_pages(flags, order), to any
address in the interval [retval,  2^order * PAGE_SIZE])?

In other words are those addresses guaranteed to be kernel logical addresses (i.e. between PAGE_OFFSET and PAGE_OFFSET + high_memory (on ix86))?

I know that in the 2.2.x kernel this used to be the case (i.e. __get_free_pages() returned kernel
logical addresses, to which virt_to_page() could be applied), but I don't quite understand the
memory managment of 2.4.x yet.

Thanks in advance for any help
regards
Martin


--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
