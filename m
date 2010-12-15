Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 696DB6B008C
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 15:38:39 -0500 (EST)
Received: from spt2.w1.samsung.com (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LDH00GGMLCCEC@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 15 Dec 2010 20:38:36 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LDH00190LCBIX@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Dec 2010 20:38:36 +0000 (GMT)
Date: Wed, 15 Dec 2010 21:34:21 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCHv8 01/12] mm: migrate.c: fix compilation error
In-reply-to: <cover.1292443200.git.m.nazarewicz@samsung.com>
Message-id: 
 <80579787f9493c73f568f6fa609c1238de3f0353.1292443200.git.m.nazarewicz@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

GCC complained about update_mmu_cache() not being defined
in migrate.c.  Including <asm/tlbflush.h> seems to solve the problem.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
---
 mm/migrate.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index fe5a3c6..6ae8a66 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -35,6 +35,8 @@
 #include <linux/hugetlb.h>
 #include <linux/gfp.h>
 
+#include <asm/tlbflush.h>
+
 #include "internal.h"
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
