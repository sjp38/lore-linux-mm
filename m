Subject: Re: [PATCH 08/32] mm: slb: add knowledge of reserve pages
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20081002131608.091390019@chello.nl>
References: <20081002130504.927878499@chello.nl>
	 <20081002131608.091390019@chello.nl>
Content-Type: text/plain
Date: Fri, 03 Oct 2008 11:32:38 +0200
Message-Id: <1223026358.28938.2.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Because I'm a dork and forgot to refresh...

---
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c
+++ linux-2.6/mm/slob.c
@@ -239,7 +239,7 @@ static int slob_last(slob_t *s)
 
 static void *slob_new_page(gfp_t gfp, int order, int node)
 {
-	void *page;
+	struct page *page;
 
 #ifdef CONFIG_NUMA
 	if (node != -1)
@@ -318,7 +318,7 @@ static void *slob_alloc(size_t size, gfp
 	slob_t *b = NULL;
 	unsigned long flags;
 
-	if (unlikely(slub_reserve)) {
+	if (unlikely(slob_reserve)) {
 		if (!(gfp_to_alloc_flags(gfp) & ALLOC_NO_WATERMARKS))
 			goto grow;
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
