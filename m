Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id BE5A06B004D
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 02:22:44 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/6] zsmalloc: remove unnecessary alignment
Date: Wed, 25 Apr 2012 15:23:10 +0900
Message-Id: <1335334994-22138-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1335334994-22138-1-git-send-email-minchan@kernel.org>
References: <1335334994-22138-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

It isn't necessary to align pool size with PAGE_SIZE.
If I missed something, please let me know it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 504b6c2..b99ad9e 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -489,14 +489,13 @@ fail:
 
 struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 {
-	int i, error, ovhd_size;
+	int i, error;
 	struct zs_pool *pool;
 
 	if (!name)
 		return NULL;
 
-	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
-	pool = kzalloc(ovhd_size, GFP_KERNEL);
+	pool = kzalloc(sizeof(*pool), GFP_KERNEL);
 	if (!pool)
 		return NULL;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
