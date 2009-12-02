From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 07/24] HWPOISON: comment the possible set_page_dirty() race
Date: Wed, 02 Dec 2009 11:12:38 +0800
Message-ID: <20091202043044.432444976@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CE14A60021B
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:37 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-comment-dirty.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

CC: Andi Kleen <andi@firstfloor.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |    2 ++
 1 file changed, 2 insertions(+)

--- linux-mm.orig/mm/memory-failure.c	2009-11-30 11:11:25.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-11-30 11:12:41.000000000 +0800
@@ -667,6 +667,8 @@ static int hwpoison_user_mappings(struct
 	/*
 	 * Propagate the dirty bit from PTEs to struct page first, because we
 	 * need this to decide if we should kill or just drop the page.
+	 * XXX: the dirty test could be racy: set_page_dirty() may not always
+	 * be called inside page lock (it's recommended but not enforced).
 	 */
 	mapping = page_mapping(p);
 	if (!PageDirty(p) && mapping && mapping_cap_writeback_dirty(mapping)) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
