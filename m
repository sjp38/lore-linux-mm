Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 07A706B00E8
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 17:56:34 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so2948567bkw.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2012 14:56:34 -0700 (PDT)
Subject: [PATCH v6 4/7] mm: mark mm-inline functions as __always_inline
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 23 Mar 2012 01:56:31 +0400
Message-ID: <20120322215631.27814.14533.stgit@zurg>
In-Reply-To: <20120322214944.27814.42039.stgit@zurg>
References: <20120322214944.27814.42039.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

GCC sometimes ignores "inline" directives even for small and simple functions.
This supposed to be fixed in gcc 4.7, but it was released only yesterday.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

---

add/remove: 0/0 grow/shrink: 1/5 up/down: 3/-57 (-54)
function                                     old     new   delta
mem_cgroup_charge_common                     253     256      +3
lru_deactivate_fn                            500     498      -2
lru_add_page_tail                            364     361      -3
mem_cgroup_usage_unregister_event            501     493      -8
mem_cgroup_lru_del                            73      65      -8
__mem_cgroup_commit_charge                   676     640     -36
---
 include/linux/mm_inline.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 227fd3e..16d45d9 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -21,7 +21,7 @@ static inline int page_is_file_cache(struct page *page)
 	return !PageSwapBacked(page);
 }
 
-static inline void
+static __always_inline void
 add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
 {
 	struct lruvec *lruvec;
@@ -31,7 +31,7 @@ add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, hpage_nr_pages(page));
 }
 
-static inline void
+static __always_inline void
 del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
 {
 	mem_cgroup_lru_del_list(page, lru);
@@ -61,7 +61,7 @@ static inline enum lru_list page_lru_base_type(struct page *page)
  * Returns the LRU list a page was on, as an index into the array of LRU
  * lists; and clears its Unevictable or Active flags, ready for freeing.
  */
-static inline enum lru_list page_off_lru(struct page *page)
+static __always_inline enum lru_list page_off_lru(struct page *page)
 {
 	enum lru_list lru;
 
@@ -85,7 +85,7 @@ static inline enum lru_list page_off_lru(struct page *page)
  * Returns the LRU list a page should be on, as an index
  * into the array of LRU lists.
  */
-static inline enum lru_list page_lru(struct page *page)
+static __always_inline enum lru_list page_lru(struct page *page)
 {
 	enum lru_list lru;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
