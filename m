Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68F076B0028
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:05:35 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b17so2704675wrf.20
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 08:05:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c60si2736055edd.409.2018.03.21.08.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 08:05:34 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LF3SfK021783
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:05:32 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gupga1eek-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:05:31 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 15:05:29 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] docs/vm: update 00-INDEX
Date: Wed, 21 Mar 2018 17:05:23 +0200
Message-Id: <1521644723-19354-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Several files were added to Documentation/vm without updates to 00-INDEX.
Fill in the missing documents

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/00-INDEX | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/Documentation/vm/00-INDEX b/Documentation/vm/00-INDEX
index 11d3d8d..0278f2c 100644
--- a/Documentation/vm/00-INDEX
+++ b/Documentation/vm/00-INDEX
@@ -10,6 +10,8 @@ frontswap.txt
 	- Outline frontswap, part of the transcendent memory frontend.
 highmem.txt
 	- Outline of highmem and common issues.
+hmm.txt
+	- Documentation of heterogeneous memory management
 hugetlbpage.txt
 	- a brief summary of hugetlbpage support in the Linux kernel.
 hugetlbfs_reserv.txt
@@ -20,25 +22,41 @@ idle_page_tracking.txt
 	- description of the idle page tracking feature.
 ksm.txt
 	- how to use the Kernel Samepage Merging feature.
+mmu_notifier.txt
+	- a note about clearing pte/pmd and mmu notifications
 numa
 	- information about NUMA specific code in the Linux vm.
 numa_memory_policy.txt
 	- documentation of concepts and APIs of the 2.6 memory policy support.
 overcommit-accounting
 	- description of the Linux kernels overcommit handling modes.
+page_frags
+	- description of page fragments allocator
 page_migration
 	- description of page migration in NUMA systems.
 pagemap.txt
 	- pagemap, from the userspace perspective
+page_owner.txt
+	- tracking about who allocated each page
+remap_file_pages.txt
+	- a note about remap_file_pages() system call
 slub.txt
 	- a short users guide for SLUB.
 soft-dirty.txt
 	- short explanation for soft-dirty PTEs
 split_page_table_lock
 	- Separate per-table lock to improve scalability of the old page_table_lock.
+swap_numa.txt
+	- automatic binding of swap device to numa node
 transhuge.txt
 	- Transparent Hugepage Support, alternative way of using hugepages.
 unevictable-lru.txt
 	- Unevictable LRU infrastructure
+userfaultfd.txt
+	- description of userfaultfd system call
+z3fold.txt
+	- outline of z3fold allocator for storing compressed pages
+zsmalloc.txt
+	- outline of zsmalloc allocator for storing compressed pages
 zswap.txt
 	- Intro to compressed cache for swap pages
-- 
2.7.4
