Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1OHUUAN017049
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 12:30:30 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1OHUUSt219308
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 12:30:30 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1OHUTxj008342
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 12:30:29 -0500
Subject: [PATCH 0/5] prepare x86/ppc64 DISCONTIG code for hotplug
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: text/plain
Date: Thu, 24 Feb 2005 09:30:26 -0800
Message-Id: <1109266226.7244.79.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Matthew Dobson <colpatch@us.ibm.com>, Keith Mannthey <kmannth@us.ibm.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Anton Blanchard <anton@samba.org>, Mike Kravetz <kravetz@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Subject pretty much says it all.  Descriptions are in the individual
patches.

They apply to 2.6.11-rc4 after a few patches from -mm which conflicted:

	stop-using-base-argument-in-__free_pages_bulk.patch
	consolidate-set_max_mapnr_init-implementations.patch
	refactor-i386-memory-setup.patch
	remove-free_all_bootmem-define.patch
	mostly-i386-mm-cleanup.patch

Boot-tested on plain x86 laptop, NUMAQ, and Summit.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
