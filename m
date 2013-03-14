Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 5FF556B007D
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:26 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 12/30] thp, mm: add event counters for huge page alloc on write to a file
Date: Thu, 14 Mar 2013 19:50:17 +0200
Message-Id: <1363283435-7666-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/vm_event_item.h |    2 ++
 mm/vmstat.c                   |    2 ++
 2 files changed, 4 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index d4b7a18..04587c4 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -71,6 +71,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_FAULT_FALLBACK,
 		THP_COLLAPSE_ALLOC,
 		THP_COLLAPSE_ALLOC_FAILED,
+		THP_WRITE_ALLOC,
+		THP_WRITE_FAILED,
 		THP_SPLIT,
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 292b1cf..bd59782 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -818,6 +818,8 @@ const char * const vmstat_text[] = {
 	"thp_fault_fallback",
 	"thp_collapse_alloc",
 	"thp_collapse_alloc_failed",
+	"thp_write_alloc",
+	"thp_write_failed",
 	"thp_split",
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
