Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D09C0C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 12:47:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88F7B214DA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 12:47:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88F7B214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 223508E0012; Tue, 12 Feb 2019 07:47:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D1508E0011; Tue, 12 Feb 2019 07:47:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 098BC8E0012; Tue, 12 Feb 2019 07:47:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id CCF388E0011
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:47:33 -0500 (EST)
Received: by mail-ua1-f69.google.com with SMTP id w13so247927uaa.21
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 04:47:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=RPx0x0OEPmjlXeTnwz45DVOd0/idD4uRJTZSAJeVx4I=;
        b=ANgS7U1AzfNtCW1aFDs++zSu9wx8cgXfSAMk0YSKOXi1Y/yzQcKOj1fbgU7D6ByTok
         WuazGXX++vyuULX9qa5pyoVJ66bCDAkmS73dg3OqyROCUfE1QouaaoHOQE1dKGHkWfJb
         1GiiCtCO9r/pD4zB7hl0G7x/Xu+5LLOWDupU+QhZ//1mn4P+lF/7F3Z9wWMc7H/E3c45
         PDD5lkrOMj8AAQeIHYtC9CNC9WO+ngdWIuZsyaQdY6BsTWqtpSAr2WGyUqFwSz4cQHic
         q14MaSRyTYZZ4O/kA6iScV8lNURU8VXFTD2QzSUPpJc7Riruf4HwwzQCZuKgssrQDuj/
         Snow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuZJ4phSLFp82WVZ/0jLdXuqQcrheZzzzmbk9/h+h8CX4mCT8qo5
	Dt3mYfAkQfZX487vgUBZGqz6xjcOa3CJXNO5Bl6Eu4mfP6H0YSqzVvMCZKRhkFCbOXufAYzLOqd
	v5IscZGHsw6YZ+24dJffzRY0zHQlFKBHM/+MdQXTty8lmKaplzOkgKiDpIZ5yovEiHw==
X-Received: by 2002:a67:e995:: with SMTP id b21mr1453493vso.13.1549975653402;
        Tue, 12 Feb 2019 04:47:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZGf8kv9N/AHY4cv/gyL/vzZ6H8cEO8CudmCvDfS/sDTPOne1BIlep4wiMMdnEk0FNHqBG+
X-Received: by 2002:a67:e995:: with SMTP id b21mr1453472vso.13.1549975652335;
        Tue, 12 Feb 2019 04:47:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549975652; cv=none;
        d=google.com; s=arc-20160816;
        b=F79X8UW77yr7iMSc4VYv2DonbAngd1mW+prSUnTqb8pEUkGiYcHOqPB8DzweVKp2NM
         8wAcyJKCpS6cx3fm4ILga/XDeGmSM8Iw70nPVZx3HYLq/gJVxpv8FOD5IDsvgr+LDMwW
         GnBbmP2Jv/WsQ2jCyhBGRqHiYADTSGYQ34K4lT3lq7VY6r/4yu/OXdQlub7HnZyjJm7R
         ytIlQZb3xJ19wqVxt2ZMRQEVSNP4TLO5ynchT/OyEvXoqeg5jEvyGoE08XwHN/wj0Fhq
         w30O24/KkMHdMUknFrcb9Bwi5+InBF6e7MFPYRi1SFc2OXtqUvQp29AfNIVqJoHlOeeE
         gmHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=RPx0x0OEPmjlXeTnwz45DVOd0/idD4uRJTZSAJeVx4I=;
        b=KrMTM+SqBY72GK+M6Aq3khOhQFomjFs/FtukVmNwYjCp9t/Pk0rKo3FpXLKcQlJdBJ
         FcFmag1I+sPMGiY+mEnYyTGNZcdZH5N3JU06hEXS7gRJOZLRN8R+Hj4o9k3yGyJ4bUId
         87/+noAeA5k0kmU1b5ZDfqSI23bbUdzBWHeOjMYPJDiwhX8BvBcjzDLXKtTpDEWORMH5
         aoGRUB6/Q8r5PpITcwVAr2OdVN+3uwwODaL3kqcnDFhjL+YscMEi8NcH2tDiagrPVAEm
         JZRHKF+l8X+qbKLaDUuLSr1ZbwvkdlNP2hNIIFpBLd+qLKiN5GoAyU5b6w2+hcudXEQe
         3CuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id b68si9209098vkh.9.2019.02.12.04.47.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 04:47:32 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 3547DBF3D004DC8D034E;
	Tue, 12 Feb 2019 20:47:28 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS409-HUB.china.huawei.com
 (10.3.19.209) with Microsoft SMTP Server id 14.3.408.0; Tue, 12 Feb 2019
 20:47:19 +0800
Date: Tue, 12 Feb 2019 12:47:07 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Oscar Salvador <osalvador@suse.de>
CC: <linux-mm@kvack.org>, <mhocko@suse.com>, <dan.j.williams@intel.com>,
	<Pavel.Tatashin@microsoft.com>, <david@redhat.com>,
	<linux-kernel@vger.kernel.org>, <dave.hansen@intel.com>,
	<shameerali.kolothum.thodi@huawei.com>, <linuxarm@huawei.com>, Robin Murphy
	<robin.murphy@arm.com>
Subject: Re: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20190212124707.000028ea@huawei.com>
In-Reply-To: <20190122103708.11043-1-osalvador@suse.de>
References: <20190122103708.11043-1-osalvador@suse.de>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jan 2019 11:37:04 +0100
Oscar Salvador <osalvador@suse.de> wrote:

> Hi,
> 
> this is the v2 of the first RFC I sent back then in October [1].
> In this new version I tried to reduce the complexity as much as possible,
> plus some clean ups.
> 
> [Testing]
> 
> I have tested it on "x86_64" (small/big memblocks) and on "powerpc".
> On both architectures hot-add/hot-remove online/offline operations
> worked as expected using vmemmap pages, I have not seen any issues so far.
> I wanted to try it out on Hyper-V/Xen, but I did not manage to.
> I plan to do so along this week (if time allows).
> I would also like to test it on arm64, but I am not sure I can grab
> an arm64 box anytime soon.

Hi Oscar,

I ran tests on one of our arm64 machines. Particular machine doesn't actually have
the mechanics for hotplug, so was all 'faked', but software wise it's all the
same.

Upshot, seems to work as expected on arm64 as well.
Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Remove currently relies on some out of tree patches (and dirty hacks) due
to the usual issue with how arm64 does pfn_valid. It's not even vaguely
ready for upstream. I'll aim to post an informational set for anyone else
testing in this area (it's more or less just a rebase of the patches from
a few years ago).

+CC Shameer who has been testing the virtualization side for more details on
that, and Robin who is driving forward memory hotplug in general on the arm64
side.

Thanks,

Jonathan

> 
> [Coverletter]:
> 
> This is another step to make the memory hotplug more usable. The primary
> goal of this patchset is to reduce memory overhead of the hot added
> memory (at least for SPARSE_VMEMMAP memory model). The current way we use
> to populate memmap (struct page array) has two main drawbacks:
> 
> a) it consumes an additional memory until the hotadded memory itself is
>    onlined and
> b) memmap might end up on a different numa node which is especially true
>    for movable_node configuration.
> 
> a) is problem especially for memory hotplug based memory "ballooning"
>    solutions when the delay between physical memory hotplug and the
>    onlining can lead to OOM and that led to introduction of hacks like auto
>    onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
>    policy for the newly added memory")).
> 
> b) can have performance drawbacks.
> 
> I have also seen hot-add operations failing on powerpc due to the fact
> that we try to use order-8 pages when populating the memmap array.
> Given 64KB base pagesize, that is 16MB.
> If we run out of those, we just fail the operation and we cannot add
> more memory.
> We could fallback to base pages as x86_64 does, but we can do better.
> 
> One way to mitigate all these issues is to simply allocate memmap array
> (which is the largest memory footprint of the physical memory hotplug)
> from the hotadded memory itself. VMEMMAP memory model allows us to map
> any pfn range so the memory doesn't need to be online to be usable
> for the array. See patch 3 for more details. In short I am reusing an
> existing vmem_altmap which wants to achieve the same thing for nvdim
> device memory.
> 
> There is also one potential drawback, though. If somebody uses memory
> hotplug for 1G (gigantic) hugetlb pages then this scheme will not work
> for them obviously because each memory block will contain reserved
> area. Large x86 machines will use 2G memblocks so at least one 1G page
> will be available but this is still not 2G...
> 
> I am not really sure somebody does that and how reliable that can work
> actually. Nevertheless, I _believe_ that onlining more memory into
> virtual machines is much more common usecase. Anyway if there ever is a
> strong demand for such a usecase we have basically 3 options a) enlarge
> memory blocks even more b) enhance altmap allocation strategy and reuse
> low memory sections to host memmaps of other sections on the same NUMA
> node c) have the memmap allocation strategy configurable to fallback to
> the current allocation.
>  
> [Overall design]:
> 
> Let us say we hot-add 2GB of memory on a x86_64 (memblock size = 128M).
> That is:
> 
>  - 16 sections
>  - 524288 pages
>  - 8192 vmemmap pages (out of those 524288. We spend 512 pages for each section)
> 
>  The range of pages is: 0xffffea0004000000 - 0xffffea0006000000
>  The vmemmap range is:  0xffffea0004000000 - 0xffffea0004080000
> 
>  0xffffea0004000000 is the head vmemmap page (first page), while all the others
>  are "tails".
> 
>  We keep the following information in it:
> 
>  - Head page:
>    - head->_refcount: number of sections
>    - head->private :  number of vmemmap pages
>  - Tail page:
>    - tail->freelist : pointer to the head
> 
> This is done because it eases the work in cases where we have to compute the
> number of vmemmap pages to know how much do we have to skip etc, and to keep
> the right accounting to present_pages.
> 
> When we want to hot-remove the range, we need to be careful because the first
> pages of that range, are used for the memmap maping, so if we remove those
> first, we would blow up while accessing the others later on.
> For that reason we keep the number of sections in head->_refcount, to know how
> much do we have to defer the free up.
> 
> Since in a hot-remove operation, sections are being removed sequentially, the
> approach taken here is that every time we hit free_section_memmap(), we decrease
> the refcount of the head.
> When it reaches 0, we know that we hit the last section, so we call
> vmemmap_free() for the whole memory-range in backwards, so we make sure that
> the pages used for the mapping will be latest to be freed up.
> 
> The accounting is as follows:
> 
>  Vmemmap pages are charged to spanned/present_paged, but not to manages_pages.
> 
> I yet have to check a couple of things like creating an accounting item
> like VMEMMAP_PAGES to show in /proc/meminfo to ease to spot the memory that
> went in there, testing Hyper-V/Xen to see how they react to the fact that
> we are using the beginning of the memory-range for our own purposes, and to
> check the thing about gigantic pages + hotplug.
> I also have to check that there is no compilation/runtime errors when
> CONFIG_SPARSEMEM but !CONFIG_SPARSEMEM_VMEMMAP.
> But before that, I would like to get people's feedback about the overall
> design, and ideas/suggestions.
> 
> 
> [1] https://patchwork.kernel.org/cover/10685835/
> 
> Michal Hocko (3):
>   mm, memory_hotplug: cleanup memory offline path
>   mm, memory_hotplug: provide a more generic restrictions for memory
>     hotplug
>   mm, sparse: rename kmalloc_section_memmap, __kfree_section_memmap
> 
> Oscar Salvador (1):
>   mm, memory_hotplug: allocate memmap from the added memory range for
>     sparse-vmemmap
> 
>  arch/arm64/mm/mmu.c            |  10 ++-
>  arch/ia64/mm/init.c            |   5 +-
>  arch/powerpc/mm/init_64.c      |   7 ++
>  arch/powerpc/mm/mem.c          |   6 +-
>  arch/s390/mm/init.c            |  12 ++-
>  arch/sh/mm/init.c              |   6 +-
>  arch/x86/mm/init_32.c          |   6 +-
>  arch/x86/mm/init_64.c          |  20 +++--
>  drivers/hv/hv_balloon.c        |   1 +
>  drivers/xen/balloon.c          |   1 +
>  include/linux/memory_hotplug.h |  42 ++++++++--
>  include/linux/memremap.h       |   2 +-
>  include/linux/page-flags.h     |  23 +++++
>  kernel/memremap.c              |   9 +-
>  mm/compaction.c                |   8 ++
>  mm/memory_hotplug.c            | 186 +++++++++++++++++++++++++++++------------
>  mm/page_alloc.c                |  47 ++++++++++-
>  mm/page_isolation.c            |  13 +++
>  mm/sparse.c                    | 124 +++++++++++++++++++++++++--
>  mm/util.c                      |   2 +
>  20 files changed, 431 insertions(+), 99 deletions(-)
> 


