Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 15B268E0001
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 08:08:19 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z1-v6so10033646pfn.14
        for <linux-mm@kvack.org>; Sat, 29 Sep 2018 05:08:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u8-v6si159383plk.443.2018.09.29.05.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Sep 2018 05:08:17 -0700 (PDT)
Subject: Patch "x86/numa_emulation: Fix emulated-to-physical node mapping" has been added to the 3.18-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sat, 29 Sep 2018 05:06:07 -0700
Message-ID: <1538222767119177@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 153089328103.27680.14778434392225818887.stgit@dwillia2-desk3.amr.corp.intel.com, alexander.levin@microsoft.com, dan.j.williams@intel.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, mingo@kernel.org, peterz@infradead.org, richard.weiyang@gmail.com, rientjes@google.com, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/numa_emulation: Fix emulated-to-physical node mapping

to the 3.18-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-numa_emulation-fix-emulated-to-physical-node-mapping.patch
and it can be found in the queue-3.18 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Sat Sep 29 04:32:11 PDT 2018
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 6 Jul 2018 09:08:01 -0700
Subject: x86/numa_emulation: Fix emulated-to-physical node mapping

From: Dan Williams <dan.j.williams@intel.com>

[ Upstream commit 3b6c62f363a19ce82bf378187ab97c9dc01e3927 ]

Without this change the distance table calculation for emulated nodes
may use the wrong numa node and report an incorrect distance.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/153089328103.27680.14778434392225818887.stgit@dwillia2-desk3.amr.corp.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/x86/mm/numa_emulation.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/arch/x86/mm/numa_emulation.c
+++ b/arch/x86/mm/numa_emulation.c
@@ -60,7 +60,7 @@ static int __init emu_setup_memblk(struc
 	eb->nid = nid;
 
 	if (emu_nid_to_phys[nid] == NUMA_NO_NODE)
-		emu_nid_to_phys[nid] = nid;
+		emu_nid_to_phys[nid] = pb->nid;
 
 	pb->start += size;
 	if (pb->start >= pb->end) {


Patches currently in stable-queue which might be from dan.j.williams@intel.com are

queue-3.18/x86-numa_emulation-fix-emulated-to-physical-node-mapping.patch
