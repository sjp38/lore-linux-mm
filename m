Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3C066B055F
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 15:26:53 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id v6-v6so15913424wri.23
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 12:26:53 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id n9-v6si1399006wrw.334.2018.11.07.12.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 07 Nov 2018 12:26:52 -0800 (PST)
Date: Wed, 7 Nov 2018 21:26:42 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/2] mm/sparse: add common helper to mark all memblocks
 present
In-Reply-To: <724be9bb-59b6-33f3-7b59-3ca644d59bf7@deltatee.com>
Message-ID: <alpine.DEB.2.21.1811072125280.1666@nanos.tec.linutronix.de>
References: <20181107173859.24096-1-logang@deltatee.com> <20181107173859.24096-3-logang@deltatee.com> <20181107121207.62cb37cf58484b7cc80a8fd8@linux-foundation.org> <724be9bb-59b6-33f3-7b59-3ca644d59bf7@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>

Logan,

On Wed, 7 Nov 2018, Logan Gunthorpe wrote:
> On 2018-11-07 1:12 p.m., Andrew Morton wrote:
> >> +void __init memblocks_present(void)
> >> +{
> >> +	struct memblock_region *reg;
> >> +
> >> +	for_each_memblock(memory, reg) {
> >> +		memory_present(memblock_get_region_node(reg),
> >> +			       memblock_region_memory_base_pfn(reg),
> >> +			       memblock_region_memory_end_pfn(reg));
> >> +	}
> >> +}
> >> +
> > 
> > I don't like the name much.  To me, memblocks_present means "are
> > memblocks present" whereas this actually means "memblocks are present".
> > But whatever.  A little covering comment which describes what this
> > does and why it does it would be nice.
> 
> The same argument can be made about the existing memory_present()
> function and I think it's worth keeping the naming consistent. I'll add
> a comment and resend shortly.

Actually if both names suck, then there also is the option to rename both
instead of adding a comment to explain the suckage.

Thanks,

	tglx
