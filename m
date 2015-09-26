Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id F22BE6B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 04:07:49 -0400 (EDT)
Received: by laclj5 with SMTP id lj5so23977620lac.3
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 01:07:49 -0700 (PDT)
Received: from mail-la0-x235.google.com (mail-la0-x235.google.com. [2a00:1450:4010:c03::235])
        by mx.google.com with ESMTPS id o9si3358215lag.30.2015.09.26.01.07.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 01:07:48 -0700 (PDT)
Received: by lacdq2 with SMTP id dq2so63947045lac.1
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 01:07:48 -0700 (PDT)
Date: Sat, 26 Sep 2015 10:07:38 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCHv2 2/3] zbud: add compaction callbacks
Message-Id: <20150926100738.9dc61efc39d39533b02b8f5a@gmail.com>
In-Reply-To: <20150926100401.96a36c7cd3c913b063887466@gmail.com>
References: <20150926100401.96a36c7cd3c913b063887466@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ddstreet@ieee.org, akpm@linux-foundation.org, Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Add no-op compaction callbacks to zbud.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/zbud.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/zbud.c b/mm/zbud.c
index fa48bcdf..d67c0aa 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -195,6 +195,16 @@ static void zbud_zpool_unmap(void *pool, unsigned long handle)
 	zbud_unmap(pool, handle);
 }
 
+static unsigned long zbud_zpool_compact(void *pool)
+{
+	return 0;
+}
+
+static unsigned long zbud_zpool_get_compacted(void *pool)
+{
+       return 0;
+}
+
 static u64 zbud_zpool_total_size(void *pool)
 {
 	return zbud_get_pool_size(pool) * PAGE_SIZE;
@@ -210,6 +220,8 @@ static struct zpool_driver zbud_zpool_driver = {
 	.shrink =	zbud_zpool_shrink,
 	.map =		zbud_zpool_map,
 	.unmap =	zbud_zpool_unmap,
+	.compact =	zbud_zpool_compact,
+	.get_num_compacted =	zbud_zpool_get_compacted,
 	.total_size =	zbud_zpool_total_size,
 };
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
