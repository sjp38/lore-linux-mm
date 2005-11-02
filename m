Message-ID: <43680923.1040007@jp.fujitsu.com>
Date: Wed, 02 Nov 2005 09:32:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <4366A8D1.7020507@yahoo.com.au> <Pine.LNX.4.58.0510312333240.29390@skynet> <4366C559.5090504@yahoo.com.au> <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au> <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu> <1130854224.14475.60.camel@localhost> <20051101142959.GA9272@elte.hu> <1130856555.14475.77.camel@localhost> <20051101150142.GA10636@elte.hu> <43679C69.6050107@jp.fujitsu.com> <Pine.LNX.4.58.0511011708000.14884@skynet>
In-Reply-To: <Pine.LNX.4.58.0511011708000.14884@skynet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Ingo Molnar <mingo@elte.hu>, Dave Hansen <haveblue@us.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> 3. When adding a node that must be removable, make the array look like
> this
> 
> int fallback_allocs[RCLM_TYPES-1][RCLM_TYPES+1] = {
>         {RCLM_NORCLM,   RCLM_TYPES,    RCLM_TYPES,  RCLM_TYPES, RCLM_TYPES},
>         {RCLM_EASY,     RCLM_FALLBACK, RCLM_NORCLM, RCLM_KERN, RCLM_TYPES},
>         {RCLM_KERN,     RCLM_TYPES,    RCLM_TYPES,  RCLM_TYPES, RCLM_TYPES},
> };
> 
> The effect of this is only allocations that are easily reclaimable will
> end up in this node. This would be a straight-forward addition to build
> upon this set of patches. The difference would only be visible to
> architectures that cared.
> 
Thank you for illustration.
maybe fallback_list per pgdat/zone is what I need with your patch.  right ?

-- Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
