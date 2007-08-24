Received: by fk-out-0910.google.com with SMTP id 18so598875fkq
        for <linux-mm@kvack.org>; Thu, 23 Aug 2007 17:42:28 -0700 (PDT)
Resent-To: Jesper Juhl <jesper.juhl@gmail.com>
Resent-Message-ID: <200708240237.02043.jesper.juhl@gmail.com>
Message-Id: <7a2e58dc05b356f27313d4a116eb92fbe2bb828e.1187912217.git.jesper.juhl@gmail.com>
In-Reply-To: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com>
References: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com>
From: Jesper Juhl <jesper.juhl@gmail.com>
Date: Fri, 24 Aug 2007 02:39:35 +0200
Subject: [PATCH 29/30] mm: No need to cast vmalloc() return value in zone_wait_table_init()
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Jesper Juhl <jesper.juhl@gmail.com>
List-ID: <linux-mm.kvack.org>

vmalloc() returns a void pointer, so there's no need to cast its
return value in mm/page_alloc.c::zone_wait_table_init().

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6427653..a8615c2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2442,7 +2442,7 @@ int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 		 * To use this new node's memory, further consideration will be
 		 * necessary.
 		 */
-		zone->wait_table = (wait_queue_head_t *)vmalloc(alloc_size);
+		zone->wait_table = vmalloc(alloc_size);
 	}
 	if (!zone->wait_table)
 		return -ENOMEM;
-- 
1.5.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
