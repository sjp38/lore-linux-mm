Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l743INae020126
	for <linux-mm@kvack.org>; Fri, 3 Aug 2007 23:18:23 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l743INPe255602
	for <linux-mm@kvack.org>; Fri, 3 Aug 2007 21:18:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l743IMB2000620
	for <linux-mm@kvack.org>; Fri, 3 Aug 2007 21:18:23 -0600
Date: Fri, 3 Aug 2007 20:18:19 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 00/14] NUMA: Memoryless node support V3
Message-ID: <20070804031819.GD15714@us.ibm.com>
References: <20070804030100.862311140@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070804030100.862311140@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On 03.08.2007 [20:01:00 -0700], Christoph Lameter wrote:
> V4->V5
> - Split N_MEMORY into N_NORMAL_MEMORY and N_HIGH_MEMORY to support
>   32 bit NUMA.
> - Mel tested it on 32bit NUMA
> - !NUMA Fixes
> - Tested on SMP and UP.
> 
> V3->V4 (by Lee)
> - Add fixes and testing.
> 
> V2->V3
> - Refresh patches (sigh)
> - Add comments suggested by Kamezawa Hiroyuki
> - Add signoff by Jes Sorensen
> 
> V1->V2
> - Add a generic layer that allows the definition of additional node bitmaps
> 
> This patchset is implementing additional node bitmaps that allow the system
> to track nodes that are online without memory and nodes that have processors.
> 
> Note that this patch is only the beginning. All code portions that assume that
> an online node has memory must be changed to use either N_NORMAL_MEMORY or
> N_HIGH_MEMORY.

I believe Andrew should drop the 9 memoryless node patches he had picked
up and take these instead. The NORMAL_MEMORY/HIGH_MEMORY distinction is
critical for booting 32-bit NUMA. I've rebased my stack of hugetlb
related patches on top of these and am testing now.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
