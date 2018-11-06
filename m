Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD1A76B02C8
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 03:17:06 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id z14-v6so1525851lfh.13
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 00:17:06 -0800 (PST)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [37.9.109.47])
        by mx.google.com with ESMTPS id c22si36071773lfd.129.2018.11.06.00.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 00:17:04 -0800 (PST)
Subject: Re: [PATCH v1 0/4]mm: convert totalram_pages, totalhigh_pages and
 managed pages to atomic
References: <1540551662-26458-1-git-send-email-arunks@codeaurora.org>
 <9b210d4cc9925caf291412d7d45f16d7@codeaurora.org>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <63d9f48c-e39f-d345-0fb6-2f04afe769a2@yandex-team.ru>
Date: Tue, 6 Nov 2018 11:17:02 +0300
MIME-Version: 1.0
In-Reply-To: <9b210d4cc9925caf291412d7d45f16d7@codeaurora.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>, keescook@chromium.org, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, julia.lawall@lip6.fr

On 06.11.2018 8:38, Arun KS wrote:
> Any comments?

Looks good.
Except unclear motivation behind this change.
This should be in comment of one of patch.

Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

> 
> Regards,
> Arun
> 
> On 2018-10-26 16:30, Arun KS wrote:
>> This series convert totalram_pages, totalhigh_pages and
>> zone->managed_pages to atomic variables.
>>
>> The patch was comiple tested on x86(x86_64_defconfig & i386_defconfig)
>> on tip of linux-mmotm. And memory hotplug tested on arm64, but on an
>> older version of kernel.
>>
>> Arun KS (4):
>> A  mm: Fix multiple evaluvations of totalram_pages and managed_pages
>> A  mm: Convert zone->managed_pages to atomic variable
>> A  mm: convert totalram_pages and totalhigh_pages variables to atomic
>> A  mm: Remove managed_page_count spinlock
>>
>> A arch/csky/mm/init.cA A A A A A A A A A A A A A A A A A A A A A A A A A  |A  4 +-
>> A arch/powerpc/platforms/pseries/cmm.cA A A A A A A A A  | 10 ++--
>> A arch/s390/mm/init.cA A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A arch/um/kernel/mem.cA A A A A A A A A A A A A A A A A A A A A A A A A  |A  3 +-
>> A arch/x86/kernel/cpu/microcode/core.cA A A A A A A A A  |A  5 +-
>> A drivers/char/agp/backend.cA A A A A A A A A A A A A A A A A A A  |A  4 +-
>> A drivers/gpu/drm/amd/amdkfd/kfd_crat.cA A A A A A A A  |A  2 +-
>> A drivers/gpu/drm/i915/i915_gem.cA A A A A A A A A A A A A A  |A  2 +-
>> A drivers/gpu/drm/i915/selftests/i915_gem_gtt.c |A  4 +-
>> A drivers/hv/hv_balloon.cA A A A A A A A A A A A A A A A A A A A A A  | 19 +++----
>> A drivers/md/dm-bufio.cA A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A drivers/md/dm-crypt.cA A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A drivers/md/dm-integrity.cA A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A drivers/md/dm-stats.cA A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A drivers/media/platform/mtk-vpu/mtk_vpu.cA A A A A  |A  2 +-
>> A drivers/misc/vmw_balloon.cA A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A drivers/parisc/ccio-dma.cA A A A A A A A A A A A A A A A A A A A  |A  4 +-
>> A drivers/parisc/sba_iommu.cA A A A A A A A A A A A A A A A A A A  |A  4 +-
>> A drivers/staging/android/ion/ion_system_heap.c |A  2 +-
>> A drivers/xen/xen-selfballoon.cA A A A A A A A A A A A A A A A  |A  6 +--
>> A fs/ceph/super.hA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A fs/file_table.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  7 +--
>> A fs/fuse/inode.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A fs/nfs/write.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A fs/nfsd/nfscache.cA A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A fs/ntfs/malloc.hA A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A fs/proc/base.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A include/linux/highmem.hA A A A A A A A A A A A A A A A A A A A A A  | 28 ++++++++++-
>> A include/linux/mm.hA A A A A A A A A A A A A A A A A A A A A A A A A A A  | 27 +++++++++-
>> A include/linux/mmzone.hA A A A A A A A A A A A A A A A A A A A A A A  | 15 +++---
>> A include/linux/swap.hA A A A A A A A A A A A A A A A A A A A A A A A A  |A  1 -
>> A kernel/fork.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  5 +-
>> A kernel/kexec_core.cA A A A A A A A A A A A A A A A A A A A A A A A A A  |A  5 +-
>> A kernel/power/snapshot.cA A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A lib/show_mem.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A mm/highmem.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  4 +-
>> A mm/huge_memory.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A mm/kasan/quarantine.cA A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A mm/memblock.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  6 +--
>> A mm/memory_hotplug.cA A A A A A A A A A A A A A A A A A A A A A A A A A  |A  4 +-
>> A mm/mm_init.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A mm/oom_kill.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A mm/page_alloc.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  | 71 +++++++++++++--------------
>> A mm/shmem.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  7 +--
>> A mm/slab.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A mm/swap.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A mm/util.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A mm/vmalloc.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  4 +-
>> A mm/vmstat.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  4 +-
>> A mm/workingset.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A mm/zswap.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  4 +-
>> A net/dccp/proto.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  7 +--
>> A net/decnet/dn_route.cA A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A net/ipv4/tcp_metrics.cA A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>> A net/netfilter/nf_conntrack_core.cA A A A A A A A A A A A  |A  7 +--
>> A net/netfilter/xt_hashlimit.cA A A A A A A A A A A A A A A A A  |A  5 +-
>> A net/sctp/protocol.cA A A A A A A A A A A A A A A A A A A A A A A A A A  |A  7 +--
>> A security/integrity/ima/ima_kexec.cA A A A A A A A A A A  |A  2 +-
>> A 58 files changed, 195 insertions(+), 144 deletions(-)
