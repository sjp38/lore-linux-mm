Message-ID: <3DA5306C.7B63584@scs.ch>
Date: Thu, 10 Oct 2002 09:46:52 +0200
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: Meaning of the dirty bit
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

While studying the follow_page() function (the version of the function that is in place since 2.4.4, i.e. with the write argument), I noticed, that for an address that
should be written to (i.e. write != 0), the function checks not only the writeable flag (with pte_write()), but also the dirty flag (with pte_dirty()) of the page
containing this address.
>From what I thought to understand from general paging theory, the dirty flag of a page is set, when its content in physical memory differs from its backing on the permanent
storage system (file or swap space). Based on this understanding I do not understand why it is necessary to check the dirty flag, in order to ensure that a page is writable
- what am I missing here?

Thanks in advance for any answers
with best regards
Martin Maletinsky

P.S. Pls. put me on cc: in your reply, since I am not on the mailing list.

--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
