Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 68B0A6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 03:58:09 -0500 (EST)
From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Subject: [PATCH 5/6] mm: add some KERN_CONT markers to continuation lines
Date: Wed, 24 Nov 2010 09:57:49 +0100
Message-Id: <1290589070-854-5-git-send-email-u.kleine-koenig@pengutronix.de>
In-Reply-To: <20101124085645.GW4693@pengutronix.de>
References: <20101124085645.GW4693@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, kernel@pengutronix.de, Arjan van de Ven <arjan@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Cc: linux-mm@kvack.org
Signed-off-by: Uwe Kleine-KA?nig <u.kleine-koenig@pengutronix.de>
---
 mm/percpu.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index efe8168..3356646 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1117,20 +1117,20 @@ static void pcpu_dump_alloc_info(const char *lvl,
 		for (alloc_end += gi->nr_units / upa;
 		     alloc < alloc_end; alloc++) {
 			if (!(alloc % apl)) {
-				printk("\n");
-				printk("%spcpu-alloc: ", lvl);
+				printk(KERN_CONT "\n");
+				printk("%spcpu-alloc:", lvl);
 			}
-			printk("[%0*d] ", group_width, group);
+			printk(KERN_CONT " [%0*d]", group_width, group);
 
 			for (unit_end += upa; unit < unit_end; unit++)
 				if (gi->cpu_map[unit] != NR_CPUS)
-					printk("%0*d ", cpu_width,
+					printk(KERN_CONT " %0*d", cpu_width,
 					       gi->cpu_map[unit]);
 				else
-					printk("%s ", empty_str);
+					printk(KERN_CONT " %s", empty_str);
 		}
 	}
-	printk("\n");
+	printk(KERN_CONT "\n");
 }
 
 /**
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
