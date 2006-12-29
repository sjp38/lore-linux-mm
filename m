Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.6) with ESMTP id kBTMB7T53498080
	for <linux-mm@kvack.org>; Fri, 29 Dec 2006 21:11:39 -0100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id kBTACFvr088234
	for <linux-mm@kvack.org>; Fri, 29 Dec 2006 21:12:20 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBTA8jR3018567
	for <linux-mm@kvack.org>; Fri, 29 Dec 2006 21:08:45 +1100
From: Balbir Singh <balbir@in.ibm.com>
Date: Fri, 29 Dec 2006 15:38:39 +0530
Message-Id: <20061229100839.13860.15525.sendpatchset@balbir.in.ibm.com>
Subject: [RFC][PATCH 0/3] Add shared RSS accounting
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hugh@veritas.com, akpm@osdl.org, andyw@uk.ibm.com
Cc: linux-mm@kvack.org, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch adds accounting of shared pages. A page is considered shared when
it is mapped in by two or more mm_struct's.

The advantage of being able to track shared pages is that

(1) It can serve as a framework on top of which rss limits can be implemented
(2) A memory resource control framework would need to track shared pages
    for resource control
(3) The private pages give an idea about how many pages will be freed if
    the process is killed

The patches apply against 2.6.20-rc2

Shared accounting can be turned on enabling CONFIG_SHARED_PAGE_ACCOUNTING.
This ensures that for configurations not interested in shared page accounting
there is no overhead.

TODO:

1. Post benchmark numbers

Comments, criticism, suggested improvements, better ways to achieve the
same functionality are welcome. Tested on UML and powerpc (compared the
results seen from /proc/pid/statm against /proc/pid/smaps)

Andy Whitcroft helped with the patches by discussing an earlier version of
the patch and it's need in detail.

Signed-off-by: Balbir Singh <balbir@in.ibm.com>

series
======
add-page-map-lock.patch
move-accounting-to-rmap.patch
add-shared-accounting.patch

An additional patch ([PATCH 2.6.20-rc2] Fix set_pte_at arguments in
page_mkclean_one) might be required to get the kernel to compile.
See http://lkml.org/lkml/2006/12/28/258.

PS: While testing the code on a i386 box with highmem and CONFIG_HIGHPTE
set, I see a BUG() in kmap_atomic(). I think this is a known issue and
is being discussed on lkml (see http://lkml.org/lkml/2006/12/28/255)

-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
