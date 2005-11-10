Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAAHa3qK002276
	for <linux-mm@kvack.org>; Thu, 10 Nov 2005 12:36:03 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jAAHa2vh088762
	for <linux-mm@kvack.org>; Thu, 10 Nov 2005 12:36:03 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jAAHa2Ol028188
	for <linux-mm@kvack.org>; Thu, 10 Nov 2005 12:36:02 -0500
Message-ID: <437384FB.1050804@austin.ibm.com>
Date: Thu, 10 Nov 2005 11:35:55 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [Patch:RFC] New zone ZONE_EASY_RECLAIM[4/5]
References: <20051110190053.0236.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20051110190053.0236.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Yasunori Goto wrote:
>
> ===================================================================
> --- new_zone.orig/include/linux/mmzone.h	2005-11-08 17:27:30.000000000 +0900
> +++ new_zone/include/linux/mmzone.h	2005-11-08 17:27:37.000000000 +0900
> @@ -92,6 +92,7 @@ struct per_cpu_pageset {
>   * combinations of zone modifiers in "zone modifier space".
>   */
>  #define GFP_ZONEMASK	0x07
> +
>  /*
>   * As an optimisation any zone modifier bits which are only valid when
>   * no other zone modifier bits are set (loners) should be placed in
> Index: new_zone/mm/mempolicy.c
> ===================================================================

It looks like the only thing this patch changes in this file is whitespace

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
