Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9V5vZOD001142
	for <linux-mm@kvack.org>; Mon, 31 Oct 2005 00:57:35 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9V5vZBN533082
	for <linux-mm@kvack.org>; Sun, 30 Oct 2005 22:57:35 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9V5vY7B023751
	for <linux-mm@kvack.org>; Sun, 30 Oct 2005 22:57:35 -0700
Date: Sun, 30 Oct 2005 21:57:25 -0800
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051031055725.GA3820@w-mikek2.ibm.com>
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Sun, Oct 30, 2005 at 06:33:55PM +0000, Mel Gorman wrote:
> Here are a few brief reasons why this set of patches is useful;
> 
> o Reduced fragmentation improves the chance a large order allocation succeeds
> o General-purpose memory hotplug needs the page/memory groupings provided
> o Reduces the number of badly-placed pages that page migration mechanism must
>   deal with. This also applies to any active page defragmentation mechanism.

I can say that this patch set makes hotplug memory remove be of
value on ppc64.  My system has 6GB of memory and I would 'load
it up' to the point where it would just start to swap and let it
run for an hour.  Without these patches, it was almost impossible
to find a section that could be offlined.  With the patches, I
can consistently reduce memory to somewhere between 512MB and 1GB.
Of course, results will vary based on workload.  Also, this is
most advantageous for memory hotlug on ppc64 due to relatively
small section size (16MB) as compared to the page grouping size
(8MB).  A more general purpose solution is needed for memory hotplug
support on architectures with larger section sizes.

Just another data point,
-- 
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
