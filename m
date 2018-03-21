Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B8ABC6B0271
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:24:45 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id q19so3889279qta.17
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:24:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s67si304861qke.363.2018.03.21.12.24.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:24:44 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJLJTe058048
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:24:44 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2guw2hs9px-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:24:43 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:24:40 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 22/32] docs/vm: soft-dirty.txt: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:38 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-23-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/soft-dirty.txt | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/Documentation/vm/soft-dirty.txt b/Documentation/vm/soft-dirty.txt
index 55684d1..cb0cfd6 100644
--- a/Documentation/vm/soft-dirty.txt
+++ b/Documentation/vm/soft-dirty.txt
@@ -1,34 +1,38 @@
-                            SOFT-DIRTY PTEs
+.. _soft_dirty:
 
-  The soft-dirty is a bit on a PTE which helps to track which pages a task
+===============
+Soft-Dirty PTEs
+===============
+
+The soft-dirty is a bit on a PTE which helps to track which pages a task
 writes to. In order to do this tracking one should
 
   1. Clear soft-dirty bits from the task's PTEs.
 
-     This is done by writing "4" into the /proc/PID/clear_refs file of the
+     This is done by writing "4" into the ``/proc/PID/clear_refs`` file of the
      task in question.
 
   2. Wait some time.
 
   3. Read soft-dirty bits from the PTEs.
 
-     This is done by reading from the /proc/PID/pagemap. The bit 55 of the
+     This is done by reading from the ``/proc/PID/pagemap``. The bit 55 of the
      64-bit qword is the soft-dirty one. If set, the respective PTE was
      written to since step 1.
 
 
-  Internally, to do this tracking, the writable bit is cleared from PTEs
+Internally, to do this tracking, the writable bit is cleared from PTEs
 when the soft-dirty bit is cleared. So, after this, when the task tries to
 modify a page at some virtual address the #PF occurs and the kernel sets
 the soft-dirty bit on the respective PTE.
 
-  Note, that although all the task's address space is marked as r/o after the
+Note, that although all the task's address space is marked as r/o after the
 soft-dirty bits clear, the #PF-s that occur after that are processed fast.
 This is so, since the pages are still mapped to physical memory, and thus all
 the kernel does is finds this fact out and puts both writable and soft-dirty
 bits on the PTE.
 
-  While in most cases tracking memory changes by #PF-s is more than enough
+While in most cases tracking memory changes by #PF-s is more than enough
 there is still a scenario when we can lose soft dirty bits -- a task
 unmaps a previously mapped memory region and then maps a new one at exactly
 the same place. When unmap is called, the kernel internally clears PTE values
@@ -36,7 +40,7 @@ including soft dirty bits. To notify user space application about such
 memory region renewal the kernel always marks new memory regions (and
 expanded regions) as soft dirty.
 
-  This feature is actively used by the checkpoint-restore project. You
+This feature is actively used by the checkpoint-restore project. You
 can find more details about it on http://criu.org
 
 
-- 
2.7.4
