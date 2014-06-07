Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7202A6B0031
	for <linux-mm@kvack.org>; Sat,  7 Jun 2014 07:09:35 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id cc10so2165252wib.16
        for <linux-mm@kvack.org>; Sat, 07 Jun 2014 04:09:34 -0700 (PDT)
Received: from mailrelay004.isp.belgacom.be (mailrelay004.isp.belgacom.be. [195.238.6.170])
        by mx.google.com with ESMTP id go2si2179260wib.64.2014.06.07.04.09.33
        for <linux-mm@kvack.org>;
        Sat, 07 Jun 2014 04:09:34 -0700 (PDT)
From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1] mm/zswap.c: add __init to zswap_entry_cache_destroy
Date: Sat,  7 Jun 2014 13:08:34 +0200
Message-Id: <1402139314-5573-1-git-send-email-fabf@skynet.be>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Fabian Frederick <fabf@skynet.be>, Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

zswap_entry_cache_destroy is only called by __init init_zswap

This patch also fixes function name
zswap_entry_cache_ s/destory/destroy

Cc: Seth Jennings <sjennings@variantweb.net>
Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 mm/zswap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index aeaef0f..ab7fa0f 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -207,7 +207,7 @@ static int zswap_entry_cache_create(void)
 	return zswap_entry_cache == NULL;
 }
 
-static void zswap_entry_cache_destory(void)
+static void __init zswap_entry_cache_destroy(void)
 {
 	kmem_cache_destroy(zswap_entry_cache);
 }
@@ -926,7 +926,7 @@ static int __init init_zswap(void)
 pcpufail:
 	zswap_comp_exit();
 compfail:
-	zswap_entry_cache_destory();
+	zswap_entry_cache_destroy();
 cachefail:
 	zbud_destroy_pool(zswap_pool);
 error:
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
