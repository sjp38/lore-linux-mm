Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D67625F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 03:45:06 -0400 (EDT)
Message-Id: <20090407072133.757876312@intel.com>
References: <20090407071729.233579162@intel.com>
Date: Tue, 07 Apr 2009 15:17:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 09/14] readahead: increase interleaved readahead size
Content-Disposition: inline; filename=readahead-interleaved-size.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Make sure interleaved readahead size is larger than request size.
This also makes readahead window grow up more quickly.

Reported-by: Xu Chenfeng <xcf@ustc.edu.cn>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/readahead.c |    1 +
 1 file changed, 1 insertion(+)

--- mm.orig/mm/readahead.c
+++ mm/mm/readahead.c
@@ -428,6 +428,7 @@ ondemand_readahead(struct address_space 
 
 		ra->start = start;
 		ra->size = start - offset;	/* old async_size */
+		ra->size += req_size;
 		ra->size = get_next_ra_size(ra, max);
 		ra->async_size = ra->size;
 		goto readit;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
