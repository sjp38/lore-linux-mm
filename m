Received: from smtp01.mail.gol.com (smtp01.mail.gol.com [203.216.5.11])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA28936
	for <linux-mm@kvack.org>; Fri, 19 Feb 1999 05:22:07 -0500
Received: from earthling.net (tc-1-018.ariake.gol.ne.jp [203.216.42.18])
	by smtp01.mail.gol.com (8.9.2/8.9.2/892-SMTP-P) with ESMTP id TAA22803
	for <linux-mm@kvack.org>; Fri, 19 Feb 1999 19:22:02 +0900 (JST)
Message-ID: <36CD3BCE.9D2AE90E@earthling.net>
Date: Fri, 19 Feb 1999 19:24:14 +0900
From: Neil Booth <NeilB@earthling.net>
MIME-Version: 1.0
Subject: vmalloc.c question
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have a simple question about vmalloc.c. I'm probably missing something
obvious, but it appears to me that the list "vmlist" of the kernel's
virtual memory areas is not protected by any kind of locking mechanism,
and thus subject to races. (e.g. two CPUs trying to insert a new virtual
memory block in the same place at the same time in get_vm_area).

Or what am I missing?

Thanks,

Neil.
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
