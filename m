Date: Wed, 1 Dec 2004 16:55:38 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: page fault scalability patch V12 [0/7]: Overview and
 performance tests
Message-Id: <20041201165538.015ee7a6.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0412011608500.22796@ppc970.osdl.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
	<Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org>
	<Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org>
	<Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412011608500.22796@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: clameter@sgi.com, hugh@veritas.com, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@osdl.org> wrote:
>
> 
> 
> On Wed, 1 Dec 2004, Christoph Lameter wrote:
> >
> > Changes from V11->V12 of this patch:
> > - dump sloppy_rss in favor of list_rss (Linus' proposal)
> > - keep up against current Linus tree (patch is based on 2.6.10-rc2-bk14)
> > 
> > This is a series of patches that increases the scalability of
> > the page fault handler for SMP. Here are some performance results
> > on a machine with 512 processors allocating 32 GB with an increasing
> > number of threads (that are assigned a processor each).
> 
> Ok, consider me convinced. I don't want to apply this before I get 2.6.10 
> out the door, but I'm happy with it.

There were concerns about some architectures relying upon page_table_lock
for exclusivity within their own pte handling functions.  Have they all
been resolved?

> I assume Andrew has already picked up the previous version.

Nope.  It has major clashes with the 4-level-pagetable work.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
