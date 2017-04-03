Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 843EF6B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 12:18:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u195so83331044pgb.1
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 09:18:06 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id o5si14720380pgc.29.2017.04.03.09.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 09:18:05 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id g2so30856199pge.2
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 09:18:05 -0700 (PDT)
From: Hao Lee <haolee.swjtu@gmail.com>
Subject: [PATCH] mm: fix spelling error
Date: Tue,  4 Apr 2017 00:16:55 +0800
Message-Id: <20170403161655.5081-1-haolee.swjtu@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: alexander.h.duyck@intel.com, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, l.stach@pengutronix.de, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haolee.swjtu@gmail.com

Fix variable name error in comments. No code changes.

Signed-off-by: Hao Lee <haolee.swjtu@gmail.com>
---
 include/linux/gfp.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index db373b9..ff3d651 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -297,8 +297,8 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
 
 /*
  * GFP_ZONE_TABLE is a word size bitstring that is used for looking up the
- * zone to use given the lowest 4 bits of gfp_t. Entries are ZONE_SHIFT long
- * and there are 16 of them to cover all possible combinations of
+ * zone to use given the lowest 4 bits of gfp_t. Entries are GFP_ZONES_SHIFT
+ * bits long and there are 16 of them to cover all possible combinations of
  * __GFP_DMA, __GFP_DMA32, __GFP_MOVABLE and __GFP_HIGHMEM.
  *
  * The zone fallback order is MOVABLE=>HIGHMEM=>NORMAL=>DMA32=>DMA.
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
