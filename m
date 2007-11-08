Date: Thu, 8 Nov 2007 13:47:35 -0600
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 02/23] SLUB: Rename NUMA defrag_ratio to remote_node_defrag_ratio
Message-ID: <20071108194735.GW19691@waste.org>
References: <20071107011130.382244340@sgi.com> <20071107011226.844437184@sgi.com> <20071108145044.GB2591@skynet.ie> <20071108172548.GW17536@waste.org> <Pine.LNX.4.64.0711081116060.9279@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711081116060.9279@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 08, 2007 at 11:16:33AM -0800, Christoph Lameter wrote:
> On Thu, 8 Nov 2007, Matt Mackall wrote:
> 
> > > I cannot figure out what the number of cycles currently showing on the TSC
> > > have to do with a ratio :(. I could semi-understand if we were counting up
> > > how many cycles were being spent trying to pack objects but that does not
> > > appear to be the case. The comment didn't help a whole lot either. It felt
> > > like a cost for packing, not a ratio
> > 
> > It's just a random number generator. And a bad one: lots of arches
> > return 0. And I believe at least one of them has some NUMA support.
> 
> Do we have a better one? Something with minimal processing overhead? I'd 
> be glad to switch it.

Not really. drivers/char/random.c does:

__get_cpu_var(trickle_count)++ & 0xfff

for a similar purpose.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
