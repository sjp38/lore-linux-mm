Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j2ELF0J9014573
	for <linux-mm@kvack.org>; Mon, 14 Mar 2005 16:15:00 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2ELEx9J243386
	for <linux-mm@kvack.org>; Mon, 14 Mar 2005 16:14:59 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j2ELExlE014186
	for <linux-mm@kvack.org>; Mon, 14 Mar 2005 16:14:59 -0500
Subject: [PATCH 0/4] sparsemem intro patches
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: text/plain
Date: Mon, 14 Mar 2005 13:14:43 -0800
Message-Id: <1110834883.19340.47.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

The following four patches provide the last needed changes before the
introduction of sparsemem.  For a more complete description of what this
will do, please see this patch:

http://www.sr71.net/patches/2.6.11/2.6.11-bk7-mhp1/broken-out/B-sparse-150-sparsemem.patch

or previous posts on the subject:
http://marc.theaimsgroup.com/?t=110868540700001&r=1&w=2
http://marc.theaimsgroup.com/?l=linux-mm&m=109897373315016&w=2

Three of these are i386-only, but one of them reorganizes the macros
used to manage the space in page->flags, and will affect all platforms.
There are analogous patches to the i386 ones for ppc64, ia64, and
x86_64, but those will be submitted by the normal arch maintainers.

The combination of the four patches has been test-booted on a variety of
i386 hardware, and compiled for ppc64, i386, and x86-64 with about 17
different .configs.  It's also been runtime-tested on ia64 configs (with
more patches on top).

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
