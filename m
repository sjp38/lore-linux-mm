Date: Fri, 1 Oct 2004 16:04:30 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Message-ID: <20041001190430.GA4372@logos.cnet>
References: <20041001182221.GA3191@logos.cnet> <20041001131147.3780722b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041001131147.3780722b.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, piggin@cyberone.com.au, arjanv@redhat.com, linux-kernel@vger.kernel.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, Oct 01, 2004 at 01:11:47PM -0700, Andrew Morton wrote:
> Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> >
> > The following patch implements a "coalesce_memory()" function 
> > which takes "zone" and "order" as a parameter. 
> > 
> > It tries to move enough physically nearby pages to form a free area
> > of "order" size.
> > 
> > It does that by checking whether the page can be moved, allocating a new page, 
> > unmapping the pte's to it, copying data to new page, remapping the ptes, 
> > and reinserting the page on the radix/LRU.
> 
> Presumably this duplicates some of the memory hot-remove patches.

As far as I have researched, the memory moving/remapping code 
on the hot remove patches dont work correctly. Please correct me.

And what I've seen (from the Fujitsu guys) was quite ugly IMHO.

> Apparently Dave Hansen has working and sane-looking hot remove code
> which is in a close-to-submittable state.

Dave?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
