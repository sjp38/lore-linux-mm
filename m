Date: Sun, 29 Jun 2008 19:12:16 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH -mm] kill unused lru functions
Message-Id: <20080629190905.37CF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

several LRU manupuration function is not used now.
So, it can be removed.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/linux/mm_inline.h |   48 ----------------------------------------------
 1 file changed, 48 deletions(-)

Index: b/include/linux/mm_inline.h
===================================================================
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -38,54 +38,6 @@ del_page_from_lru_list(struct zone *zone
 }
 
 static inline void
-add_page_to_inactive_anon_list(struct zone *zone, struct page *page)
-{
-	add_page_to_lru_list(zone, page, LRU_INACTIVE_ANON);
-}
-
-static inline void
-add_page_to_active_anon_list(struct zone *zone, struct page *page)
-{
-	add_page_to_lru_list(zone, page, LRU_ACTIVE_ANON);
-}
-
-static inline void
-add_page_to_inactive_file_list(struct zone *zone, struct page *page)
-{
-	add_page_to_lru_list(zone, page, LRU_INACTIVE_FILE);
-}
-
-static inline void
-add_page_to_active_file_list(struct zone *zone, struct page *page)
-{
-	add_page_to_lru_list(zone, page, LRU_ACTIVE_FILE);
-}
-
-static inline void
-del_page_from_inactive_anon_list(struct zone *zone, struct page *page)
-{
-	del_page_from_lru_list(zone, page, LRU_INACTIVE_ANON);
-}
-
-static inline void
-del_page_from_active_anon_list(struct zone *zone, struct page *page)
-{
-	del_page_from_lru_list(zone, page, LRU_ACTIVE_ANON);
-}
-
-static inline void
-del_page_from_inactive_file_list(struct zone *zone, struct page *page)
-{
-	del_page_from_lru_list(zone, page, LRU_INACTIVE_FILE);
-}
-
-static inline void
-del_page_from_active_file_list(struct zone *zone, struct page *page)
-{
-	del_page_from_lru_list(zone, page, LRU_INACTIVE_FILE);
-}
-
-static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
 	enum lru_list l = LRU_BASE;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
