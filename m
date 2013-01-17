Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 86C536B000C
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 12:26:51 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 5/5] staging: zcache: fix uninitialized variable compile warning
Date: Thu, 17 Jan 2013 09:26:37 -0800
Message-Id: <1358443597-9845-6-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
References: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com

Fix unitialized variable in zcache which generates warning during build

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/zcache/zcache-main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index a09dd5c..6ab13e1 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1346,7 +1346,7 @@ static int zcache_local_new_pool(uint32_t flags)
 int zcache_autocreate_pool(unsigned int cli_id, unsigned int pool_id, bool eph)
 {
 	struct tmem_pool *pool;
-	struct zcache_client *cli;
+	struct zcache_client *cli = NULL;
 	uint32_t flags = eph ? 0 : TMEM_POOL_PERSIST;
 	int ret = -1;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
