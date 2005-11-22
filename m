Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH 5/5] Light fragmentation avoidance without usemap: 005_drainpercpu
Date: Tue, 22 Nov 2005 15:43:33 -0800
Message-ID: <01EF044AAEE12F4BAAD955CB75064943053DF65D@scsmsx401.amr.corp.intel.com>
From: "Seth, Rohit" <rohit.seth@intel.com>
Sender: owner-linux-mm@kvack.org
From: Mel Gorman Sent: Tuesday, November 22, 2005 11:18 AM
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
Cc: nickpiggin@yahoo.com.au, ak@suse.de, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

>Per-cpu pages can accidentally cause fragmentation because they are
free, >but
>pinned pages in an otherwise contiguous block.  When this patch is
applied,
>the per-cpu caches are drained after the direct-reclaim is entered if
the

I don't think this is the right place to drain the pcp.  Since direct
reclaim is already done, so it is possible that allocator can service
the request without draining the pcps. 


>requested order is greater than 3. 

Why this order limit.  Most of the previous failures seen (because of my

earlier patches of bigger and more physical contiguous chunks for pcps) 
were with order 1 allocation.

>It simply reuses the code used by suspend
>and hotplug and only is triggered when anti-defragmentation is enabled.
>
That code has issues with pre-emptible kernel.

I will be shortly sending the patch to free pages from pcp when higher
order
allocation is not able to get serviced from global list.

-rohi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
