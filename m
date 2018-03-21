Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E6FC26B0028
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:26 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c4so3941817qtm.4
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:23:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s129si5876587qkb.267.2018.03.21.12.23.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:23:25 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJN3Tb119131
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:24 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gut67sccs-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:24 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:23:21 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 04/32] docs/vm: frontswap.txt: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:20 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/frontswap.txt | 59 ++++++++++++++++++++++++++----------------
 1 file changed, 37 insertions(+), 22 deletions(-)

diff --git a/Documentation/vm/frontswap.txt b/Documentation/vm/frontswap.txt
index c71a019..1979f43 100644
--- a/Documentation/vm/frontswap.txt
+++ b/Documentation/vm/frontswap.txt
@@ -1,13 +1,20 @@
+.. _frontswap:
+
+=========
+Frontswap
+=========
+
 Frontswap provides a "transcendent memory" interface for swap pages.
 In some environments, dramatic performance savings may be obtained because
 swapped pages are saved in RAM (or a RAM-like device) instead of a swap disk.
 
-(Note, frontswap -- and cleancache (merged at 3.0) -- are the "frontends"
+(Note, frontswap -- and :ref:`cleancache` (merged at 3.0) -- are the "frontends"
 and the only necessary changes to the core kernel for transcendent memory;
 all other supporting code -- the "backends" -- is implemented as drivers.
-See the LWN.net article "Transcendent memory in a nutshell" for a detailed
-overview of frontswap and related kernel parts:
-https://lwn.net/Articles/454795/ )
+See the LWN.net article `Transcendent memory in a nutshell`_
+for a detailed overview of frontswap and related kernel parts)
+
+.. _Transcendent memory in a nutshell: https://lwn.net/Articles/454795/
 
 Frontswap is so named because it can be thought of as the opposite of
 a "backing" store for a swap device.  The storage is assumed to be
@@ -50,19 +57,27 @@ or the store fails AND the page is invalidated.  This ensures stale data may
 never be obtained from frontswap.
 
 If properly configured, monitoring of frontswap is done via debugfs in
-the /sys/kernel/debug/frontswap directory.  The effectiveness of
+the `/sys/kernel/debug/frontswap` directory.  The effectiveness of
 frontswap can be measured (across all swap devices) with:
 
-failed_stores	- how many store attempts have failed
-loads		- how many loads were attempted (all should succeed)
-succ_stores	- how many store attempts have succeeded
-invalidates	- how many invalidates were attempted
+``failed_stores``
+	how many store attempts have failed
+
+``loads``
+	how many loads were attempted (all should succeed)
+
+``succ_stores``
+	how many store attempts have succeeded
+
+``invalidates``
+	how many invalidates were attempted
 
 A backend implementation may provide additional metrics.
 
 FAQ
+===
 
-1) Where's the value?
+* Where's the value?
 
 When a workload starts swapping, performance falls through the floor.
 Frontswap significantly increases performance in many such workloads by
@@ -117,8 +132,8 @@ A KVM implementation is underway and has been RFC'ed to lkml.  And,
 using frontswap, investigation is also underway on the use of NVM as
 a memory extension technology.
 
-2) Sure there may be performance advantages in some situations, but
-   what's the space/time overhead of frontswap?
+* Sure there may be performance advantages in some situations, but
+  what's the space/time overhead of frontswap?
 
 If CONFIG_FRONTSWAP is disabled, every frontswap hook compiles into
 nothingness and the only overhead is a few extra bytes per swapon'ed
@@ -148,8 +163,8 @@ pressure that can potentially outweigh the other advantages.  A
 backend, such as zcache, must implement policies to carefully (but
 dynamically) manage memory limits to ensure this doesn't happen.
 
-3) OK, how about a quick overview of what this frontswap patch does
-   in terms that a kernel hacker can grok?
+* OK, how about a quick overview of what this frontswap patch does
+  in terms that a kernel hacker can grok?
 
 Let's assume that a frontswap "backend" has registered during
 kernel initialization; this registration indicates that this
@@ -188,9 +203,9 @@ and (potentially) a swap device write are replaced by a "frontswap backend
 store" and (possibly) a "frontswap backend loads", which are presumably much
 faster.
 
-4) Can't frontswap be configured as a "special" swap device that is
-   just higher priority than any real swap device (e.g. like zswap,
-   or maybe swap-over-nbd/NFS)?
+* Can't frontswap be configured as a "special" swap device that is
+  just higher priority than any real swap device (e.g. like zswap,
+  or maybe swap-over-nbd/NFS)?
 
 No.  First, the existing swap subsystem doesn't allow for any kind of
 swap hierarchy.  Perhaps it could be rewritten to accommodate a hierarchy,
@@ -240,9 +255,9 @@ installation, frontswap is useless.  Swapless portable devices
 can still use frontswap but a backend for such devices must configure
 some kind of "ghost" swap device and ensure that it is never used.
 
-5) Why this weird definition about "duplicate stores"?  If a page
-   has been previously successfully stored, can't it always be
-   successfully overwritten?
+* Why this weird definition about "duplicate stores"?  If a page
+  has been previously successfully stored, can't it always be
+  successfully overwritten?
 
 Nearly always it can, but no, sometimes it cannot.  Consider an example
 where data is compressed and the original 4K page has been compressed
@@ -254,7 +269,7 @@ the old data and ensure that it is no longer accessible.  Since the
 swap subsystem then writes the new data to the read swap device,
 this is the correct course of action to ensure coherency.
 
-6) What is frontswap_shrink for?
+* What is frontswap_shrink for?
 
 When the (non-frontswap) swap subsystem swaps out a page to a real
 swap device, that page is only taking up low-value pre-allocated disk
@@ -267,7 +282,7 @@ to "repatriate" pages sent to a remote machine back to the local machine;
 this is driven using the frontswap_shrink mechanism when memory pressure
 subsides.
 
-7) Why does the frontswap patch create the new include file swapfile.h?
+* Why does the frontswap patch create the new include file swapfile.h?
 
 The frontswap code depends on some swap-subsystem-internal data
 structures that have, over the years, moved back and forth between
-- 
2.7.4
