Date: Thu, 23 Aug 2007 13:48:48 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re:
	vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-aroun
	d-the-lru
Message-ID: <20070823114844.GM13915@v2.random>
References: <20070823041137.GH18788@wotan.suse.de> <20070823001517.1252911b.akpm@linux-foundation.org> <20070823090722.GA25225@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070823090722.GA25225@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Bligh <mbligh@mbligh.org>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 23, 2007 at 11:07:22AM +0200, Nick Piggin wrote:
> On Thu, Aug 23, 2007 at 12:15:17AM -0700, Andrew Morton wrote:
> > On Thu, 23 Aug 2007 06:11:37 +0200 Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc3/2.6.23-rc3-mm1/broken-out/vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
> > > 
> > > About this patch... I hope it doesn't get merged without good reason...
> > 
> > I have no intention at all of merging it until it's proven to be a net
> > benefit.  This is engineering.  We shouldn't merge VM changes based on
> > handwaving.
> > 
> > It does fix a bug (ie: a difference between design intent and
> > implementation) but I have no idea whether it improves or worsens anything.
> > 
> > > [handwaving]
> > 
> > ;)
> 
> Well what I say is handwaving too, but it is a situation that wouldn't be
> completely unusual to hit. Anyway, I know I don't need to make an airtight
> argument as to why _not_ to merge a patch, so this is just a heads-up to
> be on the lookout for one potential issue I have seen with a similar change.

I like the patch, I consider it a fix but perhaps I'm biased ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
