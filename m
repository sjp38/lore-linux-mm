Date: Sat, 5 May 2007 08:42:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 2/3] SLUB: Implement targeted reclaim and partial list
 defragmentation
In-Reply-To: <p738xc3wo66.fsf@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0705050840570.26574@schroedinger.engr.sgi.com>
References: <20070504221555.642061626@sgi.com> <20070504221708.596112123@sgi.com>
 <p738xc3wo66.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Sat, 5 May 2007, Andi Kleen wrote:

> clameter@sgi.com writes:
> > 
> > NOTE: This patch is for conceptual review. I'd appreciate any feedback
> > especially on the locking approach taken here. It will be critical to
> > resolve the locking issue for this approach to become feasable.
> 
> Do you have any numbers on how this improves dcache reclaim under memory pressure?

How does one measure something like that?

I wanted to first make sure that the thing is sane. If there is a gaping 
race here then I may have to add more code to cover that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
