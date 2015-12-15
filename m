Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0F85A6B0253
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 11:50:21 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id v16so11977447qge.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 08:50:21 -0800 (PST)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id y198si1879074qhb.28.2015.12.15.08.50.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 08:50:19 -0800 (PST)
Received: by mail-qk0-x22d.google.com with SMTP id t125so22131889qkh.3
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 08:50:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151210023812.30368.84734.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<20151210023812.30368.84734.stgit@dwillia2-desk3.jf.intel.com>
Date: Tue, 15 Dec 2015 08:50:19 -0800
Message-ID: <CAPcyv4i17AyddcC4gn2u9G3mZ8SXrpZJmbLgJ1H_eE2FLu3LDA@mail.gmail.com>
Subject: Re: [-mm PATCH v2 11/25] x86, mm: introduce vmem_altmap to augment vmemmap_populate()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, kbuild test robot <lkp@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Dec 9, 2015 at 6:38 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> In support of providing struct page for large persistent memory
> capacities, use struct vmem_altmap to change the default policy for
> allocating memory for the memmap array.  The default vmemmap_populate()
> allocates page table storage area from the page allocator.  Given
> persistent memory capacities relative to DRAM it may not be feasible to
> store the memmap in 'System Memory'.  Instead vmem_altmap represents
> pre-allocated "device pages" to satisfy vmemmap_alloc_block_buf()
> requests.
>
> Cc: x86@kernel.org
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reported-by: kbuild test robot <lkp@intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/m68k/include/asm/page_mm.h |    1
>  arch/m68k/include/asm/page_no.h |    1
>  arch/mn10300/include/asm/page.h |    1
>  arch/x86/mm/init_64.c           |   32 +++++++++++---
>  drivers/nvdimm/pmem.c           |    6 ++-
>  include/linux/memory_hotplug.h  |    3 +
>  include/linux/mm.h              |   92 +++++++++++++++++++++++++++++++++++++--
>  kernel/memremap.c               |   61 +++++++++++++++++++++++++-
>  mm/memory_hotplug.c             |   66 ++++++++++++++++++++--------
>  mm/page_alloc.c                 |   10 ++++
>  mm/sparse-vmemmap.c             |   37 +++++++++++++++-
>  mm/sparse.c                     |    8 ++-
>  12 files changed, 277 insertions(+), 41 deletions(-)

Ingo, since you've shown interest in the nvdimm enabling in the past,
may I ask to look over the x86 touches in this set?  I believe Andrew
is waiting on Acked-by's to move this forward.

These patches:
[-mm PATCH v2 11/25] x86, mm: introduce vmem_altmap to augment
vmemmap_populate()
[-mm PATCH v2 16/25] x86, mm: introduce _PAGE_DEVMAP
[-mm PATCH v2 23/25] mm, x86: get_user_pages() for dax mappings

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
