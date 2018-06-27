Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB2A6B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 11:55:57 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w189-v6so1777102oiw.13
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:55:57 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y77-v6si462000oia.98.2018.06.27.08.55.56
        for <linux-mm@kvack.org>;
        Wed, 27 Jun 2018 08:55:56 -0700 (PDT)
Date: Wed, 27 Jun 2018 16:56:33 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v4 2/3] ioremap: Update pgtable free interfaces with addr
Message-ID: <20180627155632.GH30631@arm.com>
References: <20180627141348.21777-1-toshi.kani@hpe.com>
 <20180627141348.21777-3-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627141348.21777-3-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, cpandya@codeaurora.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, stable@vger.kernel.org

Hi Toshi,

On Wed, Jun 27, 2018 at 08:13:47AM -0600, Toshi Kani wrote:
> From: Chintan Pandya <cpandya@codeaurora.org>
> 
> The following kernel panic was observed on ARM64 platform due to a stale
> TLB entry.
> 
>  1. ioremap with 4K size, a valid pte page table is set.
>  2. iounmap it, its pte entry is set to 0.
>  3. ioremap the same address with 2M size, update its pmd entry with
>     a new value.
>  4. CPU may hit an exception because the old pmd entry is still in TLB,
>     which leads to a kernel panic.
> 
> Commit b6bdb7517c3d ("mm/vmalloc: add interfaces to free unmapped page
> table") has addressed this panic by falling to pte mappings in the above
> case on ARM64.
> 
> To support pmd mappings in all cases, TLB purge needs to be performed
> in this case on ARM64.
> 
> Add a new arg, 'addr', to pud_free_pmd_page() and pmd_free_pte_page()
> so that TLB purge can be added later in seprate patches.

So I acked v13 of Chintan's series posted here:

http://lists.infradead.org/pipermail/linux-arm-kernel/2018-June/582953.html

any chance this lot could all be merged together, please?

Will
