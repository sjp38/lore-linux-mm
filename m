Date: Mon, 25 Feb 2008 19:21:27 +0000
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: Page scan keeps touching kernel text pages
Message-ID: <20080225192127.GA20322@shadowen.org>
References: <20080224144710.GD31293@lazybastard.org> <20080225150724.GF2604@shadowen.org> <1203961702.6662.35.camel@nimitz.home.sr71.net> <20080225185319.GA14699@lazybastard.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20080225185319.GA14699@lazybastard.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2008 at 07:53:20PM +0100, Jorn Engel wrote:
> On Mon, 25 February 2008 09:48:22 -0800, Dave Hansen wrote:
> > On Mon, 2008-02-25 at 15:07 +0000, Andy Whitcroft wrote:
> > > shrink_page_list() would be expected to be passed pages pulled from
> > > the active or inactive lists via isolate_lru_pages()?  I would not have
> > > expected to find the kernel text on the LRU and therefore not expect to
> > > see it passed to shrink_page_list()?
> > 
> > It may have been kernel text at one time, but what about __init
> > functions?  Don't we free that section back to the normal allocator
> > after init time?  Those can end up on the LRU.
> 
> Pages below 0x2ba should be non-init in my test kernel:
> c02ba000 T __init_begin
> ...
> c02d5000 B __init_end
> 
> scanning zone DMA
> page      3fa        3 00000000 628
> page      2bf        2 00000000 628
> page       97        3 00000000 628
> page       98        2 00000000 628
> 
> So __init explains one page of this minimal sample, but not the other
> three.

I thought that init sections were deliberatly pushed to the end of the
kernel when linked, cirtainly on my laptop here that seems to be so.
That would make the first two "after" the kernel.  The other two appear
to be before the traditional kernel load address, which is 0x100000, so
those pages are before not in the kernel?

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
