Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 366136B0006
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 05:43:57 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 1/3] mm: Remove unused parameter of pages_correctly_reserved()
Date: Mon, 15 Apr 2013 17:46:45 +0800
Message-Id: <1366019207-27818-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1366019207-27818-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1366019207-27818-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, mgorman@suse.de, tj@kernel.org, liwanp@linux.vnet.ibm.com
Cc: tangchen@cn.fujitsu.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

nr_pages is not used in pages_correctly_reserved().
So remove it.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Wang Shilong <wangsl-fnst@cn.fujitsu.com>
Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/base/memory.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index a51007b..f926b9c 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -217,8 +217,7 @@ int memory_isolate_notify(unsigned long val, void *v)
  * The probe routines leave the pages reserved, just as the bootmem code does.
  * Make sure they're still that way.
  */
-static bool pages_correctly_reserved(unsigned long start_pfn,
-					unsigned long nr_pages)
+static bool pages_correctly_reserved(unsigned long start_pfn)
 {
 	int i, j;
 	struct page *page;
@@ -266,7 +265,7 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
 
 	switch (action) {
 		case MEM_ONLINE:
-			if (!pages_correctly_reserved(start_pfn, nr_pages))
+			if (!pages_correctly_reserved(start_pfn))
 				return -EBUSY;
 
 			ret = online_pages(start_pfn, nr_pages, online_type);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
