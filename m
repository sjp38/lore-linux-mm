Date: Fri, 13 Jul 2007 10:40:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/7] Sparsemem Virtual Memmap V5
Message-Id: <20070713104044.0d090c79.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707131001060.21777@schroedinger.engr.sgi.com>
References: <exportbomb.1184333503@pinky>
	<Pine.LNX.4.64.0707131001060.21777@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007 10:04:45 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 13 Jul 2007, Andy Whitcroft wrote:
> 
> > Andrew, please consider for -mm.
> > 
> > Note that I am away from my keyboard all of next week, but I figured
> > it better to get this out for testing.
> 
> Yes grumble. Why does it take so long...

gaah, I read linux-arch and linux-mm rather intermittently and I haven't
even seen these yet.

> Would it be possible to merge this for 2.6.23 (maybe late?).

It would be nice to see a bit of spirited reviewing from the affected arch
maintainers and mm people...

There's already an enormous amount of mm stuff banked up and it looks like
I get to hold onto a lot of that until 2.6.24.  We seem to be spending too
little time on the first 90% of new stuff and too little time on the last
10% of existing stuff.


> This has been 
> around for 6 months now. It removes the troubling lookups in 
> virt_to_page and page_address in sparsemem that have spooked many of us. 
> 
> virt_to_page efficiency is a performance issue for kfree and 
> kmem_cache_free in the slab allocators. I inserted probles and saw 
> that the patchset cuts down the cycles spend in virt_to_page by 50%.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
