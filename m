Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4D83F6B02A5
	for <linux-mm@kvack.org>; Sun,  8 Aug 2010 05:50:24 -0400 (EDT)
Received: by pxi12 with SMTP id 12so825245pxi.14
        for <linux-mm@kvack.org>; Sun, 08 Aug 2010 02:50:23 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] percpu : fix the memory leak
Date: Sun,  8 Aug 2010 17:53:17 +0800
Message-Id: <1281261197-8816-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: tj@kernel.org, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

	The origin code did not free the old map.
The patch fixes it.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/percpu.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index e61dc2c..d1c94e3 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -393,6 +393,7 @@ static int pcpu_extend_area_map(struct pcpu_chunk *chunk, int new_alloc)
 		goto out_unlock;
 
 	old_size = chunk->map_alloc * sizeof(chunk->map[0]);
+	old	 = chunk->map;
 	memcpy(new, chunk->map, old_size);
 
 	chunk->map_alloc = new_alloc;
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
