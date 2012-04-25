Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 407DD6B00E7
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 02:22:46 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 5/6] zsmalloc: remove unnecessary type casting
Date: Wed, 25 Apr 2012 15:23:13 +0900
Message-Id: <1335334994-22138-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1335334994-22138-1-git-send-email-minchan@kernel.org>
References: <1335334994-22138-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Let's remove unnecessary type casting of (void *).

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index b7d31cc..ff089f8 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -644,8 +644,7 @@ void zs_free(struct zs_pool *pool, void *obj)
 	spin_lock(&class->lock);
 
 	/* Insert this object in containing zspage's freelist */
-	link = (struct link_free *)((unsigned char *)kmap_atomic(f_page)
-							+ f_offset);
+	link = (struct link_free *)(kmap_atomic(f_page)	+ f_offset);
 	link->next = first_page->freelist;
 	kunmap_atomic(link);
 	first_page->freelist = obj;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
