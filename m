Message-ID: <48F3AE45.90104@inria.fr>
Date: Mon, 13 Oct 2008 22:23:33 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: [PATCH 5/5] mm: move_pages: no need to set pp->page to ZERO_PAGE(0)
 by default
References: <48F3AD47.1050301@inria.fr>
In-Reply-To: <48F3AD47.1050301@inria.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-ID: <linux-mm.kvack.org>

pp->page is never used when not set to the right page, so there is
no need to set it to ZERO_PAGE(0) by default.

Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
---
 mm/migrate.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 175e242..2453444 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -878,12 +878,6 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		struct vm_area_struct *vma;
 		struct page *page;
 
-		/*
-		 * A valid page pointer that will not match any of the
-		 * pages that will be moved.
-		 */
-		pp->page = ZERO_PAGE(0);
-
 		err = -EFAULT;
 		vma = find_vma(mm, pp->addr);
 		if (!vma || !vma_migratable(vma))
-- 
1.5.6.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
