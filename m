Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9AD6B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:23:24 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id n10-v6so5610944otl.2
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 05:23:24 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m9-v6si2999892oia.76.2018.06.29.05.23.21
        for <linux-mm@kvack.org>;
        Fri, 29 Jun 2018 05:23:22 -0700 (PDT)
Date: Fri, 29 Jun 2018 13:23:59 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v4 2/3] ioremap: Update pgtable free interfaces with addr
Message-ID: <20180629122358.GC17859@arm.com>
References: <20180627141348.21777-1-toshi.kani@hpe.com>
 <20180627141348.21777-3-toshi.kani@hpe.com>
 <20180627155632.GH30631@arm.com>
 <1530115885.14039.295.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530115885.14039.295.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "joro@8bytes.org" <joro@8bytes.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hi Toshi, Thomas,

On Wed, Jun 27, 2018 at 04:13:22PM +0000, Kani, Toshi wrote:
> On Wed, 2018-06-27 at 16:56 +0100, Will Deacon wrote:
> > On Wed, Jun 27, 2018 at 08:13:47AM -0600, Toshi Kani wrote:
> > > From: Chintan Pandya <cpandya@codeaurora.org>
> > > 
> > > The following kernel panic was observed on ARM64 platform due to a stale
> > > TLB entry.
> > > 
> > >  1. ioremap with 4K size, a valid pte page table is set.
> > >  2. iounmap it, its pte entry is set to 0.
> > >  3. ioremap the same address with 2M size, update its pmd entry with
> > >     a new value.
> > >  4. CPU may hit an exception because the old pmd entry is still in TLB,
> > >     which leads to a kernel panic.
> > > 
> > > Commit b6bdb7517c3d ("mm/vmalloc: add interfaces to free unmapped page
> > > table") has addressed this panic by falling to pte mappings in the above
> > > case on ARM64.
> > > 
> > > To support pmd mappings in all cases, TLB purge needs to be performed
> > > in this case on ARM64.
> > > 
> > > Add a new arg, 'addr', to pud_free_pmd_page() and pmd_free_pte_page()
> > > so that TLB purge can be added later in seprate patches.
> > 
> > So I acked v13 of Chintan's series posted here:
> > 
> > http://lists.infradead.org/pipermail/linux-arm-kernel/2018-June/582953.html
> > 
> > any chance this lot could all be merged together, please?
> 
> Chintan's patch 2/3 and 3/3 apply cleanly on top of my series. Can you
> please coordinate with Thomas on the logistics?

Sure. I guess having this series on a common branch that I can pull into
arm64 and apply Chintan's other patches on top would work.

How does that sound?

Will
