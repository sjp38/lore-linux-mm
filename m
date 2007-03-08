Date: Thu, 8 Mar 2007 10:16:27 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 0/3] SLUB: The unqueued slab allocator V4
In-Reply-To: <20070308174004.GB12958@skynet.ie>
Message-ID: <Pine.LNX.4.64.0703081013270.27731@schroedinger.engr.sgi.com>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0703081022040.1615@skynet.skynet.ie>
 <Pine.LNX.4.64.0703080836300.27191@schroedinger.engr.sgi.com>
 <20070308174004.GB12958@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Mar 2007, Mel Gorman wrote:

> > Note that the 16kb page size has a major 
> > impact on SLUB performance. On IA64 slub will use only 1/4th the locking 
> > overhead as on 4kb platforms.
> It'll be interesting to see the kernbench tests then with debugging
> disabled.

You can get a similar effect on 4kb platforms by specifying slub_min_order=2 on bootup.
This means that we have to rely on your patches to allow higher order 
allocs to work reliably though. The higher the order of slub the less 
locking overhead. So the better your patches deal with fragmentation the 
more we can reduce locking overhead in slub.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
