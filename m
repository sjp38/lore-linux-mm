Date: Thu, 12 Jul 2007 10:18:57 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: unlockless reclaim
Message-ID: <20070712081857.GC1830@wotan.suse.de>
References: <20070712041115.GH32414@wotan.suse.de> <20070712004339.0f5b7a2f.akpm@linux-foundation.org> <20070712075532.GB1830@wotan.suse.de> <20070712010007.164acc8e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070712010007.164acc8e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 12, 2007 at 01:00:07AM -0700, Andrew Morton wrote:
> On Thu, 12 Jul 2007 09:55:32 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > > 
> > > mutter.
> > > 
> > > So why does __pagevec_release_nonlru() check the page refcount?
> > 
> > It doesn't
> 
> yes it does

That was in answer to your question: I mean: it doesn't need to.


> > although it will have to return the count to zero of course.
> > 
> > I don't want to submit that because the lockless pagecache always needs
> > the refcount to be checked :) And which I am actually going to submit to
> > you after you chuck out a few patches.
> > 
> > But unlock_page is really murderous on my powerpc (with all the
> > unlock-speeup patches, dd if=/dev/zero of=/dev/null of a huge sparse file
> > goes up by 10% throughput on the G5!!).
> 
> well this change won't help that much.

Oh, well the dd includes reclaim and so it ends up doing 2 locks for
each page (1 to reading, 1 to reclaim). So this alone supposedly should
help by 5% :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
