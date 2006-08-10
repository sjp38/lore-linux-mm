Date: Wed, 9 Aug 2006 21:53:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Profiling: Require buffer allocation on the correct node
In-Reply-To: <200608100521.19783.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0608092152120.5748@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608091914470.5464@schroedinger.engr.sgi.com>
 <200608100521.19783.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 Aug 2006, Andi Kleen wrote:

> On Thursday 10 August 2006 04:18, Christoph Lameter wrote:
> > Profiling really suffers with off node buffers. Fail if no memory is available
> > on the nodes. The profiling code can deal with these failures should
> > they occur.
> 
> At least for Opterons and other small NUMAs I have my doubts this is a good strategy.
> However it probably shouldn't happen very often, but if it happened it would be 
> the wrong thing.
> 
> In general shouldn't there be a printk at least? Doing such things silently is a bit
> nasty.

The code already checks for failing allocations and it gives a messages 
AFAIK. This is just a fix so that the allocator does what they thought it 
would be doing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
