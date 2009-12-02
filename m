From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 08/24] HWPOISON: comment dirty swapcache pages
Date: Wed, 02 Dec 2009 11:12:39 +0800
Message-ID: <20091202043044.572334411@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CFBDC60079E
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:37 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-comment-dirty-swapcache.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

CC: Andi Kleen <andi@firstfloor.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory.c |    4 ++++
 1 file changed, 4 insertions(+)

--- linux-mm.orig/mm/memory.c	2009-11-24 16:50:44.000000000 +0800
+++ linux-mm/mm/memory.c	2009-11-30 10:35:39.000000000 +0800
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
