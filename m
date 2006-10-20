Date: Fri, 20 Oct 2006 10:20:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] virtual memmap for sparsemem [2/2] for ia64.
Message-Id: <20061020102040.5260e600.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4537985B.2010908@shadowen.org>
References: <20061019172328.4bcb1551.kamezawa.hiroyu@jp.fujitsu.com>
	<4537985B.2010908@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Oct 2006 16:23:07 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

>
> > +#ifdef CONFIG_VMEMMAP_SPARSEMEM
> > +	vmalloc_end -= NR_MEM_SECTIONS * PAGES_PER_SECTION * sizeof(struct page);
> > +	init_vmemmap_sparsemem(vmalloc_end);
> > +#endif
> 
> I thought I saw that this macro was defined to nothing when
> SPARSEMEM_VMEMMAP was undefined, so I'd expect you not to need the
> #ifdef round it here.  If its not defined when SPARSEMEM isn't defined
> then we should probabally change things so it is.  We do that for the
> sparse_init() and sparse_index_init() in linux/mmzone.h, so it would
> seem reasonable to do the same for this.
> 
Okay, I'll check it.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
