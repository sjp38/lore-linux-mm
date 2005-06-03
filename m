Date: Fri, 03 Jun 2005 06:57:42 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: Avoiding external fragmentation with a placement policy Version 12
Message-ID: <369850000.1117807062@[10.10.2.4]>
In-Reply-To: <429FFC21.1020108@yahoo.com.au>
References: <429E50B8.1060405@yahoo.com.au><429F2B26.9070509@austin.ibm.com><1117770488.5084.25.camel@npiggin-nld.site> <20050602.214927.59657656.davem@davemloft.net> <357240000.1117776882@[10.10.2.4]> <429FFC21.1020108@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "David S. Miller" <davem@davemloft.net>, jschopp@austin.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>


>>> Actually, even with TSO enabled, you'll get large order
>>> allocations, but for receive packets, and these allocations
>>> happen in software interrupt context.
>> 
>> Sounds like we still need to cope then ... ?
> 
> Sure. Although we should try to not use higher order allocs if
> possible of course. Even with a fallback mode, you will still be
> putting more pressure on higher order areas and thus degrading
> the service for *other* allocators, so such schemes should
> obviously be justified by performance improvements.

My point is that outside of a benchmark situation (where we just
rebooted the machine to run a test) you will NEVER get an order 4
block free anyway, so it's pointless. Moreover, if we use non-contig
order 0 blocks, we can use cache hot pages ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
