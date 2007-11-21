Date: Wed, 21 Nov 2007 15:23:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
Message-Id: <20071121152328.72697909.akpm@linux-foundation.org>
In-Reply-To: <20071121222059.GC31674@csn.ul.ie>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com>
	<20071115162706.4b9b9e2a.akpm@linux-foundation.org>
	<20071121222059.GC31674@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: clameter@sgi.com, linux-mm@kvack.org, apw@shadowen.org, mbligh@mbligh.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Nov 2007 22:20:59 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> I cannot see the evidence of this 3x improvement around the 32K filesize
> mark. It may be because my test is very different to what happened before,
> I got something wrong or the per-CPU allocator is not as good as it used to
> be and does not give out the same hot-pages all the time.

Could be that when you return a handful of pages to the page allocator
and then allocate a handful of pages, you get the same pages back.  But
that the page allocator wasn't doing that 4-5 years ago when that code
went in.

Of course, even if the page allocator is indeed doing this for us, you'd
still expect to see benefits from the per-cpu magazines when each CPU is
allocating and freeing a number of pages which is close to the size of
that CPU's L1 cache.  Because when the pages are going into and coming from
a shared-by-all-cpus pool, each CPU will often get pages which are hot in
a different cpu's L1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
