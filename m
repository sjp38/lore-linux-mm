Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id B46C76B0037
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 23:42:41 -0400 (EDT)
Message-ID: <522014A7.3040002@huawei.com>
Date: Fri, 30 Aug 2013 11:42:31 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 4/5] mm/ia64: use N_MEMORY instead of N_HIGH_MEMORY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@intel.com, laijs@cn.fujitsu.com
Cc: fenghua.yu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Since commit 8219fc48a(mm: node_states: introduce N_MEMORY),
we introduced N_MEMORY, now N_MEMORY stands for the nodes that has any memory,
and N_HIGH_MEMORY stands for the nodes that has normal or high memory.

The code here need to handle with the nodes which have memory,
we should use N_MEMORY instead.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 arch/ia64/kernel/uncached.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index a96bcf8..d2e5545 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -196,7 +196,7 @@ unsigned long uncached_alloc_page(int starting_nid, int n_pages)
 	nid = starting_nid;
 
 	do {
-		if (!node_state(nid, N_HIGH_MEMORY))
+		if (!node_state(nid, N_MEMORY))
 			continue;
 		uc_pool = &uncached_pools[nid];
 		if (uc_pool->pool == NULL)
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
