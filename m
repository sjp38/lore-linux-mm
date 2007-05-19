Date: Sat, 19 May 2007 03:30:13 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] increase struct page size?!
Message-ID: <20070519013013.GC15569@wotan.suse.de>
References: <20070518040854.GA15654@wotan.suse.de> <7554.1179481350@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7554.1179481350@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2007 at 10:42:30AM +0100, David Howells wrote:
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > I'd like to be the first to propose an increase to the size of struct page
> > just for the sake of increasing it!
> 
> Heh.  I'm surprised you haven't got more adverse reactions.
> 
> > If we add 8 bytes to struct page on 64-bit machines, it becomes 64 bytes,
> > which is quite a nice number for cache purposes.
> 
> Whilst that's true, if you have to deal with a run of contiguous page structs
> (eg: the page allocator, perhaps) it's actually less efficient because it
> takes more cache to do it.  But, hey, it's a compromise whatever.
> 
> In the scheme of things, if we're mostly dealing with individual page structs
> (as I think we are), then yes, I think it's probably a good thing to do -
> especially with larger page sizes.

Yeah, we would end up eating about 12.5% more cachelines for contiguous
runs of pages... but that only kicks in after we've touched 8 of them I
think, and by that point the accesses should be very prefetchable.

I think the average of 75% more cachelines touched for random accesses
is going to outweigh the contiguous batch savings, but that's just a
guess at this point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
