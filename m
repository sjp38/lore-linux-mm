Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.12.10/8.12.10) with ESMTP id j946pNd7187764
	for <linux-mm@kvack.org>; Tue, 4 Oct 2005 06:51:23 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j946pN27147356
	for <linux-mm@kvack.org>; Tue, 4 Oct 2005 08:51:23 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j946pNiR005718
	for <linux-mm@kvack.org>; Tue, 4 Oct 2005 08:51:23 +0200
Received: from localhost (dyn-9-152-216-41.boeblingen.de.ibm.com [9.152.216.41])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.12.11) with ESMTP id j946pNAZ005713
	for <linux-mm@kvack.org>; Tue, 4 Oct 2005 08:51:23 +0200
Date: Tue, 4 Oct 2005 08:50:30 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: sparsemem & sparsemem extreme question
Message-ID: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I did an implementation of CONFIG_SPARSEMEM for s390, which indeed was quite
easy. Just to find out that it was not sufficient :)
SPARSEMEM_EXTREME looks better but unfortunately adds another layer of
indirection.
I'm just wondering why there is all this indirection stuff here and why not
have one contiguous aray of struct pages (residing in the vmalloc area) that
deals with whatever size of memory an architecture wants to support.
Unused areas just wouldn't have any backing with real pages and on access
generate a page fault (nobody is supposed to access these pages anyway).
This would have the advantage that all the primitives like e.g. pfn_to_page
would be as simple as before, no need to waste large parts of the page flags
and in addition it would easily allow for memory hotplug on page size
granularity.
The only drawbacks are (as far as I can see) a _huge_ virtual mem_map array,
but that shouldn't matter too much. A real problem could be that the mem_map
array and therefore the vmalloc area need to be generated quiete early.

Most probably this has already been thought about before, but I couldn't find
anything in the achives.

Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
