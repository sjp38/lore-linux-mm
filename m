Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AAC66B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 12:37:24 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id v10-v6so16233563oth.16
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 09:37:24 -0700 (PDT)
Received: from sender-pp-092.zoho.com (sender-pp-092.zoho.com. [135.84.80.237])
        by mx.google.com with ESMTPS id 64-v6si13479519oig.226.2018.06.01.09.37.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jun 2018 09:37:23 -0700 (PDT)
From: Huaisheng Ye <yehs2007@zoho.com>
Subject: [PATCH] include/linux/gfp.h: fix the annotation of GFP_ZONE_TABLE
Date: Sat,  2 Jun 2018 00:34:03 +0800
Message-Id: <20180601163403.1032-1-yehs2007@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: chengnt@lenovo.com, Huaisheng Ye <yehs1@lenovo.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Kate Stewart <kstewart@linuxfoundation.org>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <willy@infradead.org>

From: Huaisheng Ye <yehs1@lenovo.com>

When bit is equal to 0x4, it means OPT_ZONE_DMA32 should be got
from GFP_ZONE_TABLE.
OPT_ZONE_DMA32 shall be equal to ZONE_DMA32 or ZONE_NORMAL
according to the status of CONFIG_ZONE_DMA32.

Similarly, when bit is equal to 0xc, that means OPT_ZONE_DMA32
should be got with an allocation policy GFP_MOVABLE.
So ZONE_DMA32 or ZONE_NORMAL is the possible result value.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Kate Stewart <kstewart@linuxfoundation.org>
Cc: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>
---
 include/linux/gfp.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 1a4582b..3f1b3dc 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -343,7 +343,7 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
  *       0x1    => DMA or NORMAL
  *       0x2    => HIGHMEM or NORMAL
  *       0x3    => BAD (DMA+HIGHMEM)
- *       0x4    => DMA32 or DMA or NORMAL
+ *       0x4    => DMA32 or NORMAL
  *       0x5    => BAD (DMA+DMA32)
  *       0x6    => BAD (HIGHMEM+DMA32)
  *       0x7    => BAD (HIGHMEM+DMA32+DMA)
@@ -351,7 +351,7 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
  *       0x9    => DMA or NORMAL (MOVABLE+DMA)
  *       0xa    => MOVABLE (Movable is valid only if HIGHMEM is set too)
  *       0xb    => BAD (MOVABLE+HIGHMEM+DMA)
- *       0xc    => DMA32 (MOVABLE+DMA32)
+ *       0xc    => DMA32 or NORMAL (MOVABLE+DMA32)
  *       0xd    => BAD (MOVABLE+DMA32+DMA)
  *       0xe    => BAD (MOVABLE+DMA32+HIGHMEM)
  *       0xf    => BAD (MOVABLE+DMA32+HIGHMEM+DMA)
-- 
1.8.3.1
