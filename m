Date: Thu, 15 Mar 2007 13:22:07 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/2] splice: dont steal
Message-ID: <20070315122207.GA8321@wotan.suse.de>
References: <20070314121440.GA926@wotan.suse.de> <20070315115237.GM15400@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070315115237.GM15400@kernel.dk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 15, 2007 at 12:52:37PM +0100, Jens Axboe wrote:
> On Wed, Mar 14 2007, Nick Piggin wrote:
> > Here are a couple of splice patches I found when digging in the area.
> > I could be wrong, so I'd appreciate confirmation.
> > 
> > Untested other than compile, because I don't have a good splice test
> > setup.
> > 
> > Considering these are data corruption / information leak issues, then
> > we could do worse than to merge them in 2.6.21 and earlier stable
> > trees.
> > 
> > Does anyone really use splice stealing?
> 
> That's a damn shame, I'd greatly prefer if we can try and fix it
> instead. Splice isn't really all that used yet to my knowledge, but
> stealing is one of the niftier features I think. Otherwise you're just
> copying data again.

We should be able to allow for it with the new a_ops API I'm working
on.

Basically we can pass the page down to the filesystem, and tell it to
attempt to install that page in-place.

The problem is that we can't just put this page here hoping the fs can
take it, becaue it might fail allocating blocks, for example.

Anyway, we can still copy files with 1 less copy than read/write ;)

It is a nifty feature, but I think it is more of a niche than simply
saving that 1 copy, because you have to know that the source isn't
going to be used again.

But I'll try to support it with begin_write.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
