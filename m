Date: Sat, 5 May 2007 19:11:53 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 2/3] SLUB: Implement targeted reclaim and partial list defragmentation
Message-ID: <20070505171153.GA19957@one.firstfloor.org>
References: <20070504221555.642061626@sgi.com> <20070504221708.596112123@sgi.com> <p738xc3wo66.fsf@bingen.suse.de> <Pine.LNX.4.64.0705050840570.26574@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705050840570.26574@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Sat, May 05, 2007 at 08:42:50AM -0700, Christoph Lameter wrote:
> On Sat, 5 May 2007, Andi Kleen wrote:
> 
> > clameter@sgi.com writes:
> > > 
> > > NOTE: This patch is for conceptual review. I'd appreciate any feedback
> > > especially on the locking approach taken here. It will be critical to
> > > resolve the locking issue for this approach to become feasable.
> > 
> > Do you have any numbers on how this improves dcache reclaim under memory pressure?
> 
> How does one measure something like that?

You could measure how many dentries are flushed before an > order 1 allocation
is satisfied?  Make sure to fill the dcache first.

There are no counters there for this, but that should be reasonably easy to add.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
