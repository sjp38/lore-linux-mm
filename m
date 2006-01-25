Date: Wed, 25 Jan 2006 17:52:08 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] hugepage allocator cleanup
Message-ID: <20060125165208.GC25666@wotan.suse.de>
References: <20060125091103.GA32653@wotan.suse.de> <20060125150513.GF7655@holomorphy.com> <20060125151846.GB25666@wotan.suse.de> <20060125163243.GG7655@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060125163243.GG7655@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 25, 2006 at 08:32:43AM -0800, William Lee Irwin III wrote:
> 
> Preparatory cleanups are fine by me barring where things get to the
> point of churn, which isn't a concern here.
> 

Cool.

> It appears the crucial component of this update_and_free_page(). It
> shouldn't be necessary as disciplined page->_count references are
> redirected to the head of the hugepage, but it's trying to clean up the
> page->_counts in tail pages of the hugepage in preparation for freeing.

Yes, that is the crucial part.

> Arguably 1->0 transition logic shouldn't be triggered, but the locking
> protocol envisioned may not allow unconditionally setting page->_count.
> 

Unfortunately yes I wasn't clear I guess. Any page with a nonzero
refcount must not be unconditionally set.

> Just yanking the page refcount affairs out of update_and_free_page()
> should suffice. Could I get things trimmed down to that?
> 

I could remove the first set_page_count, and make the second conditional
on the page having a zero refcount... for a 3-liner. But that's kind of
ugly (if less intrusive), and it is adds seemingly nonsense code if one
doesn't have the context of my out-of-tree patches.

Hmm... it's obviously not 2.6.16 material so there is no rush to think
it over. It is even simple enough that I don't mind carrying with my
patchset indefinitely.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
