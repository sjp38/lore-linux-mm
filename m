Date: Fri, 30 Sep 2005 22:07:16 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH]Remove pgdat list ver.2  [2/2]
Message-Id: <20050930210141.701B.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

-------------------
This is for ia64. Pgdat insertion is not necessary.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


Index: pgdat_link/arch/ia64/mm/discontig.c
===================================================================
--- pgdat_link.orig/arch/ia64/mm/discontig.c	2005-09-30 19:04:10.070261497 +0900
+++ pgdat_link/arch/ia64/mm/discontig.c	2005-09-30 19:06:42.850533063 +0900
@@ -376,30 +376,6 @@ static void __init *memory_less_node_all
 	return ptr;
 }
 
-/**
- * pgdat_insert - insert the pgdat into global pgdat_list
- * @pgdat: the pgdat for a node.
- */
-static void __init pgdat_insert(pg_data_t *pgdat)
-{
-	pg_data_t *prev = NULL, *next;
-
-	for_each_pgdat(next)
-		if (pgdat->node_id < next->node_id)
-			break;
-		else
-			prev = next;
-
-	if (prev) {
-		prev->pgdat_next = pgdat;
-		pgdat->pgdat_next = next;
-	} else {
-		pgdat->pgdat_next = pgdat_list;
-		pgdat_list = pgdat;
-	}
-
-	return;
-}
 
 /**
  * memory_less_nodes - allocate and initialize CPU only nodes pernode
@@ -695,11 +671,5 @@ void __init paging_init(void)
 				    pfn_offset, zholes_size);
 	}
 
-	/*
-	 * Make memory less nodes become a member of the known nodes.
-	 */
-	for_each_node_mask(node, memory_less_mask)
-		pgdat_insert(mem_data[node].pgdat);
-
 	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }


-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
