Date: Mon, 26 Mar 2007 18:06:24 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
Message-ID: <20070327010624.GA2986@holomorphy.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com> <20070322223927.bb4caf43.akpm@linux-foundation.org> <Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com> <20070322234848.100abb3d.akpm@linux-foundation.org> <Pine.LNX.4.64.0703230804120.21857@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0703231026490.23132@schroedinger.engr.sgi.com> <20070323222133.f17090cf.akpm@linux-foundation.org> <Pine.LNX.4.64.0703260938520.3297@schroedinger.engr.sgi.com> <20070326102651.6d59207b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070326102651.6d59207b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 26, 2007 at 10:26:51AM -0800, Andrew Morton wrote:
> a) it has been demonstrated that this patch is superior to simply removing
>    the quicklists and

Not that clameter really needs my help, but I agree with his position
on several fronts, and advocate accordingly, so here is where I'm at.

>From prior experience, I believe I know how to extract positive results,
and that's primarily by PTE caching because they're the most frequently
zeroed pagetable nodes. The upper levels of pagetables will remain in
the noise until the leaf level bottleneck is dealt with.

PTE's need a custom tlb.h to deal with the TLB issues noted above; the
asm-generic variant will not suffice. Results above the noise level
need PTE caching. Sparse fault handling (esp. after execve() is done)
is one place in particular where improvements should be most readily
demonstrable, as only single cachelines on each allocated node should
be touched. lmbench should have a fault handling latency test for this.


On Mon, Mar 26, 2007 at 10:26:51AM -0800, Andrew Morton wrote:
> b) we understand why the below simple modification crashes i386.

Full eager zeroing patches not dependent on quicklist code don't crash,
so there is no latent use-after-free issue covered up by caching. I'll
help out more on the i386 front as-needed.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
