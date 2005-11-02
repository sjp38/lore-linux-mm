Message-ID: <436880B8.1050207@yahoo.com.au>
Date: Wed, 02 Nov 2005 20:02:48 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <4366C559.5090504@yahoo.com.au> <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au> <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu> <1130854224.14475.60.camel@localhost> <20051101142959.GA9272@elte.hu> <1130856555.14475.77.camel@localhost> <20051101150142.GA10636@elte.hu> <1130858580.14475.98.camel@localhost> <20051102084946.GA3930@elte.hu>
In-Reply-To: <20051102084946.GA3930@elte.hu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Hansen <haveblue@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, Arjan van de Ven <arjanv@infradead.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:

> really, once you accept that, the path out of this mess becomes 'easy': 
> we _have to_ compromise on the feature side! And the moment we give up 
> the notion of 'generic kernel RAM' and focus on the hot-removability of 
> a limited-functionality zone, the complexity of the solution becomes 
> three orders of magnitude smaller. No fragmentation avoidance necessary.  
> No 'have to handle dozens of very hard problems to become 99% 
> functional' issues. Once you make that zone an opt-in thing, it becomes 
> much better from a development dynamics point of view as well.
> 

I agree. Especially considering that all this memory hotplug usage for
hypervisors etc. is a relatively new thing with few of our userbase
actually using it. I think a simple zones solution is the right way to
go for now.

In future, if we have a large proportion of users who want it, and
their requirements are better understood, and there is still no
hardware / hypervisor support for handling this for us, *then* it is
time to re-evaluate our compromise.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
