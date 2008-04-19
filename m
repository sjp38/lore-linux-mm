From: Dmitri Vorobiev <dmitri.vorobiev@gmail.com>
Subject: [PATCH 1/1] Five functions in mm/page_alloc.c can become static
Date: Sun, 20 Apr 2008 03:58:51 +0400
Message-ID: <1208649531-335-1-git-send-email-dmitri.vorobiev@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759807AbYDSX7P@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-Id: linux-mm.kvack.org

I noticed that the following functions in mm/page_alloc.c
were needlessly defined global:

find_usable_zone_for_movable()
adjust_zone_range_for_zone_movable()
__absent_pages_in_range()
find_min_pfn_for_node()
find_zone_movable_pfns_for_nodes()

These functions can become static, and the purpose of this
patch is to add the necessary keyword to the function
definitions.

This patch survived testing on x86_32, x86_64, and MIPS.
Build tests included allnoconfig, allyesconfig (minus kgdb),
and a few instances of randconfig. Runtime testing was
successfully performed by booting x86_32 and x86_64 boxes
as well as a MIPS-based board up to the shell prompt.

Signed-off-by: Dmitri Vorobiev <dmitri.vorobiev@gmail.com>
---
 mm/page_alloc.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 402a504..92ed55d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3033,7 +3033,7 @@ void __meminit get_pfn_range_for_nid(unsigned int nid,
  * assumption is made that zones within a node are ordered in monotonic
  * increasing memory addresses so that the "highest" populated zone is used
  */
-void __init find_usable_zone_for_movable(void)
+static void __init find_usable_zone_for_movable(void)
 {
 	int zone_index;
 	for (zone_index = MAX_NR_ZONES - 1; zone_index >= 0; zone_index--) {
@@ -3059,7 +3059,7 @@ void __init find_usable_zone_for_movable(void)
  * highest usable zone for ZONE_MOVABLE. This preserves the assumption that
  * zones within a node are in order of monotonic increases memory addresses
  */
-void __meminit adjust_zone_range_for_zone_movable(int nid,
+static void __meminit adjust_zone_range_for_zone_movable(int nid,
 					unsigned long zone_type,
 					unsigned long node_start_pfn,
 					unsigned long node_end_pfn,
@@ -3120,7 +3120,7 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
  * Return the number of holes in a range on a node. If nid is MAX_NUMNODES,
  * then all holes in the requested range will be accounted for.
  */
-unsigned long __meminit __absent_pages_in_range(int nid,
+static unsigned long __meminit __absent_pages_in_range(int nid,
 				unsigned long range_start_pfn,
 				unsigned long range_end_pfn)
 {
@@ -3604,7 +3604,7 @@ static void __init sort_node_map(void)
 }
 
 /* Find the lowest pfn for a node */
-unsigned long __init find_min_pfn_for_node(unsigned long nid)
+static unsigned long __init find_min_pfn_for_node(unsigned long nid)
 {
 	int i;
 	unsigned long min_pfn = ULONG_MAX;
@@ -3676,7 +3676,7 @@ static unsigned long __init early_calculate_totalpages(void)
  * memory. When they don't, some nodes will have more kernelcore than
  * others
  */
-void __init find_zone_movable_pfns_for_nodes(unsigned long *movable_pfn)
+static void __init find_zone_movable_pfns_for_nodes(unsigned long *movable_pfn)
 {
 	int i, nid;
 	unsigned long usable_startpfn;
-- 
1.5.3
