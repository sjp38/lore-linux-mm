Date: Mon, 24 Jan 2005 12:55:18 -0700
From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] Avoiding fragmentation through different allocator
Message-ID: <20050124195518.GA19747@colo.lackof.org>
References: <20050120101300.26FA5E598@skynet.csn.ul.ie> <20050121142854.GH19973@logos.cnet> <Pine.LNX.4.58.0501222128380.18282@skynet> <20050122215949.GD26391@logos.cnet> <Pine.LNX.4.58.0501241141450.5286@skynet> <20050124122952.GA5739@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050124122952.GA5739@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Mel Gorman <mel@csn.ul.ie>, William Lee Irwin III <wli@holomorphy.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, grundler@parisc-linux.org, jejb@steeleye.com, awilliam@fc.hp.com
List-ID: <linux-mm.kvack.org>

On Mon, Jan 24, 2005 at 10:29:52AM -0200, Marcelo Tosatti wrote:
> Grant Grundler and James Bottomley have been working on this area,
> they might want to add some comments to this discussion.
> 
> It seems HP (Grant et all) has pursued using big pages on IA64 (64K)
> for this purpose.

Marcello,
That might have been Alex Williamson...but the reasons for 64K pages
is to reduce TLB thrashing, not faster IO.

On HP ZX1 boxes, SG performance is slightly better (max +5%) when going
through the IOMMU than when bypassing it. The IOMMU can perfectly
coalesce DMA pages but has a small CPU and DMA cost to do so as well.

Otherwise, I totally agree with James. IO devices do scatter-gather
pretty well and IO subsystems are tuned for page-size chunk or
smaller anyway.

...
> > I could keep digging, but I think the bottom line is that having large
> > pages generally available rather than a fixed setting is desirable. 
> 
> Definately, yes. Thanks for the pointers. 

Big pages are good for CPU TLB and that's where most of the
research has been done. I think IO devices have learned to cope
with the fact the alot less has been (or can be for many
workloads) done to coalesce IO pages.

grant
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
