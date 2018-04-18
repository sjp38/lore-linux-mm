Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3071C6B0012
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:23 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d37-v6so900365wrd.21
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 01:08:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y9si841969edh.277.2018.04.18.01.08.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 01:08:21 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3I86GIU053167
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:20 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2he2430fqg-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:20 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 18 Apr 2018 09:08:17 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 7/7] docs/admin-guide/mm: convert plain text cross references to hyperlinks
Date: Wed, 18 Apr 2018 11:07:50 +0300
In-Reply-To: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524038870-413-8-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@infradead.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/admin-guide/mm/hugetlbpage.rst        |  3 ++-
 Documentation/admin-guide/mm/idle_page_tracking.rst |  5 +++--
 Documentation/admin-guide/mm/pagemap.rst            | 18 +++++++++++-------
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/Documentation/admin-guide/mm/hugetlbpage.rst b/Documentation/admin-guide/mm/hugetlbpage.rst
index 2b374d1..a8b0806 100644
--- a/Documentation/admin-guide/mm/hugetlbpage.rst
+++ b/Documentation/admin-guide/mm/hugetlbpage.rst
@@ -219,7 +219,8 @@ When adjusting the persistent hugepage count via ``nr_hugepages_mempolicy``, any
 memory policy mode--bind, preferred, local or interleave--may be used.  The
 resulting effect on persistent huge page allocation is as follows:
 
-#. Regardless of mempolicy mode [see Documentation/vm/numa_memory_policy.rst],
+#. Regardless of mempolicy mode [see
+   :ref:`Documentation/vm/numa_memory_policy.rst <numa_memory_policy>`],
    persistent huge pages will be distributed across the node or nodes
    specified in the mempolicy as if "interleave" had been specified.
    However, if a node in the policy does not contain sufficient contiguous
diff --git a/Documentation/admin-guide/mm/idle_page_tracking.rst b/Documentation/admin-guide/mm/idle_page_tracking.rst
index 92e3a25..6f7b7ca 100644
--- a/Documentation/admin-guide/mm/idle_page_tracking.rst
+++ b/Documentation/admin-guide/mm/idle_page_tracking.rst
@@ -65,8 +65,9 @@ workload one should:
     are not reclaimable, he or she can filter them out using
     ``/proc/kpageflags``.
 
-See Documentation/admin-guide/mm/pagemap.rst for more information about
-``/proc/pid/pagemap``, ``/proc/kpageflags``, and ``/proc/kpagecgroup``.
+See :ref:`Documentation/admin-guide/mm/pagemap.rst <pagemap>` for more
+information about ``/proc/pid/pagemap``, ``/proc/kpageflags``, and
+``/proc/kpagecgroup``.
 
 .. _impl_details:
 
diff --git a/Documentation/admin-guide/mm/pagemap.rst b/Documentation/admin-guide/mm/pagemap.rst
index 053ca64..577af85 100644
--- a/Documentation/admin-guide/mm/pagemap.rst
+++ b/Documentation/admin-guide/mm/pagemap.rst
@@ -18,7 +18,8 @@ There are four components to pagemap:
     * Bits 0-54  page frame number (PFN) if present
     * Bits 0-4   swap type if swapped
     * Bits 5-54  swap offset if swapped
-    * Bit  55    pte is soft-dirty (see Documentation/admin-guide/mm/soft-dirty.rst)
+    * Bit  55    pte is soft-dirty (see
+      :ref:`Documentation/admin-guide/mm/soft-dirty.rst <soft_dirty>`)
     * Bit  56    page exclusively mapped (since 4.2)
     * Bits 57-60 zero
     * Bit  61    page is file-page or shared-anon (since 3.5)
@@ -97,9 +98,11 @@ Short descriptions to the page flags
     A compound page with order N consists of 2^N physically contiguous pages.
     A compound page with order 2 takes the form of "HTTT", where H donates its
     head page and T donates its tail page(s).  The major consumers of compound
-    pages are hugeTLB pages (Documentation/admin-guide/mm/hugetlbpage.rst), the SLUB etc.
-    memory allocators and various device drivers. However in this interface,
-    only huge/giga pages are made visible to end users.
+    pages are hugeTLB pages
+    (:ref:`Documentation/admin-guide/mm/hugetlbpage.rst <hugetlbpage>`),
+    the SLUB etc.  memory allocators and various device drivers.
+    However in this interface, only huge/giga pages are made visible
+    to end users.
 16 - COMPOUND_TAIL
     A compound page tail (see description above).
 17 - HUGE
@@ -118,9 +121,10 @@ Short descriptions to the page flags
     zero page for pfn_zero or huge_zero page
 25 - IDLE
     page has not been accessed since it was marked idle (see
-    Documentation/admin-guide/mm/idle_page_tracking.rst). Note that this flag may be
-    stale in case the page was accessed via a PTE. To make sure the flag
-    is up-to-date one has to read ``/sys/kernel/mm/page_idle/bitmap`` first.
+    :ref:`Documentation/admin-guide/mm/idle_page_tracking.rst <idle_page_tracking>`).
+    Note that this flag may be stale in case the page was accessed via
+    a PTE. To make sure the flag is up-to-date one has to read
+    ``/sys/kernel/mm/page_idle/bitmap`` first.
 
 IO related page flags
 ---------------------
-- 
2.7.4
