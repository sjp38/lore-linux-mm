Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 89D576B0044
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 03:53:52 -0400 (EDT)
Received: by lbbgg6 with SMTP id gg6so999112lbb.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 00:53:50 -0700 (PDT)
Subject: [PATCH next 00/12] mm: replace struct mem_cgroup_zone with struct
 lruvec
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 26 Apr 2012 11:53:44 +0400
Message-ID: <20120426074632.18961.17803.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patchset depends on Johannes Weiner's patch
"mm: memcg: count pte references from every member of the reclaimed hierarchy".

bloat-o-meter delta for patches 2..12

add/remove: 6/6 grow/shrink: 6/14 up/down: 4414/-4625 (-211)
function                                     old     new   delta
shrink_page_list                               -    2270   +2270
shrink_lruvec                                  -    1386   +1386
update_isolated_counts                         -     376    +376
lruvec_init                                    -     195    +195
get_lruvec_size                                -      61     +61
balance_pgdat                               1856    1904     +48
mem_cgroup_shrink_node_zone                  283     302     +19
shrink_inactive_list                         985    1003     +18
mem_cgroup_get_lruvec_size                     -      18     +18
mem_cgroup_create                           1453    1468     +15
shrink_active_list                           824     830      +6
shrink_zone                                  147     149      +2
mem_control_stat_show                        750     745      -5
mem_cgroup_zone_lruvec                        72      67      -5
mem_cgroup_get_reclaim_stat_from_page        108     103      -5
mem_cgroup_nr_lru_pages                      185     179      -6
inactive_anon_is_low                         110     103      -7
test_mem_cgroup_node_reclaimable             200     192      -8
__mem_cgroup_free                            389     381      -8
putback_inactive_pages                       634     620     -14
mem_control_numa_stat_show                  1015    1001     -14
static.isolate_lru_pages                     419     403     -16
mem_cgroup_force_empty                      1694    1678     -16
get_reclaim_stat                              30       -     -30
mem_cgroup_zone_nr_lru_pages                  64       -     -64
free_area_init_node                          849     784     -65
mem_cgroup_inactive_anon_is_low              177      84     -93
mem_cgroup_inactive_file_is_low              140      31    -109
zone_nr_lru_pages                            110       -    -110
static.update_isolated_counts                376       -    -376
shrink_mem_cgroup_zone                      1381       -   -1381
static.shrink_page_list                     2293       -   -2293

---

Konstantin Khlebnikov (12):
      mm/vmscan: store "priority" in struct scan_control
      mm: add link from struct lruvec to struct zone
      mm/vmscan: push lruvec pointer into isolate_lru_pages()
      mm/vmscan: push zone pointer into shrink_page_list()
      mm/vmscan: push zone pointer into update_isolated_counts()
      mm/vmscan: push lruvec pointer into putback_inactive_pages()
      mm/vmscan: replace zone_nr_lru_pages() with get_lruvec_size()
      mm/vmscan: push lruvec pointer into inactive_list_is_low()
      mm/vmscan: push lruvec pointer into shrink_list()
      mm/vmscan: push lruvec pointer into get_scan_count()
      mm/vmscan: push lruvec pointer into should_continue_reclaim()
      mm/vmscan: kill struct mem_cgroup_zone


 include/linux/memcontrol.h |   16 +--
 include/linux/mmzone.h     |   14 ++
 mm/memcontrol.c            |   33 +++--
 mm/mmzone.c                |   14 ++
 mm/page_alloc.c            |    8 -
 mm/vmscan.c                |  277 ++++++++++++++++++++------------------------
 6 files changed, 177 insertions(+), 185 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
