Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2776B000A
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:11 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b10-v6so926576wrf.3
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 01:08:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 35si859582edk.410.2018.04.18.01.08.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 01:08:10 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3I87Kc3170558
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:08 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2he27pg1cn-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:08 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 18 Apr 2018 09:08:06 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 3/7] docs/vm: pagemap: formatting and spelling updates
Date: Wed, 18 Apr 2018 11:07:46 +0300
In-Reply-To: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524038870-413-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@infradead.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/pagemap.rst | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/Documentation/vm/pagemap.rst b/Documentation/vm/pagemap.rst
index d54b4bf..9644bc0 100644
--- a/Documentation/vm/pagemap.rst
+++ b/Documentation/vm/pagemap.rst
@@ -13,7 +13,7 @@ There are four components to pagemap:
  * ``/proc/pid/pagemap``.  This file lets a userspace process find out which
    physical frame each virtual page is mapped to.  It contains one 64-bit
    value for each virtual page, containing the following data (from
-   fs/proc/task_mmu.c, above pagemap_read):
+   ``fs/proc/task_mmu.c``, above pagemap_read):
 
     * Bits 0-54  page frame number (PFN) if present
     * Bits 0-4   swap type if swapped
@@ -36,7 +36,7 @@ There are four components to pagemap:
    precisely which pages are mapped (or in swap) and comparing mapped
    pages between processes.
 
-   Efficient users of this interface will use /proc/pid/maps to
+   Efficient users of this interface will use ``/proc/pid/maps`` to
    determine which areas of memory are actually mapped and llseek to
    skip over unmapped regions.
 
@@ -79,11 +79,11 @@ There are four components to pagemap:
    memory cgroup each page is charged to, indexed by PFN. Only available when
    CONFIG_MEMCG is set.
 
-Short descriptions to the page flags:
-=====================================
+Short descriptions to the page flags
+====================================
 
 0 - LOCKED
-   page is being locked for exclusive access, eg. by undergoing read/write IO
+   page is being locked for exclusive access, e.g. by undergoing read/write IO
 7 - SLAB
    page is managed by the SLAB/SLOB/SLUB/SLQB kernel memory allocator
    When compound page is used, SLUB/SLQB will only set this flag on the head
@@ -132,7 +132,7 @@ IO related page flags
    ie. for file backed page: (in-memory data revision >= on-disk one)
 4 - DIRTY
    page has been written to, hence contains new data
-   ie. for file backed page: (in-memory data revision >  on-disk one)
+   i.e. for file backed page: (in-memory data revision >  on-disk one)
 8 - WRITEBACK
    page is being synced to disk
 
@@ -145,7 +145,7 @@ LRU related page flags
    page is in the active LRU list
 18 - UNEVICTABLE
    page is in the unevictable (non-)LRU list It is somehow pinned and
-   not a candidate for LRU page reclaims, eg. ramfs pages,
+   not a candidate for LRU page reclaims, e.g. ramfs pages,
    shmctl(SHM_LOCK) and mlock() memory segments
 2 - REFERENCED
    page has been referenced since last LRU list enqueue/requeue
@@ -156,7 +156,7 @@ LRU related page flags
 12 - ANON
    a memory mapped page that is not part of a file
 13 - SWAPCACHE
-   page is mapped to swap space, ie. has an associated swap entry
+   page is mapped to swap space, i.e. has an associated swap entry
 14 - SWAPBACKED
    page is backed by swap/RAM
 
-- 
2.7.4
