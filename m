Date: Thu, 8 Nov 2007 11:25:48 -0600
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 02/23] SLUB: Rename NUMA defrag_ratio to remote_node_defrag_ratio
Message-ID: <20071108172548.GW17536@waste.org>
References: <20071107011130.382244340@sgi.com> <20071107011226.844437184@sgi.com> <20071108145044.GB2591@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071108145044.GB2591@skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 08, 2007 at 02:50:44PM +0000, Mel Gorman wrote:
> > -	if (!s->defrag_ratio || get_cycles() % 1024 > s->defrag_ratio)
> > +	if (!s->remote_node_defrag_ratio ||
> > +			get_cycles() % 1024 > s->remote_node_defrag_ratio)
> 
> I cannot figure out what the number of cycles currently showing on the TSC
> have to do with a ratio :(. I could semi-understand if we were counting up
> how many cycles were being spent trying to pack objects but that does not
> appear to be the case. The comment didn't help a whole lot either. It felt
> like a cost for packing, not a ratio

It's just a random number generator. And a bad one: lots of arches
return 0. And I believe at least one of them has some NUMA support.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
