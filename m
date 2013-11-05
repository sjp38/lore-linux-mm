Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 89D426B003A
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 06:00:50 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id w10so8237443pde.31
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 03:00:50 -0800 (PST)
Received: from psmtp.com ([74.125.245.111])
        by mx.google.com with SMTP id cx4si13201770pbc.89.2013.11.05.03.00.47
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 03:00:48 -0800 (PST)
Date: Tue, 5 Nov 2013 12:00:43 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: since-3.12 branch opened for mm git tree (was: Re: mmotm
 2013-11-04-16-11 uploaded)
Message-ID: <20131105110043.GA5882@dhcp22.suse.cz>
References: <20131105001242.C881431C25D@corp2gmr1-1.hot.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131105001242.C881431C25D@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

Hi,
mm git tree goes on again after some pause while I was on vacation.

I have just created since-3.12 branch in mm git tree
(http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary). It
is based on v3.12 tag in Linus tree and mmotm 2013-11-04-16-11.

I have merged Tejun's cgroups/for-3.13 branch to pull css_id changes.

As usual mmotm trees are tagged with signed tag
(finger print BB43 1E25 7FB8 660F F2F1  D22D 48E2 09A2 B310 E347)

The current shortlog says:
Akira Takeuchi (1):
      mm: ensure get_unmapped_area() returns higher address than mmap_min_addr

Andrew Morton (1):
      mm-thp-khugepaged-add-policy-for-finding-target-node-fix

Bob Liu (2):
      mm: thp: cleanup: mv alloc_hugepage to better place
      mm: thp: khugepaged: add policy for finding target node

Catalin Marinas (1):
      mm: kmemleak: avoid false negatives on vmalloc'ed objects

Christian Hesse (1):
      Documentation/vm/zswap.txt: fix typos

Daeseok Youn (1):
      mm/bootmem.c: remove unused local `map'

Damien Ramonda (1):
      readahead: fix sequential read cache miss detection

David Rientjes (1):
      mm, mempolicy: make mpol_to_str robust and always succeed

Fengguang Wu (1):
      swap: swapin_nr_pages() can be static

Greg Thelen (1):
      memcg: refactor mem_control_numa_stat_show()

Heiko Carstens (2):
      mmap: arch_get_unmapped_area(): use proper mmap base for bottom up direction
      s390/mmap: randomize mmap base for bottom up direction

Jan Kara (4):
      writeback: do not sync data dirtied after sync start
      writeback: use older_than_this_is_set instead of magic older_than_this == 0
      writeback-do-not-sync-data-dirtied-after-sync-start-fix-2.txt
      writeback-do-not-sync-data-dirtied-after-sync-start-fix-3

Jerome Marchand (1):
      mm/compaction.c: update comment about zone lock in isolate_freepages_block

Jianguo Wu (4):
      mm/vmalloc: use NUMA_NO_NODE
      mm/huge_memory.c: fix stale comments of transparent_hugepage_flags
      mm/arch: use NUMA_NO_NODE
      mm/mempolicy: use NUMA_NO_NODE

Joe Perches (1):
      ksm: Remove redundant __GFP_ZERO from kcalloc

KOSAKI Motohiro (3):
      mm: fix page_group_by_mobility_disabled breakage
      mm: get rid of unnecessary overhead of trace_mm_page_alloc_extfrag()
      mm: __rmqueue_fallback() should respect pageblock type

Krzysztof Kozlowski (2):
      frontswap: enable call to invalidate area on swapoff
      swap: fix setting PAGE_SIZE blocksize during swapoff/swapon race

Li Zefan (5):
      memcg: convert to use cgroup_is_descendant()
      memcg: convert to use cgroup id
      memcg: fail to create cgroup if the cgroup id is too big
      memcg: stop using css id
      cgroup: kill css_id

Mel Gorman (1):
      mm: do not walk all of system memory during show_mem

Michal Hocko (1):
      Merge remote-tracking branch 'cgroups/for-3.13' into mmotm

Naoya Horiguchi (5):
      mm: remove obsolete comments about page table lock
      mm/memory-failure.c: move set_migratetype_isolate() outside get_any_page()
      /proc/pid/smaps: show VM_SOFTDIRTY flag in VmFlags line
      smaps-show-vm_softdirty-flag-in-vmflags-line-fix
      tools/vm/page-types.c: support KPF_SOFTDIRTY bit

Qiang Huang (4):
      mm: add a helper function to check may oom condition
      memcg, kmem: Use is_root_cache instead of hard code
      memcg, kmem: rename cache_from_memcg to cache_from_memcg_idx
      memcg, kmem: use cache_from_memcg_idx instead of hard code

Robin Holt (1):
      mm/nobootmem.c: have __free_pages_memory() free in larger chunks.

Serge Hallyn (1):
      device_cgroup: remove can_attach

Seth Jennings (1):
      mm/swapfile.c: fix comment typos

Shaohua Li (1):
      swap: add a simple detector for inappropriate swapin readahead

Tang Chen (6):
      mm/memblock.c: factor out of top-down allocation
      mm/memblock.c: introduce bottom-up allocation mode
      x86/mm: factor out of top-down direct mapping setup
      x86/mem-hotplug: support initialize page tables in bottom-up
      x86, acpi, crash, kdump: do reserve_crashkernel() after SRAT is parsed.
      mem-hotplug: introduce movable_node boot option

Toshi Kani (3):
      cpu/mem hotplug: add try_online_node() for cpu_up()
      mm: set N_CPU to node_states during boot
      mm: clear N_CPU from node_states at CPU offline

Wanpeng Li (4):
      mm/vmalloc: don't set area->caller twice
      mm/vmalloc: fix show vmap_area information race with vmap_area tear down
      mm/vmalloc: revert "mm/vmalloc.c: check VM_UNINITIALIZED flag in s_show instead of show_numa_info"
      revert mm/vmalloc.c: emit the failure message before return

Weijie Yang (3):
      mm/zswap: avoid unnecessary page scanning
      mm/zswap: bugfix: memory leak when invalidate and reclaim occur concurrently
      mm/zswap: refactor the get/put routines

Xishi Qiu (7):
      mm/arch: use __free_reserved_page() to simplify the code
      drivers/video/acornfb.c: use __free_reserved_page() to simplify the code
      mm: use pgdat_end_pfn() to simplify the code in arch
      mm: use pgdat_end_pfn() to simplify the code in others
      mm: use populated_zone() instead of if(zone->present_pages)
      mm/memory_hotplug.c: rename the function is_memblock_offlined_cb()
      mm/memory_hotplug.c: use pfn_to_nid() instead of page_to_nid(pfn_to_page())

Ying Han (1):
      memcg: support hierarchical memory.numa_stats

Zhang Yanfei (4):
      mm/sparsemem: use PAGES_PER_SECTION to remove redundant nr_pages parameter
      mm/sparsemem: fix a bug in free_map_bootmem when CONFIG_SPARSEMEM_VMEMMAP
      mm-sparsemem-fix-a-bug-in-free_map_bootmem-when-config_sparsemem_vmemmap-v2
      mm/page_alloc.c: remove unused marco LONG_ALIGN

Zheng Liu (1):
      mm: improve the description for dirty_background_ratio/dirty_ratio sysctl

Zhi Yong Wu (2):
      arch/x86/mm/init.c: fix incorrect function name in alloc_low_pages()
      mm/page_alloc.c: fix comment in zlc_setup()

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
