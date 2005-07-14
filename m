Message-Id: <20050714214352.197408000@homer>
Date: Thu, 14 Jul 2005 23:43:52 +0200
From: domen@coderock.org
Subject: [patch 1/1] mm/swap_state: Fix "nocast type" warnings
Content-Disposition: inline; filename=sparse-mm_swap_state
Sender: owner-linux-mm@kvack.org
From: Victor Fusco <victor@cetuc.puc-rio.br>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Victor Fusco <victor@cetuc.puc-rio.br>, domen@coderock.org
List-ID: <linux-mm.kvack.org>


Fix the sparse warning "implicit cast to nocast type"

File/Subsystem:mm/swap_state.c

Signed-off-by: Victor Fusco <victor@cetuc.puc-rio.br>
Signed-off-by: Domen Puncer <domen@coderock.org>

--

---
 swap_state.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: quilt/mm/swap_state.c
===================================================================
--- quilt.orig/mm/swap_state.c
+++ quilt/mm/swap_state.c
@@ -67,8 +67,8 @@ void show_swap_cache_info(void)
  * __add_to_swap_cache resembles add_to_page_cache on swapper_space,
  * but sets SwapCache flag and private instead of mapping and index.
  */
-static int __add_to_swap_cache(struct page *page,
-		swp_entry_t entry, int gfp_mask)
+static int __add_to_swap_cache(struct page *page, swp_entry_t entry,
+			       unsigned int __nocast gfp_mask)
 {
 	int error;
 

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
