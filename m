Received: from scs.ch (nutshell.scs.ch [172.18.1.10])
	by mail.scs.ch (8.11.6/8.11.6) with ESMTP id fBA8rQV17038
	for <linux-mm@kvack.org>; Mon, 10 Dec 2001 09:53:26 +0100
Message-ID: <3C147805.99B2EE4A@scs.ch>
Date: Mon, 10 Dec 2001 09:53:25 +0100
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: how has set_pgdir been replaced in 2.4.x
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

In the 2.2.x Linux kernel there used to be a function set_pgdir(), in charge of keeping all page global directories consistent. I.e. when modifying the kernel page tables
(e.g. in vmalloc, or ioremap), set_pgdir() was called, to update the corresponding entry in any processes global page directory, as well as in the cached global page
directories.

I noticed that in the 2.4.x Linux kernel the function set_pgdir() has gone (at least for most platforms). When looking at code that modifies kernel page tables (e.g.
vmalloc_area_pages) I could not figure out, how the page global directories are kept consistent. It looks to me as if
global page directory entries were modified in one global page directory (the swapper_pg_dir) only. If this is the case, I wonder how the modifications are 'propagated'
into all the other global page directories (I think they *must* at one moment be copied into all other global page directories, in order to make the new memory mapping
visible in all process contexts).

I thought that maybe one global page directory was used for all processes, but than I wonder how the user space mappings in the beginning of the virtual address space
(which are process specific) can be handled.

Please put me on cc: in your reply, since I am not subscribed to the list.

thank you in advance, regards
Martin

--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich


--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
IRC Channel:   irc.openprojects.net / #kernelnewbies
Web Page:      http://www.kernelnewbies.org/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
