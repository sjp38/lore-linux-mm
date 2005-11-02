Message-ID: <436891AE.1040709@yahoo.com.au>
Date: Wed, 02 Nov 2005 21:15:10 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie><20051031055725.GA3820@w-mikek2.ibm.com><4365BBC4.2090906@yahoo.com.au> <20051030235440.6938a0e9.akpm@osdl.org> <27700000.1130769270@[10.10.2.4]> <4366A8D1.7020507@yahoo.com.au> <Pine.LNX.4.58.0510312333240.29390@skynet> <4366C559.5090504@yahoo.com.au> <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au> <4367D71A.1030208@austin.ibm.com> <43681100.1000603@yahoo.com.au> <214340000.1130895665@[10.10.2.4]> <43681E89.8070905@yahoo.com.au> <216280000.1130898244@[10.10.2.4]> <43682940.3020200@yahoo.com.au> <217570000.1130906356@[10.10.2.4]> <43684A16.70401@yahoo.com.au> <231260000.1130908490@[10.10.2.4]> <43685B63.7020701@jp.fujitsu.com>
In-Reply-To: <43685B63.7020701@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Joel Schopp <jschopp@austin.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Martin J. Bligh wrote:
> 

> please check kmalloc(32k,64k)
> 
> For example, loopback device's default MTU=16436 means order=3 and
> maybe there are other high MTU device.
> 
> I suspect skb_makewritable()/skb_copy()/skb_linearize() function can be
> sufferd from fragmentation when MTU is big. They allocs large skb by
> gathering fragmented skbs.When these skb_* funcs failed, the packet
> is silently discarded by netfilter. If fragmentation is heavy, packets
> (especialy TCP) uses large MTU never reachs its end, even if loopback.
> 
> Honestly, I'm not familiar with network code, could anyone comment this ?
> 

I'd be interested to know, actually. I was hoping loopback should always
use order-0 allocations, because the loopback driver is SG, FRAGLIST,
and HIGHDMA capable. However I'm likewise not familiar with network code.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
