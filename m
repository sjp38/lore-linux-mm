Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id ED1D26B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 14:03:51 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/5] x86-64: remove dead debugging code for !pse setups
Date: Wed, 20 Mar 2013 14:03:30 -0400
Message-Id: <1363802612-32127-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1363802612-32127-1-git-send-email-hannes@cmpxchg.org>
References: <1363802612-32127-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ben Hutchings <ben@decadent.org.uk>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

No need to maintain addr_end and p_end when they are never actually
read anywhere on !pse setups.  Remove the dead code.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/x86/mm/init_64.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 7dd132c..1acba7e 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1312,9 +1312,6 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 
 			if (!p)
 				return -ENOMEM;
-
-			addr_end = addr + PAGE_SIZE;
-			p_end = p + PAGE_SIZE;
 		} else {
 			next = pmd_addr_end(addr, end);
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
