Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE376B000D
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:13:56 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c73-v6so14544156qke.2
        for <linux-mm@kvack.org>; Mon, 14 May 2018 01:13:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p13-v6si6135105qtg.64.2018.05.14.01.13.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 01:13:55 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4E84Itb133843
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:13:54 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hy19s3rbf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:13:54 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 14 May 2018 09:13:52 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/3] docs/vm: transhuge: change sections order
Date: Mon, 14 May 2018 11:13:38 +0300
In-Reply-To: <1526285620-453-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1526285620-453-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1526285620-453-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

so that userspace interface and implementation description will be grouped
together

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/transhuge.rst | 82 +++++++++++++++++++++---------------------
 1 file changed, 41 insertions(+), 41 deletions(-)

diff --git a/Documentation/vm/transhuge.rst b/Documentation/vm/transhuge.rst
index 2c6867f..56d04cbb 100644
--- a/Documentation/vm/transhuge.rst
+++ b/Documentation/vm/transhuge.rst
@@ -38,31 +38,6 @@ are using hugepages but a significant speedup already happens if only
 one of the two is using hugepages just because of the fact the TLB
 miss is going to run faster.
 
-Design
-======
-
-- "graceful fallback": mm components which don't have transparent hugepage
-  knowledge fall back to breaking huge pmd mapping into table of ptes and,
-  if necessary, split a transparent hugepage. Therefore these components
-  can continue working on the regular pages or regular pte mappings.
-
-- if a hugepage allocation fails because of memory fragmentation,
-  regular pages should be gracefully allocated instead and mixed in
-  the same vma without any failure or significant delay and without
-  userland noticing
-
-- if some task quits and more hugepages become available (either
-  immediately in the buddy or through the VM), guest physical memory
-  backed by regular pages should be relocated on hugepages
-  automatically (with khugepaged)
-
-- it doesn't require memory reservation and in turn it uses hugepages
-  whenever possible (the only possible reservation here is kernelcore=
-  to avoid unmovable pages to fragment all the memory but such a tweak
-  is not specific to transparent hugepage support and it's a generic
-  feature that applies to all dynamic high order allocations in the
-  kernel)
-
 Transparent Hugepage Support maximizes the usefulness of free memory
 if compared to the reservation approach of hugetlbfs by allowing all
 unused memory to be used as cache or other movable (or even unmovable
@@ -401,6 +376,47 @@ tracer to record how long was spent in __alloc_pages_nodemask and
 using the mm_page_alloc tracepoint to identify which allocations were
 for huge pages.
 
+Optimizing the applications
+===========================
+
+To be guaranteed that the kernel will map a 2M page immediately in any
+memory region, the mmap region has to be hugepage naturally
+aligned. posix_memalign() can provide that guarantee.
+
+Hugetlbfs
+=========
+
+You can use hugetlbfs on a kernel that has transparent hugepage
+support enabled just fine as always. No difference can be noted in
+hugetlbfs other than there will be less overall fragmentation. All
+usual features belonging to hugetlbfs are preserved and
+unaffected. libhugetlbfs will also work fine as usual.
+
+Design principles
+=================
+
+- "graceful fallback": mm components which don't have transparent hugepage
+  knowledge fall back to breaking huge pmd mapping into table of ptes and,
+  if necessary, split a transparent hugepage. Therefore these components
+  can continue working on the regular pages or regular pte mappings.
+
+- if a hugepage allocation fails because of memory fragmentation,
+  regular pages should be gracefully allocated instead and mixed in
+  the same vma without any failure or significant delay and without
+  userland noticing
+
+- if some task quits and more hugepages become available (either
+  immediately in the buddy or through the VM), guest physical memory
+  backed by regular pages should be relocated on hugepages
+  automatically (with khugepaged)
+
+- it doesn't require memory reservation and in turn it uses hugepages
+  whenever possible (the only possible reservation here is kernelcore=
+  to avoid unmovable pages to fragment all the memory but such a tweak
+  is not specific to transparent hugepage support and it's a generic
+  feature that applies to all dynamic high order allocations in the
+  kernel)
+
 get_user_pages and follow_page
 ==============================
 
@@ -432,22 +448,6 @@ hugepages being returned (as it's not only checking the pfn of the
 page and pinning it during the copy but it pretends to migrate the
 memory in regular page sizes and with regular pte/pmd mappings).
 
-Optimizing the applications
-===========================
-
-To be guaranteed that the kernel will map a 2M page immediately in any
-memory region, the mmap region has to be hugepage naturally
-aligned. posix_memalign() can provide that guarantee.
-
-Hugetlbfs
-=========
-
-You can use hugetlbfs on a kernel that has transparent hugepage
-support enabled just fine as always. No difference can be noted in
-hugetlbfs other than there will be less overall fragmentation. All
-usual features belonging to hugetlbfs are preserved and
-unaffected. libhugetlbfs will also work fine as usual.
-
 Graceful fallback
 =================
 
-- 
2.7.4
