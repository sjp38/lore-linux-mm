Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6FB3F6B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 10:12:29 -0400 (EDT)
Date: Wed, 29 Sep 2010 09:12:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: zone state overhead
In-Reply-To: <20100929100307.GA14204@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009290736280.30777@router.home>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie> <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com> <20100929100307.GA14204@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 2010, Mel Gorman wrote:

> Alternatively we could revisit Christoph's suggestion of modifying
> stat_threshold when under pressure instead of zone_page_state_snapshot. Maybe
> by temporarily stat_threshold when kswapd is awake to a per-zone value
> such that
>
> zone->low + threshold*nr_online_cpus < high

Updating the threshold also is expensive. I thought more along the lines
of reducing the threshold for good if the VM runs into reclaim trouble
because of too high fuzziness in the counters.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
