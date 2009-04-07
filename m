Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 93CA85F0010
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 03:45:14 -0400 (EDT)
Message-Id: <20090407072133.526359876@intel.com>
References: <20090407071729.233579162@intel.com>
Date: Tue, 07 Apr 2009 15:17:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 07/14] readahead: apply max_sane_readahead() limit in ondemand_readahead()
Content-Disposition: inline; filename=readahead-sane-max.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Just in case someone aggressively set a huge readahead size.

Cc: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/readahead.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mm.orig/mm/readahead.c
+++ mm/mm/readahead.c
@@ -382,7 +382,7 @@ ondemand_readahead(struct address_space 
 		   bool hit_readahead_marker, pgoff_t offset,
 		   unsigned long req_size)
 {
-	int	max = ra->ra_pages;	/* max readahead pages */
+	unsigned long max = max_sane_readahead(ra->ra_pages);
 	pgoff_t prev_offset;
 	int	sequential;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
