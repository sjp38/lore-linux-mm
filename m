Date: Thu, 02 Jun 2005 22:34:42 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: Avoiding external fragmentation with a placement policy Version 12
Message-ID: <357240000.1117776882@[10.10.2.4]>
In-Reply-To: <20050602.214927.59657656.davem@davemloft.net>
References: <429E50B8.1060405@yahoo.com.au><429F2B26.9070509@austin.ibm.com><1117770488.5084.25.camel@npiggin-nld.site> <20050602.214927.59657656.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: jschopp@austin.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

>> It would really help your cause in the short term if you can
>> demonstrate improvements for say order-3 allocations (eg. use
>> gige networking, TSO, jumbo frames, etc).
> 
> TSO chops up the user data into PAGE_SIZE chunks, it doesn't
> make use of non-zero page orders.
> 
> AF_UNIX sockets, however, will happily use higher order
> pages.  But even this is limited to SKB_MAX_ORDER which
> is currently defined to 2.
> 
> So the only way to get order 3 or larger allocations with
> the networking is to use jumbo frames but without TSO enabled.

One of the calls I got the other day was for loopback interface. 
Default MTU is 16K, which seems to screw everything up and do higher 
order allocs. Turning it down to under 4K seemed to fix things. I'm 
fairly sure loopback doesn't really need phys contig memory, but it 
seems to use it at the moment ;-)

> Actually, even with TSO enabled, you'll get large order
> allocations, but for receive packets, and these allocations
> happen in software interrupt context.

Sounds like we still need to cope then ... ?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
