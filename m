Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C84956B0283
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:22 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v194so3773324qka.2
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:25:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e3si2960619qkm.283.2018.03.21.12.25.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:25:21 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJPK2t127054
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:20 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gut67sek2-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:20 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:25:17 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 30/32] docs/vm: zswap.txt: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:46 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Message-Id: <1521660168-14372-31-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/zswap.txt | 71 +++++++++++++++++++++++++++-------------------
 1 file changed, 42 insertions(+), 29 deletions(-)

diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
index 0b3a114..1444ecd 100644
--- a/Documentation/vm/zswap.txt
+++ b/Documentation/vm/zswap.txt
@@ -1,4 +1,11 @@
-Overview:
+.. _zswap:
+
+=====
+zswap
+=====
+
+Overview
+========
 
 Zswap is a lightweight compressed cache for swap pages. It takes pages that are
 in the process of being swapped out and attempts to compress them into a
@@ -7,32 +14,34 @@ for potentially reduced swap I/O.A  This trade-off can also result in a
 significant performance improvement if reads from the compressed cache are
 faster than reads from a swap device.
 
-NOTE: Zswap is a new feature as of v3.11 and interacts heavily with memory
-reclaim.  This interaction has not been fully explored on the large set of
-potential configurations and workloads that exist.  For this reason, zswap
-is a work in progress and should be considered experimental.
+.. note::
+   Zswap is a new feature as of v3.11 and interacts heavily with memory
+   reclaim.  This interaction has not been fully explored on the large set of
+   potential configurations and workloads that exist.  For this reason, zswap
+   is a work in progress and should be considered experimental.
+
+   Some potential benefits:
 
-Some potential benefits:
 * Desktop/laptop users with limited RAM capacities can mitigate the
-A A A  performance impact of swapping.
+  performance impact of swapping.
 * Overcommitted guests that share a common I/O resource can
-A A A  dramatically reduce their swap I/O pressure, avoiding heavy handed I/O
-    throttling by the hypervisor.A This allows more work to get done with less
-    impact to the guest workload and guests sharing the I/O subsystem
+  dramatically reduce their swap I/O pressure, avoiding heavy handed I/O
+  throttling by the hypervisor.A This allows more work to get done with less
+  impact to the guest workload and guests sharing the I/O subsystem
 * Users with SSDs as swap devices can extend the life of the device by
-A A A  drastically reducing life-shortening writes.
+  drastically reducing life-shortening writes.
 
 Zswap evicts pages from compressed cache on an LRU basis to the backing swap
 device when the compressed pool reaches its size limit.  This requirement had
 been identified in prior community discussions.
 
 Zswap is disabled by default but can be enabled at boot time by setting
-the "enabled" attribute to 1 at boot time. ie: zswap.enabled=1.  Zswap
+the ``enabled`` attribute to 1 at boot time. ie: ``zswap.enabled=1``.  Zswap
 can also be enabled and disabled at runtime using the sysfs interface.
 An example command to enable zswap at runtime, assuming sysfs is mounted
-at /sys, is:
+at ``/sys``, is::
 
-echo 1 > /sys/module/zswap/parameters/enabled
+	echo 1 > /sys/module/zswap/parameters/enabled
 
 When zswap is disabled at runtime it will stop storing pages that are
 being swapped out.  However, it will _not_ immediately write out or fault
@@ -43,7 +52,8 @@ pages out of the compressed pool, a swapoff on the swap device(s) will
 fault back into memory all swapped out pages, including those in the
 compressed pool.
 
-Design:
+Design
+======
 
 Zswap receives pages for compression through the Frontswap API and is able to
 evict pages from its own compressed pool on an LRU basis and write them back to
@@ -53,12 +63,12 @@ Zswap makes use of zpool for the managing the compressed memory pool.  Each
 allocation in zpool is not directly accessible by address.  Rather, a handle is
 returned by the allocation routine and that handle must be mapped before being
 accessed.  The compressed memory pool grows on demand and shrinks as compressed
-pages are freed.  The pool is not preallocated.  By default, a zpool of type
-zbud is created, but it can be selected at boot time by setting the "zpool"
-attribute, e.g. zswap.zpool=zbud.  It can also be changed at runtime using the
-sysfs "zpool" attribute, e.g.
+pages are freed.  The pool is not preallocated.  By default, a zpool
+of type zbud is created, but it can be selected at boot time by
+setting the ``zpool`` attribute, e.g. ``zswap.zpool=zbud``. It can
+also be changed at runtime using the sysfs ``zpool`` attribute, e.g.::
 
-echo zbud > /sys/module/zswap/parameters/zpool
+	echo zbud > /sys/module/zswap/parameters/zpool
 
 The zbud type zpool allocates exactly 1 page to store 2 compressed pages, which
 means the compression ratio will always be 2:1 or worse (because of half-full
@@ -83,14 +93,16 @@ via frontswap, to free the compressed entry.
 
 Zswap seeks to be simple in its policies.  Sysfs attributes allow for one user
 controlled policy:
+
 * max_pool_percent - The maximum percentage of memory that the compressed
-    pool can occupy.
+  pool can occupy.
 
-The default compressor is lzo, but it can be selected at boot time by setting
-the a??compressora?? attribute, e.g. zswap.compressor=lzo.  It can also be changed
-at runtime using the sysfs "compressor" attribute, e.g.
+The default compressor is lzo, but it can be selected at boot time by
+setting the ``compressor`` attribute, e.g. ``zswap.compressor=lzo``.
+It can also be changed at runtime using the sysfs "compressor"
+attribute, e.g.::
 
-echo lzo > /sys/module/zswap/parameters/compressor
+	echo lzo > /sys/module/zswap/parameters/compressor
 
 When the zpool and/or compressor parameter is changed at runtime, any existing
 compressed pages are not modified; they are left in their own zpool.  When a
@@ -106,11 +118,12 @@ compressed length of the page is set to zero and the pattern or same-filled
 value is stored.
 
 Same-value filled pages identification feature is enabled by default and can be
-disabled at boot time by setting the "same_filled_pages_enabled" attribute to 0,
-e.g. zswap.same_filled_pages_enabled=0. It can also be enabled and disabled at
-runtime using the sysfs "same_filled_pages_enabled" attribute, e.g.
+disabled at boot time by setting the ``same_filled_pages_enabled`` attribute
+to 0, e.g. ``zswap.same_filled_pages_enabled=0``. It can also be enabled and
+disabled at runtime using the sysfs ``same_filled_pages_enabled``
+attribute, e.g.::
 
-echo 1 > /sys/module/zswap/parameters/same_filled_pages_enabled
+	echo 1 > /sys/module/zswap/parameters/same_filled_pages_enabled
 
 When zswap same-filled page identification is disabled at runtime, it will stop
 checking for the same-value filled pages during store operation. However, the
-- 
2.7.4
