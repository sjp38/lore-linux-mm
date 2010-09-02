Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AABA26B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 01:54:41 -0400 (EDT)
Date: Thu, 2 Sep 2010 13:54:38 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: [PATCH]vmscan: trival: delete dead code
Message-ID: <20100902055438.GA14705@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

delete dead code.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c391c32..993ab4c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1914,16 +1914,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	}
 
 out:
-	/*
-	 * Now that we've scanned all the zones at this priority level, note
-	 * that level within the zone so that the next thread which performs
-	 * scanning of this zone will immediately start out at this priority
-	 * level.  This affects only the decision whether or not to bring
-	 * mapped pages onto the inactive list.
-	 */
-	if (priority < 0)
-		priority = 0;
-
 	delayacct_freepages_end();
 	put_mems_allowed();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
