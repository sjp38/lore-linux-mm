Subject: Re: [RFC/PATCH] prepare_unmapped_area
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070205215827.a1a8ccdd.akpm@linux-foundation.org>
References: <200702060405.l1645R7G009668@shell0.pdx.osdl.net>
	 <1170736938.2620.213.camel@localhost.localdomain>
	 <20070206044516.GA16647@wotan.suse.de>
	 <1170738296.2620.220.camel@localhost.localdomain>
	 <20070205213130.308a8c76.akpm@linux-foundation.org>
	 <1170740760.2620.222.camel@localhost.localdomain>
	 <20070205215827.a1a8ccdd.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 06 Feb 2007 17:02:37 +1100
Message-Id: <1170741757.2620.229.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, hugh@veritas.com, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-02-05 at 21:58 -0800, Andrew Morton wrote:
> On Tue, 06 Feb 2007 16:46:00 +1100 Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > On Mon, 2007-02-05 at 21:31 -0800, Andrew Morton wrote:
> > > On Tue, 06 Feb 2007 16:04:56 +1100 Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> > > 
> > > > +#ifndef HAVE_ARCH_PREPARE_UNMAPPED_AREA
> > > > +int arch_prepare_unmapped_area(struct file *file, unsigned long addr,
> > > 
> > > __attribute__((weak)), please.
> > 
> > Not sure about that ... it will usually be inline, in fact, should be
> > static inline...
> > 
> 
> Bah.  function calls are fast, mmap() is slow and ARCH_HAVE_FOO is fugly.
> 
> Alternative: implement include/asm-*/arch-mmap.h and put the implementation
> in there.  That way, we can lose HAVE_ARCH_UNMAPPED_AREA and maybe a few other
> things too.

Yeah, I could have the two version in there become
generic_get_unmapped_area{_topdown} and have arch inlines for all
archs... probably a good idea. I'll look into it tomorrow.

Regarding using weak symbols, I'm not sure what you had in mind... you
can use those to have a symbol in arch overriding a symbol elsewhere ?

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
