Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 3E3D86B000A
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 00:25:56 -0500 (EST)
Message-ID: <5111E72C.5000709@cn.fujitsu.com>
Date: Wed, 06 Feb 2013 13:16:28 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/7] ia64: use %ld to print pages calculated in nr_free_buffer_pages
References: <5111E612.4010907@cn.fujitsu.com>
In-Reply-To: <5111E612.4010907@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Now the function nr_free_buffer_pages returns unsigned long, so
use %ld to print its return value.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/ia64/mm/contig.c    |    2 +-
 arch/ia64/mm/discontig.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 1516d1d..80dab50 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -93,7 +93,7 @@ void show_mem(unsigned int filter)
 	printk(KERN_INFO "%d pages swap cached\n", total_cached);
 	printk(KERN_INFO "Total of %ld pages in page table cache\n",
 	       quicklist_total_size());
-	printk(KERN_INFO "%d free buffer pages\n", nr_free_buffer_pages());
+	printk(KERN_INFO "%ld free buffer pages\n", nr_free_buffer_pages());
 }
 
 
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index c641333..b8a8fa3 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -666,7 +666,7 @@ void show_mem(unsigned int filter)
 	printk(KERN_INFO "%d pages swap cached\n", total_cached);
 	printk(KERN_INFO "Total of %ld pages in page table cache\n",
 	       quicklist_total_size());
-	printk(KERN_INFO "%d free buffer pages\n", nr_free_buffer_pages());
+	printk(KERN_INFO "%ld free buffer pages\n", nr_free_buffer_pages());
 }
 
 /**
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
