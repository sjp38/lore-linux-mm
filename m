Date: Thu, 19 Oct 2006 18:42:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
In-Reply-To: <20061020101857.b795f143.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0610191838420.11820@schroedinger.engr.sgi.com>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610190932310.8072@schroedinger.engr.sgi.com>
 <20061020101857.b795f143.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Oct 2006, KAMEZAWA Hiroyuki wrote:

> Yes. but it seems to need per-arch implementation (in page fault handler).
> like this (from ia64)

If we have a statically assigned virtual memory area then this is not a 
big problem. With sharing the VMALLOC address space this may be a problem. 
I think a static address space is no problem for 64 bit platforms where 
we have lots of virtual address space. 32 bit platforms may have a dense 
address space where vmemmap is not needed. 
Maybe switch to a static address range range ? You saw my ia64 patch 
that did this right?


> Maybe extra optimization patch can be discussed after this generic code is settled.

Ok.

> > > +#ifdef CONFIG_VMEMMAP_SPARSEMEM
> > > +extern struct page *virt_memmap_start;
> > 
> > extern struct page[] would be better performance wise. Use the definitions 
> > for FLATMEM?
> Okay. will make it as array. or some constant value.

See my IA64 patchset for vmemmap static. We could define the mem_map 
address statically in the linker.

> > The virtual memmap has the potential of becoming the default for x86_64 
> > and many other platforms that already map memory. There is no performance 
> > difference between FLATMEM and this virtual memmap approach if there are 
> > already mappings in play.
> > 
> Hmm, adding CONFIG_HAVE_ARCH_LARGE_KERNEL_PAGE_MAPPING will be good ?
> We can add per-arch patches afterwards.

Great!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
