Received: from icy.inside.sealabs.com (root@icy.inside.sealabs.com [192.168.49.43])
	by klawatti.sealabs.com (8.8.5/8.8.5) with ESMTP id NAA07609
	for <linux-mm@kvack.org>; Wed, 14 Jul 1999 13:19:39 -0700
Received: from watchguard.com (windsurf.inside.sealabs.com [192.168.49.235])
	by icy.inside.sealabs.com (8.8.7/8.8.7) with ESMTP id NAA26131
	for <linux-mm@kvack.org>; Wed, 14 Jul 1999 13:23:21 -0700
Message-ID: <378CF1B5.4EBCCC5D@watchguard.com>
Date: Wed, 14 Jul 1999 13:23:17 -0700
From: Craig Perras <cperras@watchguard.com>
MIME-Version: 1.0
Subject: mquery call and page faults
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello -

I scanned the docs and code for a counterpart to the mprotect call: I
would like some way to query the vm_flags for a page (or set of pages).
It would be great if it was possible to check the page-flag values as
well (locked, dirty, etc), tho this is less important. 

Finally, is there an architecture-independent method for determining the
type of page fault? The only thing I've found was in the do_page_fault
call, but it is processor-dependent.

I would be happy to implement these features if they do not already
exist and if noone else is working on them. Any suggestions are welcome.

thanks!
--craig
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
