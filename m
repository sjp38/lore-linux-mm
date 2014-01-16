Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
	by kanga.kvack.org (Postfix) with ESMTP id E78A56B0037
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 06:12:09 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id l9so912066eaj.28
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 03:12:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d46si447880eeo.60.2014.01.16.03.12.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 03:12:08 -0800 (PST)
Date: Thu, 16 Jan 2014 11:12:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: vmstat: Do not display stats for TLB flushes unless
 debugging
Message-ID: <20140116111205.GN4963@suse.de>
References: <1389278098-27154-1-git-send-email-mgorman@suse.de>
 <1389278098-27154-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1389278098-27154-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The patch "x86: mm: Account for TLB flushes only when debugging" removed
vmstat counters related to TLB flushes unless CONFIG_DEBUG_TLBFLUSH was
set from the vm_event_item enum but not the vmstat_text text.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmstat.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7249614..def5dd2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -851,12 +851,14 @@ const char * const vmstat_text[] = {
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
 #endif
+#ifdef CONFIG_DEBUG_TLBFLUSH
 #ifdef CONFIG_SMP
 	"nr_tlb_remote_flush",
 	"nr_tlb_remote_flush_received",
-#endif
+#endif /* CONFIG_SMP */
 	"nr_tlb_local_flush_all",
 	"nr_tlb_local_flush_one",
+#endif /* CONFIG_DEBUG_TLBFLUSH */
 
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
