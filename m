Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25C586B0275
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:24:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id c11so3072786wrf.4
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:24:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o56si1833816edc.525.2018.03.21.12.24.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:24:53 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJMR4H078696
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:24:52 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2guwg9g3hy-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:24:52 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:24:49 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 24/32] docs/vm: swap_numa.txt: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:40 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-25-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/swap_numa.txt | 55 +++++++++++++++++++++++++-----------------
 1 file changed, 33 insertions(+), 22 deletions(-)

diff --git a/Documentation/vm/swap_numa.txt b/Documentation/vm/swap_numa.txt
index d5960c9..e0466f2 100644
--- a/Documentation/vm/swap_numa.txt
+++ b/Documentation/vm/swap_numa.txt
@@ -1,5 +1,8 @@
+.. _swap_numa:
+
+===========================================
 Automatically bind swap device to numa node
--------------------------------------------
+===========================================
 
 If the system has more than one swap device and swap device has the node
 information, we can make use of this information to decide which swap
@@ -7,15 +10,16 @@ device to use in get_swap_pages() to get better performance.
 
 
 How to use this feature
------------------------
+=======================
 
 Swap device has priority and that decides the order of it to be used. To make
 use of automatically binding, there is no need to manipulate priority settings
 for swap devices. e.g. on a 2 node machine, assume 2 swap devices swapA and
 swapB, with swapA attached to node 0 and swapB attached to node 1, are going
-to be swapped on. Simply swapping them on by doing:
-# swapon /dev/swapA
-# swapon /dev/swapB
+to be swapped on. Simply swapping them on by doing::
+
+	# swapon /dev/swapA
+	# swapon /dev/swapB
 
 Then node 0 will use the two swap devices in the order of swapA then swapB and
 node 1 will use the two swap devices in the order of swapB then swapA. Note
@@ -24,32 +28,39 @@ that the order of them being swapped on doesn't matter.
 A more complex example on a 4 node machine. Assume 6 swap devices are going to
 be swapped on: swapA and swapB are attached to node 0, swapC is attached to
 node 1, swapD and swapE are attached to node 2 and swapF is attached to node3.
-The way to swap them on is the same as above:
-# swapon /dev/swapA
-# swapon /dev/swapB
-# swapon /dev/swapC
-# swapon /dev/swapD
-# swapon /dev/swapE
-# swapon /dev/swapF
-
-Then node 0 will use them in the order of:
-swapA/swapB -> swapC -> swapD -> swapE -> swapF
+The way to swap them on is the same as above::
+
+	# swapon /dev/swapA
+	# swapon /dev/swapB
+	# swapon /dev/swapC
+	# swapon /dev/swapD
+	# swapon /dev/swapE
+	# swapon /dev/swapF
+
+Then node 0 will use them in the order of::
+
+	swapA/swapB -> swapC -> swapD -> swapE -> swapF
+
 swapA and swapB will be used in a round robin mode before any other swap device.
 
-node 1 will use them in the order of:
-swapC -> swapA -> swapB -> swapD -> swapE -> swapF
+node 1 will use them in the order of::
+
+	swapC -> swapA -> swapB -> swapD -> swapE -> swapF
+
+node 2 will use them in the order of::
+
+	swapD/swapE -> swapA -> swapB -> swapC -> swapF
 
-node 2 will use them in the order of:
-swapD/swapE -> swapA -> swapB -> swapC -> swapF
 Similaly, swapD and swapE will be used in a round robin mode before any
 other swap devices.
 
-node 3 will use them in the order of:
-swapF -> swapA -> swapB -> swapC -> swapD -> swapE
+node 3 will use them in the order of::
+
+	swapF -> swapA -> swapB -> swapC -> swapD -> swapE
 
 
 Implementation details
-----------------------
+======================
 
 The current code uses a priority based list, swap_avail_list, to decide
 which swap device to use and if multiple swap devices share the same
-- 
2.7.4
