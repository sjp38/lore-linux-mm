Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 18E7A6B0087
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 21:07:23 -0400 (EDT)
Message-ID: <51E34B10.5090005@asianux.com>
Date: Mon, 15 Jul 2013 09:06:24 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] mm/slub.c: beautify code for removing redundancy 'break'
 statement.
References: <51DF5F43.3080408@asianux.com> <51DF778B.8090701@asianux.com> <0000013fd32d0b91-4cab82b6-a24f-42e2-a1d2-ac5df2be6f4c-000000@email.amazonses.com>
In-Reply-To: <0000013fd32d0b91-4cab82b6-a24f-42e2-a1d2-ac5df2be6f4c-000000@email.amazonses.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org

Remove redundancy 'break' statement.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/slub.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 05ab2d5..db93fa4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -878,7 +878,6 @@ static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
 				object_err(s, page, object,
 					"Freechain corrupt");
 				set_freepointer(s, object, NULL);
-				break;
 			} else {
 				slab_err(s, page, "Freepointer corrupt");
 				page->freelist = NULL;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
