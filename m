Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id CEB9C6B0142
	for <linux-mm@kvack.org>; Wed, 29 May 2013 11:09:20 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id wz12so9336800pbc.3
        for <linux-mm@kvack.org>; Wed, 29 May 2013 08:09:20 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH, v2 3/5] mm/CRIS: clean up unused VALID_PAGE()
Date: Wed, 29 May 2013 23:08:54 +0800
Message-Id: <1369840136-1491-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369840136-1491-1-git-send-email-jiang.liu@huawei.com>
References: <1369840136-1491-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, linux-cris-kernel@axis.com

VALID_PAGE() has been removed from kernel long time ago, so clean up it.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: Mikael Starvik <starvik@axis.com>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: linux-cris-kernel@axis.com
Cc: linux-kernel@vger.kernel.org
---
 arch/cris/include/asm/page.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/cris/include/asm/page.h b/arch/cris/include/asm/page.h
index be45ee3..dfc53f9 100644
--- a/arch/cris/include/asm/page.h
+++ b/arch/cris/include/asm/page.h
@@ -51,7 +51,6 @@ typedef struct page *pgtable_t;
  */ 
 
 #define virt_to_page(kaddr)    (mem_map + (((unsigned long)(kaddr) - PAGE_OFFSET) >> PAGE_SHIFT))
-#define VALID_PAGE(page)       (((page) - mem_map) < max_mapnr)
 #define virt_addr_valid(kaddr)	pfn_valid((unsigned)(kaddr) >> PAGE_SHIFT)
 
 /* convert a page (based on mem_map and forward) to a physical address
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
