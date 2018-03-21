Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E7BD96B0026
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:23 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j3so2968341wrb.18
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:23:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n1si252024edc.511.2018.03.21.12.23.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:23:22 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJJXCR022643
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:20 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gusvyaf35-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:20 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:23:17 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 03/32] docs/vm: cleancache.txt: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:19 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/cleancache.txt | 105 ++++++++++++++++++++++++----------------
 1 file changed, 62 insertions(+), 43 deletions(-)

diff --git a/Documentation/vm/cleancache.txt b/Documentation/vm/cleancache.txt
index e4b49df..68cba91 100644
--- a/Documentation/vm/cleancache.txt
+++ b/Documentation/vm/cleancache.txt
@@ -1,4 +1,11 @@
-MOTIVATION
+.. _cleancache:
+
+==========
+Cleancache
+==========
+
+Motivation
+==========
 
 Cleancache is a new optional feature provided by the VFS layer that
 potentially dramatically increases page cache effectiveness for
@@ -21,9 +28,10 @@ Transcendent memory "drivers" for cleancache are currently implemented
 in Xen (using hypervisor memory) and zcache (using in-kernel compressed
 memory) and other implementations are in development.
 
-FAQs are included below.
+:ref:`FAQs <faq>` are included below.
 
-IMPLEMENTATION OVERVIEW
+Implementation Overview
+=======================
 
 A cleancache "backend" that provides transcendent memory registers itself
 to the kernel's cleancache "frontend" by calling cleancache_register_ops,
@@ -80,22 +88,33 @@ different Linux threads are simultaneously putting and invalidating a page
 with the same handle, the results are indeterminate.  Callers must
 lock the page to ensure serial behavior.
 
-CLEANCACHE PERFORMANCE METRICS
+Cleancache Performance Metrics
+==============================
 
 If properly configured, monitoring of cleancache is done via debugfs in
-the /sys/kernel/debug/cleancache directory.  The effectiveness of cleancache
+the `/sys/kernel/debug/cleancache` directory.  The effectiveness of cleancache
 can be measured (across all filesystems) with:
 
-succ_gets	- number of gets that were successful
-failed_gets	- number of gets that failed
-puts		- number of puts attempted (all "succeed")
-invalidates	- number of invalidates attempted
+``succ_gets``
+	number of gets that were successful
+
+``failed_gets``
+	number of gets that failed
+
+``puts``
+	number of puts attempted (all "succeed")
+
+``invalidates``
+	number of invalidates attempted
 
 A backend implementation may provide additional metrics.
 
+.. _faq:
+
 FAQ
+===
 
-1) Where's the value? (Andrew Morton)
+* Where's the value? (Andrew Morton)
 
 Cleancache provides a significant performance benefit to many workloads
 in many environments with negligible overhead by improving the
@@ -137,8 +156,8 @@ device that stores pages of data in a compressed state.  And
 the proposed "RAMster" driver shares RAM across multiple physical
 systems.
 
-2) Why does cleancache have its sticky fingers so deep inside the
-   filesystems and VFS? (Andrew Morton and Christoph Hellwig)
+* Why does cleancache have its sticky fingers so deep inside the
+  filesystems and VFS? (Andrew Morton and Christoph Hellwig)
 
 The core hooks for cleancache in VFS are in most cases a single line
 and the minimum set are placed precisely where needed to maintain
@@ -168,9 +187,9 @@ filesystems in the future.
 The total impact of the hooks to existing fs and mm files is only
 about 40 lines added (not counting comments and blank lines).
 
-3) Why not make cleancache asynchronous and batched so it can
-   more easily interface with real devices with DMA instead
-   of copying each individual page? (Minchan Kim)
+* Why not make cleancache asynchronous and batched so it can more
+  easily interface with real devices with DMA instead of copying each
+  individual page? (Minchan Kim)
 
 The one-page-at-a-time copy semantics simplifies the implementation
 on both the frontend and backend and also allows the backend to
@@ -182,8 +201,8 @@ are avoided.  While the interface seems odd for a "real device"
 or for real kernel-addressable RAM, it makes perfect sense for
 transcendent memory.
 
-4) Why is non-shared cleancache "exclusive"?  And where is the
-   page "invalidated" after a "get"? (Minchan Kim)
+* Why is non-shared cleancache "exclusive"?  And where is the
+  page "invalidated" after a "get"? (Minchan Kim)
 
 The main reason is to free up space in transcendent memory and
 to avoid unnecessary cleancache_invalidate calls.  If you want inclusive,
@@ -193,7 +212,7 @@ be easily extended to add a "get_no_invalidate" call.
 
 The invalidate is done by the cleancache backend implementation.
 
-5) What's the performance impact?
+* What's the performance impact?
 
 Performance analysis has been presented at OLS'09 and LCA'10.
 Briefly, performance gains can be significant on most workloads,
@@ -206,7 +225,7 @@ single-core systems with slow memory-copy speeds, cleancache
 has little value, but in newer multicore machines, especially
 consolidated/virtualized machines, it has great value.
 
-6) How do I add cleancache support for filesystem X? (Boaz Harrash)
+* How do I add cleancache support for filesystem X? (Boaz Harrash)
 
 Filesystems that are well-behaved and conform to certain
 restrictions can utilize cleancache simply by making a call to
@@ -217,26 +236,26 @@ not enable the optional cleancache.
 
 Some points for a filesystem to consider:
 
-- The FS should be block-device-based (e.g. a ram-based FS such
-  as tmpfs should not enable cleancache)
-- To ensure coherency/correctness, the FS must ensure that all
-  file removal or truncation operations either go through VFS or
-  add hooks to do the equivalent cleancache "invalidate" operations
-- To ensure coherency/correctness, either inode numbers must
-  be unique across the lifetime of the on-disk file OR the
-  FS must provide an "encode_fh" function.
-- The FS must call the VFS superblock alloc and deactivate routines
-  or add hooks to do the equivalent cleancache calls done there.
-- To maximize performance, all pages fetched from the FS should
-  go through the do_mpag_readpage routine or the FS should add
-  hooks to do the equivalent (cf. btrfs)
-- Currently, the FS blocksize must be the same as PAGESIZE.  This
-  is not an architectural restriction, but no backends currently
-  support anything different.
-- A clustered FS should invoke the "shared_init_fs" cleancache
-  hook to get best performance for some backends.
-
-7) Why not use the KVA of the inode as the key? (Christoph Hellwig)
+  - The FS should be block-device-based (e.g. a ram-based FS such
+    as tmpfs should not enable cleancache)
+  - To ensure coherency/correctness, the FS must ensure that all
+    file removal or truncation operations either go through VFS or
+    add hooks to do the equivalent cleancache "invalidate" operations
+  - To ensure coherency/correctness, either inode numbers must
+    be unique across the lifetime of the on-disk file OR the
+    FS must provide an "encode_fh" function.
+  - The FS must call the VFS superblock alloc and deactivate routines
+    or add hooks to do the equivalent cleancache calls done there.
+  - To maximize performance, all pages fetched from the FS should
+    go through the do_mpag_readpage routine or the FS should add
+    hooks to do the equivalent (cf. btrfs)
+  - Currently, the FS blocksize must be the same as PAGESIZE.  This
+    is not an architectural restriction, but no backends currently
+    support anything different.
+  - A clustered FS should invoke the "shared_init_fs" cleancache
+    hook to get best performance for some backends.
+
+* Why not use the KVA of the inode as the key? (Christoph Hellwig)
 
 If cleancache would use the inode virtual address instead of
 inode/filehandle, the pool id could be eliminated.  But, this
@@ -251,7 +270,7 @@ of cleancache would be lost because the cache of pages in cleanache
 is potentially much larger than the kernel pagecache and is most
 useful if the pages survive inode cache removal.
 
-8) Why is a global variable required?
+* Why is a global variable required?
 
 The cleancache_enabled flag is checked in all of the frequently-used
 cleancache hooks.  The alternative is a function call to check a static
@@ -262,14 +281,14 @@ global variable allows cleancache to be enabled by default at compile
 time, but have insignificant performance impact when cleancache remains
 disabled at runtime.
 
-9) Does cleanache work with KVM?
+* Does cleanache work with KVM?
 
 The memory model of KVM is sufficiently different that a cleancache
 backend may have less value for KVM.  This remains to be tested,
 especially in an overcommitted system.
 
-10) Does cleancache work in userspace?  It sounds useful for
-   memory hungry caches like web browsers.  (Jamie Lokier)
+* Does cleancache work in userspace?  It sounds useful for
+  memory hungry caches like web browsers.  (Jamie Lokier)
 
 No plans yet, though we agree it sounds useful, at least for
 apps that bypass the page cache (e.g. O_DIRECT).
-- 
2.7.4
