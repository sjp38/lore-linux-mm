Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 688616B0010
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 17:02:24 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g9-v6so1514089wrq.7
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 14:02:24 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p6-v6si1336108wrj.355.2018.07.03.14.02.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 14:02:22 -0700 (PDT)
Date: Tue, 3 Jul 2018 23:02:15 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 2/3] ioremap: Update pgtable free interfaces with
 addr
In-Reply-To: <1530287995.14039.361.camel@hpe.com>
Message-ID: <alpine.DEB.2.21.1807032301140.1816@nanos.tec.linutronix.de>
References: <20180627141348.21777-1-toshi.kani@hpe.com>  <20180627141348.21777-3-toshi.kani@hpe.com>  <20180627155632.GH30631@arm.com> <1530115885.14039.295.camel@hpe.com>  <20180629122358.GC17859@arm.com> <1530287995.14039.361.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "will.deacon@arm.com" <will.deacon@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "joro@8bytes.org" <joro@8bytes.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, 29 Jun 2018, Kani, Toshi wrote:
> On Fri, 2018-06-29 at 13:23 +0100, Will Deacon wrote:
> > Hi Toshi, Thomas,
> > 
> > On Wed, Jun 27, 2018 at 04:13:22PM +0000, Kani, Toshi wrote:
> > > On Wed, 2018-06-27 at 16:56 +0100, Will Deacon wrote:
> > > > On Wed, Jun 27, 2018 at 08:13:47AM -0600, Toshi Kani wrote:
> > > > > From: Chintan Pandya <cpandya@codeaurora.org>
> > > > > 
> > > > > The following kernel panic was observed on ARM64 platform due to a stale
> > > > > TLB entry.
> > > > > 
> > > > >  1. ioremap with 4K size, a valid pte page table is set.
> > > > >  2. iounmap it, its pte entry is set to 0.
> > > > >  3. ioremap the same address with 2M size, update its pmd entry with
> > > > >     a new value.
> > > > >  4. CPU may hit an exception because the old pmd entry is still in TLB,
> > > > >     which leads to a kernel panic.
> > > > > 
> > > > > Commit b6bdb7517c3d ("mm/vmalloc: add interfaces to free unmapped page
> > > > > table") has addressed this panic by falling to pte mappings in the above
> > > > > case on ARM64.
> > > > > 
> > > > > To support pmd mappings in all cases, TLB purge needs to be performed
> > > > > in this case on ARM64.
> > > > > 
> > > > > Add a new arg, 'addr', to pud_free_pmd_page() and pmd_free_pte_page()
> > > > > so that TLB purge can be added later in seprate patches.
> > > > 
> > > > So I acked v13 of Chintan's series posted here:
> > > > 
> > > > http://lists.infradead.org/pipermail/linux-arm-kernel/2018-June/582953.html
> > > > 
> > > > any chance this lot could all be merged together, please?
> > > 
> > > Chintan's patch 2/3 and 3/3 apply cleanly on top of my series. Can you
> > > please coordinate with Thomas on the logistics?
> > 
> > Sure. I guess having this series on a common branch that I can pull into
> > arm64 and apply Chintan's other patches on top would work.
> > 
> > How does that sound?
> 
> Should this go thru -mm tree then?
> 
> Andrew, Thomas, what do you think? 

I just pick it up and provide Will a branch to pull that lot from.

Thanks,

	tglx
