Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5RFIAV2026325
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 11:18:10 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5RFI9Xu217564
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 11:18:10 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5RFI96V032317
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 11:18:09 -0400
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 27 Jun 2008 20:48:08 +0530
Message-Id: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
Subject: [RFC 0/5] Memory controller soft limit introduction (v3)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patchset implements the basic changes required to implement soft limits
in the memory controller. A soft limit is a variation of the currently
supported hard limit feature. A memory cgroup can exceed it's soft limit
provided there is no contention for memory.

These patches were tested on a x86_64 box, by running a programs in parallel,
and checking their behaviour for various soft limit values.

These patches were developed on top of 2.6.26-rc5-mm3. Comments, suggestions,
criticism are all welcome!

A previous version of the patch can be found at

http://kerneltrap.org/mailarchive/linux-kernel/2008/2/19/904114

TODOs:

1. Distribute the excessive (non-contended) resources between groups
   in the ratio of their soft limits
2. Merge with KAMEZAWA's and YAMAMOTO's water mark and background reclaim
   patches in the long-term

series
------
memory-controller-soft-limit-add-documentation.patch
prio_heap_delete_max.patch
prio_heap_replace_leaf.patch
memory-controller-soft-limit-res-counter-updates.patch
memory-controller-soft-limit-reclaim-on-contention.patch

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
