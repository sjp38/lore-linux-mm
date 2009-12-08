Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0938A600783
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:29 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [10/31] HWPOISON: comment dirty swapcache pages
Message-Id: <20091208211626.5E29EB151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:26 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

AK: Improve comment

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/memory.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c
+++ linux/mm/memory.c
@@ -2540,6 +2540,10 @@ static int do_swap_page(struct mm_struct
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
 	} else if (PageHWPoison(page)) {
+		/*
+		 * hwpoisoned dirty swapcache pages are kept for killing
+		 * owner processes (which may be unknown at hwpoison time)
+		 */
 		ret = VM_FAULT_HWPOISON;
 		delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 		goto out_release;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
