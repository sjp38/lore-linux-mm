Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8596B03A3
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:01:08 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u69so35964701ita.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:01:08 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0016.hostedemail.com. [216.40.44.16])
        by mx.google.com with ESMTPS id r69si2029465ita.60.2017.03.15.19.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:01:07 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/15] mm: page_alloc: Move __meminitdata and __initdata uses
Date: Wed, 15 Mar 2017 19:00:02 -0700
Message-Id: <689086c2457a87c7bb976ccefea42e7e8ec6c741.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

It's preferred to have these after the declarations.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ec9832d15d07..2933a8a11927 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -262,16 +262,16 @@ int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
 int watermark_scale_factor = 10;
 
-static unsigned long __meminitdata nr_kernel_pages;
-static unsigned long __meminitdata nr_all_pages;
-static unsigned long __meminitdata dma_reserve;
+static unsigned long nr_kernel_pages __meminitdata;
+static unsigned long nr_all_pages __meminitdata;
+static unsigned long dma_reserve __meminitdata;
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
-static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
-static unsigned long __initdata required_kernelcore;
-static unsigned long __initdata required_movablecore;
-static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
+static unsigned long arch_zone_lowest_possible_pfn[MAX_NR_ZONES] __meminitdata;
+static unsigned long arch_zone_highest_possible_pfn[MAX_NR_ZONES] __meminitdata;
+static unsigned long required_kernelcore __initdata;
+static unsigned long required_movablecore __initdata;
+static unsigned long zone_movable_pfn[MAX_NUMNODES] __meminitdata;
 static bool mirrored_kernelcore;
 
 /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
