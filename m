Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l64MZe8q026988
	for <linux-mm@kvack.org>; Thu, 5 Jul 2007 08:35:57 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l64MGLZY143396
	for <linux-mm@kvack.org>; Thu, 5 Jul 2007 08:16:24 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l64MCnB3026944
	for <linux-mm@kvack.org>; Thu, 5 Jul 2007 08:12:49 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 04 Jul 2007 15:12:40 -0700
Message-Id: <20070704221240.13517.37641.sendpatchset@balbir-laptop>
Subject: [-mm PATCH 0/7] Memory controller introduction
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@>, osdl.org, Pavel Emelianov <xemul@>, openvz.org, Vaidyanathan Srinivasan <svaidy@>, linux.vnet.ibm.com
Cc: Paul Menage <menage@>, google.com, Linux Kernel Mailing List <linux-kernel@>, vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, Linux Containers <containers@>, lists.osdl.org
List-ID: <linux-mm.kvack.org>

Resending with the patch numbering fixed and linux-mm copied

This patchset implements another version of the memory controller. These
patches have been through a big churn, the first set of patches were posted
last year and earlier this year at
	http://lkml.org/lkml/2007/2/19/10

Ever since, the RSS controller has been through four revisions, the latest
one being
	http://lwn.net/Articles/236817/

This patchset draws from the patches listed above and from some of the
contents of the patches posted by Vaidyanathan for page cache control.
	http://lkml.org/lkml/2007/6/20/92

Pavel, Vaidy could you look at the patches and add your signed off by
where relevant?

At OLS, the resource management BOF, it was discussed that we need to manage
RSS and unmapped page cache together. This patchset is a step towards that

TODO's

1. Add memory controller water mark support. Reclaim on high water mark
2. Add support for shrinking on limit change
3. Add per zone per container LRU lists
4. Make page_referenced() container aware
5. Figure out a better CLUI for the controller

In case you have been using/testing the RSS controller, you'll find that
this controller works slower than the RSS controller. The reason being
that both swap cache and page cache is accounted for, so pages do go
out to swap upon reclaim (they cannot live in the swap cache).

I've test compiled the framework without the controller enabled, tested
the code on UML and minimally on a power box.

Any test output, feedback, comments, suggestions are welcome!

series

res_counters_infra.patch
mem-control-setup.patch
mem-control-accounting-setup.patch
mem-control-accounting.patch
mem-control-task-migration.patch
mem-control-lru-and-reclaim.patch
mem-control-out-of-memory.patch

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
