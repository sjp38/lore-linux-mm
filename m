From: Matthew Dobson <colpatch@us.ibm.com>
Subject: [patch 4/9] mempool - Update mempool page allocator user
Date: Wed, 25 Jan 2006 11:40:05 -0800
Message-ID: <1138218005.2092.4.camel@localhost.localdomain>
References: <20060125161321.647368000@localhost.localdomain>
Reply-To: colpatch@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932148AbWAYVh6@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

plain text document attachment (critical_mempools)
Fixup existing mempool users to use the new mempool API, part 1.

Fix the sole "indirect" user of mempool_alloc_pages to be aware of its new
'node_id' argument.

Signed-off-by: Matthew Dobson <colpatch@us.ibm.com>

 highmem.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.16-rc1+critical_mempools/mm/highmem.c
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/mm/highmem.c
+++ linux-2.6.16-rc1+critical_mempools/mm/highmem.c
@@ -30,9 +30,9 @@
 
 static mempool_t *page_pool, *isa_page_pool;
 
-static void *mempool_alloc_pages_isa(gfp_t gfp_mask, void *data)
+static void *mempool_alloc_pages_isa(gfp_t gfp_mask, int node_id, void *data)
 {
-	return mempool_alloc_pages(gfp_mask | GFP_DMA, data);
+	return mempool_alloc_pages(gfp_mask | GFP_DMA, node_id, data);
 }
 


--
