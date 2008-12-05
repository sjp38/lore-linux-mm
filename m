From: Nick Andrew <nick@nick-andrew.net>
Subject: [PATCH] Fix incorrect use of loose in slub.c
Date: Fri, 05 Dec 2008 14:08:08 +1100
Message-ID: <20081205030808.32351.74011.stgit@marcab.local.tull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Greg Kroah-Hartman <gregkh@suse.de>, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Nick Andrew <nick@nick-andrew.net>
List-ID: <linux-mm.kvack.org>

Fix incorrect use of loose in slub.c

It should be 'lose', not 'loose'.

Signed-off-by: Nick Andrew <nick@nick-andrew.net>
---

 mm/slub.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/mm/slub.c b/mm/slub.c
index 749588a..d918e3a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -692,7 +692,7 @@ static int check_object(struct kmem_cache *s, struct page *page,
 	if (!check_valid_pointer(s, page, get_freepointer(s, p))) {
 		object_err(s, page, p, "Freepointer corrupt");
 		/*
-		 * No choice but to zap it and thus loose the remainder
+		 * No choice but to zap it and thus lose the remainder
 		 * of the free objects in this slab. May cause
 		 * another error because the object count is now wrong.
 		 */
@@ -4345,7 +4345,7 @@ static void sysfs_slab_remove(struct kmem_cache *s)
 
 /*
  * Need to buffer aliases during bootup until sysfs becomes
- * available lest we loose that information.
+ * available lest we lose that information.
  */
 struct saved_alias {
 	struct kmem_cache *s;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
