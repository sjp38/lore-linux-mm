Received: from cse.iitkgp.ernet.in (IDENT:root@cse.iitkgp.ernet.in [144.16.192.57])
	by iitkgp.iitkgp.ernet.in (8.9.3/8.9.3) with ESMTP id CAA04515
	for <linux-mm@kvack.org>; Wed, 15 Nov 2000 02:12:47 -0500 (GMT)
Received: from cse.iitkgp.ernet.in (decsrv1 [144.16.202.161])
	by cse.iitkgp.ernet.in (8.9.3/8.8.7) with ESMTP id CAA06751
	for <linux-mm@kvack.org>; Wed, 15 Nov 2000 02:55:25 +0530
Message-ID: <3A12363A.3B5395AF@cse.iitkgp.ernet.in>
Date: Wed, 15 Nov 2000 02:07:38 -0500
From: Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
MIME-Version: 1.0
Subject: Question about pte_alloc()
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

hi all,

it appears from the code that pte_alloc() might block since it allocates
a page table with GFP_KERNEL if the page table doesnt already exist. i
need to call pte_alloc() at interrupt time. Basically i want to map some
kernel memory into user space as soon as the device gives me data. will
there be any problem if i use another version of pte_alloc() which calls
with GFP_ATOMIC priority?
Maybe i am completely lost :-)

cheers
joy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
