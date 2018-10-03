Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4A76B000D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 06:51:18 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e15-v6so2629105pfi.5
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 03:51:18 -0700 (PDT)
Received: from gateway23.websitewelcome.com (gateway23.websitewelcome.com. [192.185.50.185])
        by mx.google.com with ESMTPS id e13-v6si1225205pfb.174.2018.10.03.03.51.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 03:51:17 -0700 (PDT)
Received: from cm13.websitewelcome.com (cm13.websitewelcome.com [100.42.49.6])
	by gateway23.websitewelcome.com (Postfix) with ESMTP id 9F13ED800
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 05:51:16 -0500 (CDT)
Date: Wed, 3 Oct 2018 12:51:14 +0200
From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] zsmalloc: fix fall-through annotation
Message-ID: <20181003105114.GA24423@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Gustavo A. R. Silva" <gustavo@embeddedor.com>

Replace "fallthru" with a proper "fall through" annotation.

This fix is part of the ongoing efforts to enabling
-Wimplicit-fallthrough

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 58886d4..fd4b3a9 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -418,7 +418,7 @@ static void *zs_zpool_map(void *pool, unsigned long handle,
 	case ZPOOL_MM_WO:
 		zs_mm = ZS_MM_WO;
 		break;
-	case ZPOOL_MM_RW: /* fallthru */
+	case ZPOOL_MM_RW: /* fall through */
 	default:
 		zs_mm = ZS_MM_RW;
 		break;
-- 
2.7.4
