Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l7OFJsng002940
	for <linux-mm@kvack.org>; Sat, 25 Aug 2007 01:19:54 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7OFJrjB4518052
	for <linux-mm@kvack.org>; Sat, 25 Aug 2007 01:19:53 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7OFJrXh027320
	for <linux-mm@kvack.org>; Sat, 25 Aug 2007 01:19:53 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 24 Aug 2007 20:49:48 +0530
Message-Id: <20070824151948.16582.34424.sendpatchset@balbir-laptop>
Subject: [-mm PATCH 0/10] Memory controller introduction (v7)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Linux MM Mailing List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric W Biederman <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

Hi, Andrew,

Here's version 7 of the memory controller (against 2.6.23-rc2-mm2). I was
told "7" is a lucky number, so I am hopeful this version of the patchset will
get merged ;)

The salient features of the patches are

a. Provides *zero overhead* for non memory controller users
b. Enable control of both RSS (mapped) and Page Cache (unmapped) pages
c. The infrastructure allows easy addition of other types of memory to control
d. Provides a double LRU: global memory pressure causes reclaim from the
   global LRU; a container on hitting a limit, reclaims from the per
   container LRU

The documentation accompanying this patch has more details on the design
and usage.

Changelog since version 6

1. Port to 2.6.23-rc3-mm1
2. Add new documentation

Tested the patches (with config disabled) and kernbench, lmbench on an
x86_64 box.

For more detailed test results, comments on usage and detailed changelog
please see version 6 of the patches

	http://lwn.net/Articles/246140/

series

mem-control-res-counters-infrastructure
mem-control-setup
mem-control-accounting-setup
mem-control-accounting
mem-control-task-migration
mem-control-lru-and-reclaim
mem-control-out-of-memory
mem-control-choose-rss-vs-rss-and-pagecache
mem-control-per-container-page-referenced
mem-control-documentation

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
