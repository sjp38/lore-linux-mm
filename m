Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 549996B005C
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 22:47:58 -0400 (EDT)
Received: by mail-ye0-f178.google.com with SMTP id q1so513782yen.9
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 19:47:57 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 2/2] drivers: staging: zcache: fix compile warning
Date: Tue,  2 Apr 2013 10:47:43 +0800
Message-Id: <1364870864-13888-2-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1364870864-13888-1-git-send-email-bob.liu@oracle.com>
References: <1364870864-13888-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: konrad.wilk@oracle.com, dan.magenheimer@oracle.com, fengguang.wu@intel.com, linux-mm@kvack.org, akpm@linux-foundation.org, Bob Liu <bob.liu@oracle.com>

Fix below compile warning:
staging/zcache/zcache-main.c: In function a??zcache_autocreate_poola??:
staging/zcache/zcache-main.c:1393:13: warning: a??clia?? may be used uninitialized
in this function [-Wuninitialized]

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 drivers/staging/zcache/zcache-main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index ac75670..7999021 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1341,7 +1341,7 @@ static int zcache_local_new_pool(uint32_t flags)
 int zcache_autocreate_pool(unsigned int cli_id, unsigned int pool_id, bool eph)
 {
 	struct tmem_pool *pool;
-	struct zcache_client *cli;
+	struct zcache_client *cli = NULL;
 	uint32_t flags = eph ? 0 : TMEM_POOL_PERSIST;
 	int ret = -1;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
