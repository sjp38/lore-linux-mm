Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 744E66B0038
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 05:56:59 -0400 (EDT)
Message-ID: <51B1ADC7.7060708@cn.fujitsu.com>
Date: Fri, 07 Jun 2013 17:54:15 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] mm, vmalloc: Remove unused purge_fragmented_blocks_thiscpu
References: <51B1AD2F.4030702@cn.fujitsu.com>
In-Reply-To: <51B1AD2F.4030702@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: chanho.min@lge.com, Johannes Weiner <hannes@cmpxchg.org>, iamjoonsoo.kim@lge.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

This function is nowhere used now, so remove it.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/vmalloc.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b8abcba..5c037b9 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -891,11 +891,6 @@ static void purge_fragmented_blocks(int cpu)
 	}
 }
 
-static void purge_fragmented_blocks_thiscpu(void)
-{
-	purge_fragmented_blocks(smp_processor_id());
-}
-
 static void purge_fragmented_blocks_allcpus(void)
 {
 	int cpu;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
