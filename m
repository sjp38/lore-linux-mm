Date: Tue, 6 Feb 2007 07:40:34 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC/PATCH] prepare_unmapped_area
Message-ID: <20070206064034.GB5549@wotan.suse.de>
References: <200702060405.l1645R7G009668@shell0.pdx.osdl.net> <1170736938.2620.213.camel@localhost.localdomain> <20070206044516.GA16647@wotan.suse.de> <1170738296.2620.220.camel@localhost.localdomain> <20070205213130.308a8c76.akpm@linux-foundation.org> <1170740760.2620.222.camel@localhost.localdomain> <20070205215827.a1a8ccdd.akpm@linux-foundation.org> <20070206061211.GA5549@wotan.suse.de> <20070205223747.d3494395.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070205223747.d3494395.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, hugh@veritas.com, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 05, 2007 at 10:37:47PM -0800, Andrew Morton wrote:
> On Tue, 6 Feb 2007 07:12:11 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > 
> > It still costs a whole nother cacheline, for just an empty function on
> > !hugepage kernels.
> 
> Doubtful, especially with CONFIG_CC_OPTIMIZE_FOR_SIZE=y.

Oh, does the function call get stripped out in that case? Why does it
get left in with OPTIMIZE_FOR_SIZE=n, I wonder?

> > > Alternative: implement include/asm-*/arch-mmap.h and put the implementation
> > > in there.  That way, we can lose HAVE_ARCH_UNMAPPED_AREA and maybe a few other
> > > things too.
> > 
> > Yes please.
> 
> It's a heck of a lot of fuss, adding 20-odd new files.  If we're sure that
> we can use it for other things then maybe..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
