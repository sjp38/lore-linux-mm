Date: Sun, 28 Jan 2007 19:19:09 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
Message-ID: <20070128181909.GA12645@elte.hu>
References: <1169993494.10987.23.camel@lappy> <20070128144933.GD16552@infradead.org> <20070128151700.GA7644@elte.hu> <20070128152858.GA23410@infradead.org> <20070128154806.GA10615@elte.hu> <20070128155429.GA26855@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070128155429.GA26855@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

* Christoph Hellwig <hch@infradead.org> wrote:

> On Sun, Jan 28, 2007 at 04:48:06PM +0100, Ingo Molnar wrote:
> > i'm sorry, but do you realize that files_lock is a global lock, 
> > triggered by /every single/ file close?
> 
> Please check which thread you're in before you start such lengthy 
> rants.

my reply applies to the other thread too, you made a similar comment 
there too:

* Christoph Hellwig <hch@infradead.org> wrote:

> On Sun, Jan 28, 2007 at 12:51:18PM +0100, Peter Zijlstra wrote:
> > This patch-set breaks up the global file_list_lock which was found 
> > to be a severe contention point under basically any filesystem 
> > intensive workload.
>
> Benchmarks, please.  Where exactly do you see contention for this?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
