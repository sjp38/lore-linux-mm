Message-Id: <200405222207.i4MM7Sr13001@mail.osdl.org>
Subject: [patch 22/57] numa api core: use SLAB_PANIC
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:06:57 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>



---

 25-akpm/mm/mempolicy.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff -puN mm/mempolicy.c~numa-api-core-slab-panic mm/mempolicy.c
--- 25/mm/mempolicy.c~numa-api-core-slab-panic	2004-05-22 14:56:24.948298808 -0700
+++ 25-akpm/mm/mempolicy.c	2004-05-22 14:59:40.410584024 -0700
@@ -1004,14 +1004,11 @@ static __init int numa_policy_init(void)
 {
 	policy_cache = kmem_cache_create("numa_policy",
 					 sizeof(struct mempolicy),
-					 0, 0, NULL, NULL);
+					 0, SLAB_PANIC, NULL, NULL);
 
 	sn_cache = kmem_cache_create("shared_policy_node",
 				     sizeof(struct sp_node),
-				     0, 0, NULL, NULL);
-
-	if (!policy_cache || !sn_cache)
-		panic("Cannot create NUMA policy cache");
+				     0, SLAB_PANIC, NULL, NULL);
 	return 0;
 }
 module_init(numa_policy_init);

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
