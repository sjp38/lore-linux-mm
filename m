Date: Mon, 5 Feb 2007 22:54:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC/PATCH] prepare_unmapped_area
Message-Id: <20070205225418.b0eb0346.akpm@linux-foundation.org>
In-Reply-To: <20070206064034.GB5549@wotan.suse.de>
References: <200702060405.l1645R7G009668@shell0.pdx.osdl.net>
	<1170736938.2620.213.camel@localhost.localdomain>
	<20070206044516.GA16647@wotan.suse.de>
	<1170738296.2620.220.camel@localhost.localdomain>
	<20070205213130.308a8c76.akpm@linux-foundation.org>
	<1170740760.2620.222.camel@localhost.localdomain>
	<20070205215827.a1a8ccdd.akpm@linux-foundation.org>
	<20070206061211.GA5549@wotan.suse.de>
	<20070205223747.d3494395.akpm@linux-foundation.org>
	<20070206064034.GB5549@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, hugh@veritas.com, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Feb 2007 07:40:34 +0100 Nick Piggin <npiggin@suse.de> wrote:

> On Mon, Feb 05, 2007 at 10:37:47PM -0800, Andrew Morton wrote:
> > On Tue, 6 Feb 2007 07:12:11 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > > 
> > > It still costs a whole nother cacheline, for just an empty function on
> > > !hugepage kernels.
> > 
> > Doubtful, especially with CONFIG_CC_OPTIMIZE_FOR_SIZE=y.
> 
> Oh, does the function call get stripped out in that case? Why does it
> get left in with OPTIMIZE_FOR_SIZE=n, I wonder?

It's still there, but is probably sharing a cacheline with the callee,
assuming the linker leaves functions in the programmer-specfied order,
which it usually does.

Some of the fancy linker options might subvert that, dunno.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
