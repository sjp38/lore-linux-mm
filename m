Date: Thu, 26 Jan 2006 15:19:55 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] hugepage allocator cleanup
Message-ID: <20060126141955.GB6940@wotan.suse.de>
References: <20060125091103.GA32653@wotan.suse.de> <20060125150513.GF7655@holomorphy.com> <20060125151846.GB25666@wotan.suse.de> <20060125163243.GG7655@holomorphy.com> <20060125165208.GC25666@wotan.suse.de> <20060126030424.GH7655@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060126030424.GH7655@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 25, 2006 at 07:04:24PM -0800, William Lee Irwin III wrote:
> On Wed, Jan 25, 2006 at 08:32:43AM -0800, William Lee Irwin III wrote:
> >> Just yanking the page refcount affairs out of update_and_free_page()
> >> should suffice. Could I get things trimmed down to that?
> >> 
> 
> On Wed, Jan 25, 2006 at 05:52:08PM +0100, Nick Piggin wrote:
> > I could remove the first set_page_count, and make the second conditional
> > on the page having a zero refcount... for a 3-liner. But that's kind of
> > ugly (if less intrusive), and it is adds seemingly nonsense code if one
> > doesn't have the context of my out-of-tree patches.
> > Hmm... it's obviously not 2.6.16 material so there is no rush to think
> > it over. It is even simple enough that I don't mind carrying with my
> > patchset indefinitely.
> 
> After I thought about it, alloc_fresh_huge_page() does enqueue pages
> with refcounts of 1, where free_huge_page() (called from the freeing
> hook in page[1].mapping) enqueues pages with refcounts of 0, so it

Yep.

> would actually make sense (and possibly prevent leaks) to take the
> whole patch as-is.
> 
> 

Yeah, you could add a bad_page-like check to verify the refcount
hasn't been mucked with... and of course the regular allocator can
now verify refcounts are alright when update_and_free_page returns
them.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
