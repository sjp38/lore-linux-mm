Received: from cse.iitkgp.ernet.in (IDENT:root@cse.iitkgp.ernet.in [144.16.192.57])
	by iitkgp.iitkgp.ernet.in (8.9.3/8.9.3) with ESMTP id BAA16311
	for <linux-mm@kvack.org>; Wed, 8 Nov 2000 01:37:22 -0500 (GMT)
Received: from cse.iitkgp.ernet.in (decsrv1 [144.16.202.161])
	by cse.iitkgp.ernet.in (8.9.3/8.8.7) with ESMTP id CAA12165
	for <linux-mm@kvack.org>; Wed, 8 Nov 2000 02:19:48 +0530
Message-ID: <3A08F37A.38C156C1@cse.iitkgp.ernet.in>
Date: Wed, 08 Nov 2000 01:32:26 -0500
From: Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
MIME-Version: 1.0
Subject: Question about swap_in() in 2.2.16 ....
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

hi,

after the missing page has been swapped in this bit of code is
executed:-

if (!write_access || is_page_shared(page_map)) {
      set_pte(page_table, mk_pte(page, vma->vm_page_prot));
      return 1;
 }

Now this creates a read-only mapping  even if the access was a "write
acess"  ( if the page is shared ). Doesnt this mean that an additional
"write-protect" fault will be taken immediately when the process tries
to write again ? Or am i missing something here ?

joy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
