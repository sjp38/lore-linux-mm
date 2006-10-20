Date: Fri, 20 Oct 2006 11:06:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
Message-Id: <20061020110618.6423d0e4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0610191838420.11820@schroedinger.engr.sgi.com>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0610190932310.8072@schroedinger.engr.sgi.com>
	<20061020101857.b795f143.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0610191838420.11820@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Oct 2006 18:42:24 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 20 Oct 2006, KAMEZAWA Hiroyuki wrote:
> 
> > Yes. but it seems to need per-arch implementation (in page fault handler).
> > like this (from ia64)
> 
> If we have a statically assigned virtual memory area then this is not a 
> big problem. With sharing the VMALLOC address space this may be a problem. 
> I think a static address space is no problem for 64 bit platforms where 
> we have lots of virtual address space. 32 bit platforms may have a dense 
> address space where vmemmap is not needed. 
> Maybe switch to a static address range range ? You saw my ia64 patch 
> that did this right?
> 
I'll study it.

> > > > +#ifdef CONFIG_VMEMMAP_SPARSEMEM
> > > > +extern struct page *virt_memmap_start;
> > > 
> > > extern struct page[] would be better performance wise. Use the definitions 
> > > for FLATMEM?
> > Okay. will make it as array. or some constant value.
> 
> See my IA64 patchset for vmemmap static. We could define the mem_map 
> address statically in the linker.
> 
Ok.

> > > The virtual memmap has the potential of becoming the default for x86_64 
> > > and many other platforms that already map memory. There is no performance 
> > > difference between FLATMEM and this virtual memmap approach if there are 
> > > already mappings in play.
> > > 
> > Hmm, adding CONFIG_HAVE_ARCH_LARGE_KERNEL_PAGE_MAPPING will be good ?
> > We can add per-arch patches afterwards.
> 
> Great!

By the way, we have to make sizeof(struct page) as (1 << x) aligned size to use
large-sized page. (IIRC, my gcc-3.4.3 says it is 56bytes....)

-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
