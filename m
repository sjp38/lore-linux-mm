Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id CB5876B004D
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 03:07:03 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id n8so798425lbj.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 00:07:03 -0700 (PDT)
Subject: [PATCH v2 2/2] bug: completely remove code of disabled VM_BUG_ON()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 28 Apr 2012 11:06:59 +0400
Message-ID: <20120428070659.21258.40916.stgit@zurg>
In-Reply-To: <20120425112623.26927.43229.stgit@zurg>
References: <20120425112623.26927.43229.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, "H. Peter Anvin" <hpa@zytor.com>, Cong Wang <xiyou.wangcong@gmail.com>

Even if CONFIG_DEBUG_VM=n gcc genereates code for some VM_BUG_ON()

for example VM_BUG_ON(!PageCompound(page) || !PageHead(page)); in
do_huge_pmd_wp_page() generates 114 bytes of code.
But they mostly disappears when I split this VM_BUG_ON into two:
-VM_BUG_ON(!PageCompound(page) || !PageHead(page));
+VM_BUG_ON(!PageCompound(page));
+VM_BUG_ON(!PageHead(page));
weird... but anyway after this patch code disappears completely.

add/remove: 0/0 grow/shrink: 7/97 up/down: 135/-1784 (-1649)

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

---

add/remove: 0/0 grow/shrink: 7/97 up/down: 135/-1784 (-1649)
function                                     old     new   delta
make_alloc_exact                             160     210     +50
deactivate_slab                             1302    1350     +48
get_page_from_freelist                      2043    2059     +16
split_free_page                              348     356      +8
add_to_swap                                  113     118      +5
__do_fault                                  1152    1157      +5
page_referenced_one                          415     418      +3
lru_cache_add_lru                             66      65      -1
static.get_partial_node                      593     591      -2
static.copy_user_highpage                     93      91      -2
unuse_mm                                    1559    1556      -3
unlock_page                                   49      46      -3
try_to_merge_with_ksm_page                  1540    1537      -3
static.update_isolated_counts                335     332      -3
special_mapping_fault                        130     127      -3
set_page_dirty_balance                        98      95      -3
mem_cgroup_uncharge_cache_page                21      18      -3
mem_cgroup_newpage_charge                     38      35      -3
add_page_to_unevictable_list                 189     186      -3
__get_user_pages                            1287    1284      -3
putback_lru_page                             216     210      -6
follow_page                                 1020    1014      -6
__activate_page                              375     369      -6
update_and_free_page                         121     114      -7
try_to_munlock                                72      65      -7
shmem_truncate_range                        1586    1579      -7
put_page                                      56      49      -7
page_evictable                               145     138      -7
copy_huge_pmd                                411     404      -7
add_to_page_cache_locked                     292     285      -7
__free_pages_bootmem                         122     115      -7
zap_huge_pmd                                 244     236      -8
try_get_mem_cgroup_from_page                 326     318      -8
static.__page_cache_release                  277     269      -8
shmem_find_get_pages_and_swap                353     345      -8
shmem_file_aio_read                          886     878      -8
shmem_add_to_page_cache                      340     332      -8
reuse_swap_page                              239     231      -8
new_page_node                                100      92      -8
mem_cgroup_move_account                      425     417      -8
ksm_migrate_page                              69      61      -8
invalidate_inode_page                        186     178      -8
hugetlb_cow                                 1145    1137      -8
get_page                                      50      42      -8
find_get_pages_tag                           449     441      -8
find_get_pages                               402     394      -8
enabled_show                                 184     176      -8
dequeue_huge_page_node                       149     141      -8
defrag_show                                  184     176      -8
__alloc_pages_nodemask                      2215    2207      -8
follow_trans_huge_pmd                        149     140      -9
__delete_from_swap_cache                      91      82      -9
swap_readpage                                 95      85     -10
static.get_mctgt_type_thp                    178     167     -11
free_pages                                    74      63     -11
__pagevec_lru_add_fn                         243     231     -12
new_node_page                                 57      43     -14
__put_anon_vma                               161     147     -14
rmap_walk_ksm                                321     305     -16
rmap_walk                                    575     559     -16
replace_page_cache_page                      310     294     -16
remove_migration_pte                         632     616     -16
release_pages                                484     468     -16
page_add_new_anon_rmap                       237     221     -16
move_active_pages_to_lru                     382     366     -16
migrate_pages                               1283    1267     -16
migrate_page_copy                            469     453     -16
mem_cgroup_charge_common                     169     153     -16
ksm_scan_thread                             3164    3148     -16
follow_hugetlb_page                          825     809     -16
find_get_pages_contig                        431     415     -16
do_wp_page                                  1829    1813     -16
clear_page_dirty_for_io                      269     253     -16
alloc_fresh_huge_page                        254     238     -16
__mem_cgroup_try_charge                     2425    2409     -16
__isolate_lru_page                           213     197     -16
__add_to_swap_cache                          203     187     -16
lru_add_page_tail                            392     373     -19
__mem_cgroup_begin_update_page_stat          161     140     -21
remove_mapping                                69      46     -23
__split_huge_page_pmd                        180     157     -23
alloc_buddy_huge_page                        333     309     -24
static.isolate_lru_pages                     399     373     -26
split_page                                   101      73     -28
__remove_mapping                             311     283     -28
__mem_cgroup_uncharge_common                 787     757     -30
putback_inactive_pages                       641     609     -32
do_page_add_anon_rmap                        247     215     -32
__get_page_tail                              274     242     -32
try_to_unmap                                 135     100     -35
mem_cgroup_prepare_migration                 443     408     -35
new_slab                                     763     725     -38
hugetlb_acct_memory                          827     786     -41
put_compound_page                            343     301     -42
__rmqueue                                   1093    1050     -43
page_move_anon_rmap                           71      26     -45
free_pcppages_bulk                           956     911     -45
static.migrate_page_move_mapping             563     513     -50
migrate_huge_page_move_mapping               372     322     -50
free_one_page                                819     769     -50
isolate_lru_page                             383     326     -57
shrink_page_list                            2313    2233     -80
khugepaged                                  5028    4947     -81
do_huge_pmd_wp_page                         1747    1628    -119
---
 include/linux/mmdebug.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index c04ecfe..580bd58 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -4,7 +4,7 @@
 #ifdef CONFIG_DEBUG_VM
 #define VM_BUG_ON(cond) BUG_ON(cond)
 #else
-#define VM_BUG_ON(cond) do { (void)(cond); } while (0)
+#define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #endif
 
 #ifdef CONFIG_DEBUG_VIRTUAL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
