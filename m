Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 7B47E6B0032
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 10:36:55 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lj1so1367193pab.17
        for <linux-mm@kvack.org>; Mon, 10 Jun 2013 07:36:54 -0700 (PDT)
Message-ID: <51B5E480.6060303@gmail.com>
Date: Mon, 10 Jun 2013 22:36:48 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: Fix the comment for GFP_ZONE_TABLE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

0xc just means MOVABLE + DMA32, which results in zone DMA32.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/gfp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0f615eb..9b4dd49 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -209,7 +209,7 @@ static inline int allocflags_to_migratetype(gfp_t gfp_flags)
  *       0x9    => DMA or NORMAL (MOVABLE+DMA)
  *       0xa    => MOVABLE (Movable is valid only if HIGHMEM is set too)
  *       0xb    => BAD (MOVABLE+HIGHMEM+DMA)
- *       0xc    => DMA32 (MOVABLE+HIGHMEM+DMA32)
+ *       0xc    => DMA32 (MOVABLE+DMA32)
  *       0xd    => BAD (MOVABLE+DMA32+DMA)
  *       0xe    => BAD (MOVABLE+DMA32+HIGHMEM)
  *       0xf    => BAD (MOVABLE+DMA32+HIGHMEM+DMA)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
