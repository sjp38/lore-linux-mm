Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95Gq4gP009176
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 12:52:04 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95Gq4t2087628
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 12:52:04 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j95Gq4RO008463
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 12:52:04 -0400
Subject: Re: [PATCH 5/7] Fragmentation Avoidance V16: 005_fallback
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051005144612.11796.35309.sendpatchset@skynet.csn.ul.ie>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
	 <20051005144612.11796.35309.sendpatchset@skynet.csn.ul.ie>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 09:51:55 -0700
Message-Id: <1128531115.26009.32.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, jschopp@austin.ibm.com, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 15:46 +0100, Mel Gorman wrote:
> 
> + */
> +static inline struct free_area *
> +fallback_buddy_reserve(int start_alloctype, struct zone *zone,
> +                       unsigned int current_order, struct page *page,
> +                       struct free_area *area)
> +{
> +       if (start_alloctype != RCLM_NORCLM)
> +               return area;
> +
> +       area = &(zone->free_area_lists[RCLM_NORCLM][current_order]);
> +
> +       /* Reserve the whole block if this is a large split */
> +       if (current_order >= MAX_ORDER / 2) {
> +               int reserve_type=RCLM_NORCLM;

-EBADCODINGSTYLE.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
