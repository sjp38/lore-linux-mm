Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 24B396B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 02:45:22 -0500 (EST)
Received: by iahk25 with SMTP id k25so2875413iah.14
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 23:45:21 -0800 (PST)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/1] vmalloc: Remove static declaration of va from __get_vm_area_node
Date: Thu,  8 Dec 2011 13:20:21 +0530
Message-Id: <1323330621-31254-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, David Vrabel <david.vrabel@citrix.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

Static storage is not required for the struct vmap_area in
__get_vm_area_node.

Removing "static" to store this variable on the stack instead.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/vmalloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3231bf3..173562c 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1290,7 +1290,7 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 		unsigned long align, unsigned long flags, unsigned long start,
 		unsigned long end, int node, gfp_t gfp_mask, void *caller)
 {
-	static struct vmap_area *va;
+	struct vmap_area *va;
 	struct vm_struct *area;
 
 	BUG_ON(in_interrupt());
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
