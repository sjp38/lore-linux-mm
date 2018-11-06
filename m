Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD2DC6B02B8
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 00:38:59 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id bb3-v6so12358994plb.20
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 21:38:59 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id n5-v6si1754738pfb.88.2018.11.05.21.38.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 21:38:58 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 06 Nov 2018 11:08:57 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v1 0/4]mm: convert totalram_pages, totalhigh_pages and
 managed pages to atomic
In-Reply-To: <1540551662-26458-1-git-send-email-arunks@codeaurora.org>
References: <1540551662-26458-1-git-send-email-arunks@codeaurora.org>
Message-ID: <9b210d4cc9925caf291412d7d45f16d7@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, julia.lawall@lip6.fr

Any comments?

Regards,
Arun

On 2018-10-26 16:30, Arun KS wrote:
> This series convert totalram_pages, totalhigh_pages and
> zone->managed_pages to atomic variables.
> 
> The patch was comiple tested on x86(x86_64_defconfig & i386_defconfig)
> on tip of linux-mmotm. And memory hotplug tested on arm64, but on an
> older version of kernel.
> 
> Arun KS (4):
>   mm: Fix multiple evaluvations of totalram_pages and managed_pages
>   mm: Convert zone->managed_pages to atomic variable
>   mm: convert totalram_pages and totalhigh_pages variables to atomic
>   mm: Remove managed_page_count spinlock
> 
>  arch/csky/mm/init.c                           |  4 +-
>  arch/powerpc/platforms/pseries/cmm.c          | 10 ++--
>  arch/s390/mm/init.c                           |  2 +-
>  arch/um/kernel/mem.c                          |  3 +-
>  arch/x86/kernel/cpu/microcode/core.c          |  5 +-
>  drivers/char/agp/backend.c                    |  4 +-
>  drivers/gpu/drm/amd/amdkfd/kfd_crat.c         |  2 +-
>  drivers/gpu/drm/i915/i915_gem.c               |  2 +-
>  drivers/gpu/drm/i915/selftests/i915_gem_gtt.c |  4 +-
>  drivers/hv/hv_balloon.c                       | 19 +++----
>  drivers/md/dm-bufio.c                         |  2 +-
>  drivers/md/dm-crypt.c                         |  2 +-
>  drivers/md/dm-integrity.c                     |  2 +-
>  drivers/md/dm-stats.c                         |  2 +-
>  drivers/media/platform/mtk-vpu/mtk_vpu.c      |  2 +-
>  drivers/misc/vmw_balloon.c                    |  2 +-
>  drivers/parisc/ccio-dma.c                     |  4 +-
>  drivers/parisc/sba_iommu.c                    |  4 +-
>  drivers/staging/android/ion/ion_system_heap.c |  2 +-
>  drivers/xen/xen-selfballoon.c                 |  6 +--
>  fs/ceph/super.h                               |  2 +-
>  fs/file_table.c                               |  7 +--
>  fs/fuse/inode.c                               |  2 +-
>  fs/nfs/write.c                                |  2 +-
>  fs/nfsd/nfscache.c                            |  2 +-
>  fs/ntfs/malloc.h                              |  2 +-
>  fs/proc/base.c                                |  2 +-
>  include/linux/highmem.h                       | 28 ++++++++++-
>  include/linux/mm.h                            | 27 +++++++++-
>  include/linux/mmzone.h                        | 15 +++---
>  include/linux/swap.h                          |  1 -
>  kernel/fork.c                                 |  5 +-
>  kernel/kexec_core.c                           |  5 +-
>  kernel/power/snapshot.c                       |  2 +-
>  lib/show_mem.c                                |  2 +-
>  mm/highmem.c                                  |  4 +-
>  mm/huge_memory.c                              |  2 +-
>  mm/kasan/quarantine.c                         |  2 +-
>  mm/memblock.c                                 |  6 +--
>  mm/memory_hotplug.c                           |  4 +-
>  mm/mm_init.c                                  |  2 +-
>  mm/oom_kill.c                                 |  2 +-
>  mm/page_alloc.c                               | 71 
> +++++++++++++--------------
>  mm/shmem.c                                    |  7 +--
>  mm/slab.c                                     |  2 +-
>  mm/swap.c                                     |  2 +-
>  mm/util.c                                     |  2 +-
>  mm/vmalloc.c                                  |  4 +-
>  mm/vmstat.c                                   |  4 +-
>  mm/workingset.c                               |  2 +-
>  mm/zswap.c                                    |  4 +-
>  net/dccp/proto.c                              |  7 +--
>  net/decnet/dn_route.c                         |  2 +-
>  net/ipv4/tcp_metrics.c                        |  2 +-
>  net/netfilter/nf_conntrack_core.c             |  7 +--
>  net/netfilter/xt_hashlimit.c                  |  5 +-
>  net/sctp/protocol.c                           |  7 +--
>  security/integrity/ima/ima_kexec.c            |  2 +-
>  58 files changed, 195 insertions(+), 144 deletions(-)
