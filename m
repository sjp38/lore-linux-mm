Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0236B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 11:39:27 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id lf10so2963489pab.0
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 08:39:27 -0800 (PST)
Received: from psmtp.com ([74.125.245.143])
        by mx.google.com with SMTP id dj6si14640667pad.32.2013.11.20.08.39.23
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 08:39:25 -0800 (PST)
Received: by mail-yh0-f44.google.com with SMTP id f64so1883450yha.3
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 08:39:22 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] mm/zswap: change params from hidden to ro
Date: Wed, 20 Nov 2013 11:38:42 -0500
Message-Id: <1384965522-5788-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Seth Jennings <sjennings@variantweb.net>
Cc: Dan Streetman <ddstreet@ieee.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

The "compressor" and "enabled" params are currently hidden,
this changes them to read-only, so userspace can tell if
zswap is enabled or not and see what compressor is in use.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zswap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index d93510c..36b268b 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -77,12 +77,12 @@ static u64 zswap_duplicate_entry;
 **********************************/
 /* Enable/disable zswap (disabled by default, fixed at boot for now) */
 static bool zswap_enabled __read_mostly;
-module_param_named(enabled, zswap_enabled, bool, 0);
+module_param_named(enabled, zswap_enabled, bool, 0444);
 
 /* Compressor to be used by zswap (fixed at boot for now) */
 #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
 static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
-module_param_named(compressor, zswap_compressor, charp, 0);
+module_param_named(compressor, zswap_compressor, charp, 0444);
 
 /* The maximum percentage of memory that the compressed pool can occupy */
 static unsigned int zswap_max_pool_percent = 20;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
