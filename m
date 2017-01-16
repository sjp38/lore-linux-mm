From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH] mm/slub: Add a dump_stack() to the unexpected GFP check
Date: Mon, 16 Jan 2017 10:16:43 +0100
Message-ID: <20170116091643.15260-1-bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

From: Borislav Petkov <bp@suse.de>

We wanna know who's doing such a thing. Like slab.c does that.

Signed-off-by: Borislav Petkov <bp@suse.de>
---
 mm/slub.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/slub.c b/mm/slub.c
index 067598a00849..1b0fa7625d6d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1623,6 +1623,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 		flags &= ~GFP_SLAB_BUG_MASK;
 		pr_warn("Unexpected gfp: %#x (%pGg). Fixing up to gfp: %#x (%pGg). Fix your code!\n",
 				invalid_mask, &invalid_mask, flags, &flags);
+		dump_stack();
 	}
 
 	return allocate_slab(s,
-- 
2.11.0
