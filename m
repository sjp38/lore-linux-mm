Received: by ewy4 with SMTP id 4so100305ewy.14
        for <linux-mm@kvack.org>; Tue, 09 Dec 2008 14:14:04 -0800 (PST)
Message-ID: <493EEDAB.30403@gmail.com>
Date: Tue, 09 Dec 2008 23:14:03 +0100
From: Roel Kluin <roel.kluin@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 27/31] mm: Make static
References: <493EA286.7080500@gmail.com>
In-Reply-To: <493EA286.7080500@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sparse asked whether these could be static.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 mm/memcontrol.c |    3 ++-
 mm/vmscan.c     |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 866dcc7..b2dbba7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -779,7 +779,8 @@ int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask)
 	return 0;
 }
 
-int mem_cgroup_resize_limit(struct mem_cgroup *memcg, unsigned long long val)
+static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
+		unsigned long long val)
 {
 
 	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 62e7f62..440e2a3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2472,7 +2472,7 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
  * back onto @zone's unevictable list.
  */
 #define SCAN_UNEVICTABLE_BATCH_SIZE 16UL /* arbitrary lock hold batch size */
-void scan_zone_unevictable_pages(struct zone *zone)
+static void scan_zone_unevictable_pages(struct zone *zone)
 {
 	struct list_head *l_unevictable = &zone->lru[LRU_UNEVICTABLE].list;
 	unsigned long scan;
@@ -2514,7 +2514,7 @@ void scan_zone_unevictable_pages(struct zone *zone)
  * that has possibly/probably made some previously unevictable pages
  * evictable.
  */
-void scan_all_zones_unevictable_pages(void)
+static void scan_all_zones_unevictable_pages(void)
 {
 	struct zone *zone;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
