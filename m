Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95Gjq2Y023529
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 12:45:52 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95GnIx4489670
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 10:49:18 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j95GmZw4025432
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 10:48:35 -0600
Subject: Re: [PATCH 3/7] Fragmentation Avoidance V16: 003_fragcore
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051005144602.11796.53850.sendpatchset@skynet.csn.ul.ie>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
	 <20051005144602.11796.53850.sendpatchset@skynet.csn.ul.ie>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 09:48:27 -0700
Message-Id: <1128530908.26009.28.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, jschopp@austin.ibm.com, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 15:46 +0100, Mel Gorman wrote:
> 
> @@ -1483,8 +1540,10 @@ void show_free_areas(void)
>  
>                 spin_lock_irqsave(&zone->lock, flags);
>                 for (order = 0; order < MAX_ORDER; order++) {
> -                       nr = zone->free_area[order].nr_free;
> -                       total += nr << order;
> +                       for (type=0; type < RCLM_TYPES; type++) {
> +                               nr = zone->free_area_lists[type][order].nr_free;
> +                               total += nr << order;
> +                       }

Can that use the new for_each_ macro?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
