From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/24] hwpoison fixes and stress testing filters
Date: Wed, 02 Dec 2009 11:12:31 +0800
Message-ID: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 543EC6B0062
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:36 -0500 (EST)
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Hi,

I'd like to submit the following patches for review.
They mainly falls into two catalogs:

- hwpoison fixes and cleanups we collected over time

 [PATCH 01/24] page-types: add standard GPL license head
 [PATCH 02/24] migrate: page could be locked by hwpoison, dont BUG()
 [PATCH 03/24] HWPOISON: remove the anonymous entry
 [PATCH 04/24] HWPOISON: return ENXIO on invalid pfn
 [PATCH 05/24] HWPOISON: avoid grabbing page for two times
 [PATCH 06/24] HWPOISON: abort on failed unmap
 [PATCH 07/24] HWPOISON: comment the possible set_page_dirty() race
 [PATCH 08/24] HWPOISON: comment dirty swapcache pages
 [PATCH 09/24] HWPOISON: introduce delete_from_lru_cache()
 [PATCH 10/24] HWPOISON: remove the free buddy page handler
 [PATCH 11/24] HWPOISON: detect free buddy pages explicitly

- conditional hwpoison injection filters for stress testing

 [PATCH 12/24] HWPOISON: make it possible to unpoison pages
 [PATCH 13/24] HWPOISON: introduce struct hwpoison_control
 [PATCH 14/24] HWPOISON: return 0 if page is assured to be isolated
 [PATCH 15/24] HWPOISON: add fs/device filters
 [PATCH 16/24] HWPOISON: limit hwpoison injector to known page types
 [PATCH 17/24] mm: export stable page flags
 [PATCH 18/24] HWPOISON: add page flags filter
 [PATCH 19/24] memcg: rename and export try_get_mem_cgroup_from_page()
 [PATCH 20/24] memcg: add accessor to mem_cgroup.css
 [PATCH 21/24] cgroup: define empty css_put() when !CONFIG_CGROUPS
 [PATCH 22/24] HWPOISON: add memory cgroup filter
 [PATCH 23/24] HWPOISON: add an interface to switch off/on all the page filters
 [PATCH 24/24] HWPOISON: show corrupted file info

 Documentation/vm/page-types.c     |   15 -
 fs/proc/page.c                    |   45 ---
 include/linux/cgroup.h            |    3 
 include/linux/kernel-page-flags.h |   46 +++
 include/linux/memcontrol.h        |   13 
 include/linux/mm.h                |    1 
 include/linux/page-flags.h        |    4 
 mm/Kconfig                        |    3 
 mm/hwpoison-inject.c              |   89 +++++-
 mm/internal.h                     |   12 
 mm/madvise.c                      |    1 
 mm/memcontrol.c                   |   16 -
 mm/memory-failure.c               |  392 ++++++++++++++++++++++------
 mm/memory.c                       |    4 
 mm/migrate.c                      |    2 
 mm/page_alloc.c                   |   21 +
 16 files changed, 532 insertions(+), 135 deletions(-)

Thanks,
Fengguang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
