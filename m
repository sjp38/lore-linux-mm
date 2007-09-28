Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8SDJ7L5021517
	for <linux-mm@kvack.org>; Fri, 28 Sep 2007 09:19:07 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8SDJ6Xa464272
	for <linux-mm@kvack.org>; Fri, 28 Sep 2007 07:19:06 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8SDJ6cx031968
	for <linux-mm@kvack.org>; Fri, 28 Sep 2007 07:19:06 -0600
Subject: Re: [PATCH 2/4] hugetlb: Try to grow hugetlb pool for MAP_PRIVATE
	mappings
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20070927200910.14951.41144.stgit@kernel>
References: <20070927200848.14951.26553.stgit@kernel>
	 <20070927200910.14951.41144.stgit@kernel>
Content-Type: text/plain
Date: Fri, 28 Sep 2007 08:19:05 -0500
Message-Id: <1190985545.14295.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-09-27 at 13:09 -0700, Adam Litke wrote:
> +/*
> + * Increment or decrement surplus_huge_pages.  Keep node-specific counters
> + * balanced by operating on them in a round-robin fashion.
> + * Returns 1 if an adjustment was made.
> + */
> +static int adjust_pool_surplus(int delta)
> +{
> +	static int prev_nid;
> +	int nid = prev_nid;
> +	int ret = 0;
> +
> +	BUG_ON(delta != -1 || delta != 1);

Ughh.  How about && here instead ;)  Fixed locally.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
