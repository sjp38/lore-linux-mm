Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1SIsNpb003350
	for <linux-mm@kvack.org>; Mon, 28 Feb 2005 13:54:23 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1SIsNmU061578
	for <linux-mm@kvack.org>; Mon, 28 Feb 2005 13:54:23 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1SIsMjV022750
	for <linux-mm@kvack.org>; Mon, 28 Feb 2005 13:54:22 -0500
Subject: [PATCH 0/5] prepare x86/ppc64 DISCONTIG code for hotplug
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: text/plain
Date: Mon, 28 Feb 2005 10:54:18 -0800
Message-Id: <1109616858.6921.39.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Keith Mannthey <kmannth@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Subject pretty much says it all.  Descriptions are in the individual
patches.  These patches replace the
"allow-hot-add-enabled-i386-numa-box-to-boot.patch" which is currently
in -mm.  Please drop it.  

They apply to 2.6.11-rc5 after a few patches from -mm which conflicted:

	stop-using-base-argument-in-__free_pages_bulk.patch
	consolidate-set_max_mapnr_init-implementations.patch
	refactor-i386-memory-setup.patch
	remove-free_all_bootmem-define.patch
	mostly-i386-mm-cleanup.patch

Boot-tested on plain x86 laptop, NUMAQ, and Summit.  These probably
deserve to stay in -mm for a release or two.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
