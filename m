Date: Thu, 6 Oct 2005 16:12:07 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/7] Fragmentation Avoidance V16: 002_usemap
In-Reply-To: <20051005.163847.73221396.davem@davemloft.net>
Message-ID: <Pine.LNX.4.58.0510061610390.1255@skynet>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
 <20051005144557.11796.2110.sendpatchset@skynet.csn.ul.ie>
 <20051005.163847.73221396.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: linux-mm@kvack.org, akpm@osdl.org, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, jschopp@austin.ibm.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wed, 5 Oct 2005, David S. Miller wrote:

> From: Mel Gorman <mel@csn.ul.ie>
> Date: Wed,  5 Oct 2005 15:45:57 +0100 (IST)
>
> > +	unsigned int type = 0;
>  ...
> > +	bitidx = pfn_to_bitidx(zone, pfn);
> > +	usemap = pfn_to_usemap(zone, pfn);
> > +
>
> There seems no strong reason not to use "unsigned long" for "type" and
> besides that will provide the required alignment for the bitops
> interfaces.  "unsigned int" is not sufficient.
>

There is no strong reason. I'll convert them to unsigned longs and check
for implicit type conversions.

> Then we also don't need to thing about "does this work on big-endian
> 64-bit" and things of that nature.
>

Always a plus.

> Please audit your other bitops uses for this issue.
>

I will. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
