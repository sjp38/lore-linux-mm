Message-ID: <436888E7.1060609@yahoo.com.au>
Date: Wed, 02 Nov 2005 20:37:43 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com>
In-Reply-To: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit Huizenga <gh@us.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Gerrit Huizenga wrote:
> On Wed, 02 Nov 2005 19:50:15 +1100, Nick Piggin wrote:

>>Isn't the solution for your hypervisor problem to dish out pages of
>>the same size that are used by the virtual machines. Doesn't this
>>provide you with a nice, 100% solution that doesn't add complexity
>>where it isn't needed?
> 
> 
> So do you see the problem with fragementation if the hypervisor is
> handing out, say, 1 MB pages?  Or, more likely, something like 64 MB
> pages?  What are the chances that an entire 64 MB page can be freed
> on a large system that has been up a while?
> 

I see the problem, but if you want to be able to shrink memory to a
given size, then you must either introduce a hard limit somewhere, or
have the hypervisor hand out guest sized pages. Use zones, or Xen?

> And, if you create zones, you run into all of the zone rebalancing
> problems of ZONE_DMA, ZONE_NORMAL, ZONE_HIGHMEM.  In that case, on
> any long running system, ZONE_HOTPLUGGABLE has been overwhelmed with
> random allocations, making almost none of it available.
> 

If there are zone rebalancing problems[*], then it would be great to
have more users of zones because then they will be more likely to get
fixed.

[*] and there are, sadly enough - see the recent patches I posted to
     lkml for example. But I'm fairly confident that once the particularly
     silly ones have been fixed, zone balancing will no longer be a
     derogatory term as has been thrown around (maybe rightly) in this
     thread!

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
