Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7C76B0087
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 13:10:29 -0400 (EDT)
Date: Sun, 24 Oct 2010 20:10:20 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLAB updates for 2.6.37-rc1
Message-ID: <alpine.DEB.2.00.1010242005280.4447@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

The bulk of changes here are from Christoph Lameter's SLUB unification 
patch series. I've included SLUB cleanups that don't change the core 
allocator and hope to queue the more interesting patches for 2.6.38. 
There's also bug fixes and other cleanups included here from David 
Rientjes and Namhyung Kim.

The SLUB patches were built on Tejun Heo's UP per-CPU patches which is why 
they show up in the pull request although you already have them in 
master.

                         Pekka

The following changes since commit 35da7a307c535f9c2929cae277f3df425c9f9b1e:
   Linus Torvalds (1):
         Merge branch 'for-2.6.37/core' of git://git.kernel.dk/linux-2.6-block

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git for-linus

Christoph Lameter (14):
       slub: Force no inlining of debug functions
       slub: Remove dynamic dma slab allocation
       slub: Remove static kmem_cache_cpu array for boot
       slub: Dynamically size kmalloc cache allocations
       slub: Extract hooks for memory checkers from hotpaths
       slub: Move gfpflag masking out of the hotpath
       slub: Add dummy functions for the !SLUB_DEBUG case
       slub: Fix up missing kmalloc_cache -> kmem_cache_node case for memoryhotplug
       Slub: UP bandaid
       slub: reduce differences between SMP and NUMA
       SLUB: Pass active and inactive redzone flags instead of boolean to debug functions
       slub: extract common code to remove objects from partial list without locking
       slub: Enable sysfs support for !CONFIG_SLUB_DEBUG
       slub: Move functions to reduce #ifdefs

David Rientjes (2):
       slob: fix gfp flags for order-0 page allocations
       slub: fix SLUB_RESILIENCY_TEST for dynamic kmalloc caches

Namhyung Kim (3):
       slub: Fix signedness warnings
       slub: Add lock release annotation
       slub: Move NUMA-related functions under CONFIG_NUMA

Pekka Enberg (5):
       SLUB: Fix merged slab cache names
       Revert "Slub: UP bandaid"
       SLUB: Optimize slab_free() debug check
       SLUB: Fix memory hotplug with !NUMA
       Merge branch 'master' into for-linus

Tejun Heo (4):
       vmalloc: pcpu_get/free_vm_areas() aren't needed on UP
       percpu: reduce PCPU_MIN_UNIT_SIZE to 32k
       percpu: use percpu allocator on UP too
       percpu: clear memory allocated with the km allocator

  include/linux/slub_def.h |   14 +-
  lib/Kconfig.debug        |    2 +-
  mm/slob.c                |    4 +-
  mm/slub.c                |  788 ++++++++++++++++++++++++----------------------
  4 files changed, 424 insertions(+), 384 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
