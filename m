Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 07A876B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 11:57:35 -0400 (EDT)
Date: Tue, 22 May 2012 17:57:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: memcg-devel git tree updated to 3.4
Message-ID: <20120522155728.GE1663@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

Hi,
JFYI I have just pushed memcg patch queue rebased on top of v3.4.
You can find it at a usual place:
	git@github.com:mstsxfx/memcg-devel.git in since-3.4 branch

I hope I haven't forgotten about anything (there quite some patches that
are sitting in mmotm but I haven't seen them in linux-next - statistics
cleanup by Johannes and lruvec cleanup by Hugh - and I will push them as
soon as they appear there).

Current shortlog on top of v3.4:

Aneesh Kumar K.V (15):
      hugetlb: rename max_hstate to hugetlb_max_hstate
      hugetlbfs: don't use ERR_PTR with VM_FAULT* values
      hugetlbfs: add an inline helper for finding hstate index
      hugetlb: use mmu_gather instead of a temporary linked list for accumulating pages
      hugetlb: avoid taking i_mmap_mutex in unmap_single_vma() for hugetlb
      hugetlb: simplify migrate_huge_page()
      memcg: add HugeTLB extension
      hugetlb: add charge/uncharge calls for HugeTLB alloc/free
      memcg: track resource index in cftype private
      hugetlbfs: add memcg control files for hugetlbfs
      memcg: use scnprintf instead of sprintf
      hugetlbfs: add a list for tracking in-use HugeTLB pages
      memcg: move HugeTLB resource count to parent cgroup on memcg removal
      hugetlb: migrate memcg info from oldpage to new page during migration
      memcg: add memory controller documentation for hugetlb management

David Rientjes (4):
      mm, thp: remove unnecessary ret variable
      mm, thp: allow fallback when pte_alloc_one() fails for huge pmd
      thp, memcg: split hugepage for memcg oom on cow
      mm, thp: drop page_table_lock to uncharge memcg pages

Hugh Dickins (6):
      memcg: fix page migration to reset_owner
      memcg: fix GPF when cgroup removal races with last exit
      memcg swap: mem_cgroup_move_swap_account never needs fixup
      memcg swap: use mem_cgroup_uncharge_swap()
      mm/memcg: scanning_global_lru means mem_cgroup_disabled
      mm/memcg: move reclaim_stat into lruvec

Johannes Weiner (3):
      kernel: cgroup: push rcu read locking from css_is_ancestor() to callsite
      mm: memcg: count pte references from every member of the reclaimed hierarchy
      Documentation: memcg: future proof hierarchical statistics documentation

KAMEZAWA Hiroyuki (2):
      memcg: clear pc->mem_cgorup if necessary.
      memcg: fix/change behavior of shared anon at moving task

Kirill A. Shutemov (4):
      memcg: mark more functions/variables as static
      memcg: remove unused variable
      memcg: mark stat field of mem_cgroup struct as __percpu
      memcg: remove redundant parentheses

Konstantin Khlebnikov (18):
      mm: push lru index into shrink_[in]active_list()
      mm: mark mm-inline functions as __always_inline
      mm: remove lru type checks from __isolate_lru_page()
      mm/memcg: kill mem_cgroup_lru_del()
      mm/memcg: use vm_swappiness from target memory cgroup
      mm: correctly synchronize rss-counters at exit/exec
      mm/vmscan: store "priority" in struct scan_control
      mm: add link from struct lruvec to struct zone
      mm/vmscan: push lruvec pointer into isolate_lru_pages()
      mm/vmscan: push zone pointer into shrink_page_list()
      mm/vmscan: remove update_isolated_counts()
      mm/vmscan: push lruvec pointer into putback_inactive_pages()
      mm/vmscan: replace zone_nr_lru_pages() with get_lruvec_size()
      mm/vmscan: push lruvec pointer into inactive_list_is_low()
      mm/vmscan: push lruvec pointer into shrink_list()
      mm/vmscan: push lruvec pointer into get_scan_count()
      mm/vmscan: push lruvec pointer into should_continue_reclaim()
      mm/vmscan: kill struct mem_cgroup_zone

Mel Gorman (2):
      mm: vmscan: remove lumpy reclaim
      mm: vmscan: remove reclaim_mode_t

Rik van Riel (1):
      mm: remove swap token code

Sha Zhengju (2):
      memcg: make threshold index in the right position
      memcg: revise the position of threshold index while unregistering event

Tejun Heo (15):
      cgroup: deprecate remount option changes
      cgroup: move cgroup_clear_directory() call out of cgroup_populate_dir()
      cgroup: build list of all cgroups under a given cgroupfs_root
      cgroup: implement cgroup_add_cftypes() and friends
      cgroup: merge cft_release_agent cftype array into the base files array
      cgroup: relocate cftype and cgroup_subsys definitions in controllers
      cgroup: convert all non-memcg controllers to the new cftype interface
      memcg: always create memsw files if CONFIG_CGROUP_MEM_RES_CTLR_SWAP
      cgroup: convert memcg controller to the new cftype interface
      cgroup: remove cgroup_add_file[s]()
      cgroup: relocate __d_cgrp() and __d_cft()
      cgroup: introduce struct cfent
      cgroup: implement cgroup_rm_cftypes()
      cgroup: use negative bias on css->refcnt to block css_tryget()
      cgroup: make css->refcnt clearing on cgroup removal optional

Ying Han (2):
      mm: rename is_mlocked_vma() to mlocked_vma_newpage()
      memcg: add mlock statistic in memory.stat

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
