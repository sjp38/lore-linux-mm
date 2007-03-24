Date: Fri, 23 Mar 2007 23:39:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] rfc: introduce /dev/hugetlb
Message-Id: <20070323233917.e5c1a4fc.akpm@linux-foundation.org>
In-Reply-To: <b040c32a0703240011ib9a66f3l1701b8adda94401d@mail.gmail.com>
References: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com>
	<20070323205810.3860886d.akpm@linux-foundation.org>
	<29495f1d0703232232o3e436c62lddccc82c4dd17b51@mail.gmail.com>
	<20070323221225.bdadae16.akpm@linux-foundation.org>
	<b040c32a0703240011ib9a66f3l1701b8adda94401d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Nish Aravamudan <nish.aravamudan@gmail.com>, Adam Litke <agl@us.ibm.com>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 24 Mar 2007 00:11:32 -0700 "Ken Chen" <kenchen@google.com> wrote:

> On 3/23/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > a) Ken observes that obtaining private hugetlb memory via hugetlbfs
> >    involves "fuss".
> >
> > b) the libhugetlbfs maintainers then go off and implement a no-fuss way of
> >    doing this.
> 
> Hmm, what started this thread was libhugetlbfs maintainer complained
> how "fuss" it was to create private hugetlb mapping and suggested an
> even bigger kernel change with pagetable_operations API.

OK.  I wasn't paying particularly close attention.  But my rant still
stands ;)

>  The new API
> was designed with an end goal of introduce /dev/hugetlb (as one of the
> feature, they might be thinking more).  What motivated me here is to
> point out that we can achieve the same goal of having a /dev/hugetlb
> with existing hugetlbfs infrastructure and the implementation is
> relatively straightforward.  What it also buys us is a bit more
> flexibility to the end user who wants to use the interface directly.

OK.

Why is it a "fuss" to do this with hugetlbfs files, btw?

Having read back through the thread, the only substantiation I can really
see is

  The pagetable_operations API opens up possibilities to do some
  additional (and completely sane) things.  For example, I have a patch
  that alters the character device code below to make use of a hugetlb
  ZERO_PAGE.  This eliminates almost all the up-front fault time, allowing
  pages to be COW'ed only when first written to.  We cannot do things like
  this with hugetlbfs anymore because we have a set of complex semantics to
  preserve.


Why is this actually a useful feature?

What does "complex semantics to preserve" mean?


I dunno.  I see a lot of code flying around, but comparatively little
effort to describe the actual problems which we're trying to solve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
