Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 59F156B006E
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 07:37:50 -0400 (EDT)
From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 3/7] mm/slub.c: remove invalid reference to list iterator variable
Date: Sun,  8 Jul 2012 13:37:40 +0200
Message-Id: <1341747464-1772-4-git-send-email-Julia.Lawall@lip6.fr>
In-Reply-To: <1341747464-1772-1-git-send-email-Julia.Lawall@lip6.fr>
References: <1341747464-1772-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kernel-janitors@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

If list_for_each_entry, etc complete a traversal of the list, the iterator
variable ends up pointing to an address at an offset from the list head,
and not a meaningful structure.  Thus this value should not be used after
the end of the iterator.  The patch replaces s->name by al->name, which is
referenced nearby.

This problem was found using Coccinelle (http://coccinelle.lip6.fr/).

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index cc4ed03..ef9bf01 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5395,7 +5395,7 @@ static int __init slab_sysfs_init(void)
 		err = sysfs_slab_alias(al->s, al->name);
 		if (err)
 			printk(KERN_ERR "SLUB: Unable to add boot slab alias"
-					" %s to sysfs\n", s->name);
+					" %s to sysfs\n", al->name);
 		kfree(al);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
