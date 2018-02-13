Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 52F2B6B0005
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 19:24:31 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id g24so15794924iob.13
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 16:24:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p135sor4174907itg.108.2018.02.12.16.24.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Feb 2018 16:24:30 -0800 (PST)
Date: Mon, 12 Feb 2018 16:24:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] mm, page_alloc: move mirrored_kernelcore to
 __meminitdata
In-Reply-To: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1802121623280.179479@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

mirrored_kernelcore can be in __meminitdata, so move it there.

At the same time, fixup section specifiers to be after the name of the 
variable per checkpatch.
---
 mm/page_alloc.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -264,19 +264,19 @@ int min_free_kbytes = 1024;
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
+static unsigned long arch_zone_lowest_possible_pfn[MAX_NR_ZONES] __meminitdata;
+static unsigned long arch_zone_highest_possible_pfn[MAX_NR_ZONES] __meminitdata;
+static unsigned long required_kernelcore __initdata;
 static unsigned long required_kernelcore_percent __initdata;
-static unsigned long __initdata required_movablecore;
+static unsigned long required_movablecore __initdata;
 static unsigned long required_movablecore_percent __initdata;
-static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
-static bool mirrored_kernelcore;
+static unsigned long zone_movable_pfn[MAX_NUMNODES] __meminitdata;
+static bool mirrored_kernelcore __meminitdata;
 
 /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
 int movable_zone;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
