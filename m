Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ED49B8D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 18:59:03 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2UMhUx3032292
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:43:30 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2UMww33114540
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:58:58 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2UMwuEe015892
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:58:57 -0600
Subject: Re: [RFC][PATCH 2/2] make new alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110322191503.91DA6036@kernel>
References: <20110322191501.7EEC645D@kernel>
	 <20110322191503.91DA6036@kernel>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 30 Mar 2011 15:58:54 -0700
Message-ID: <1301525934.31087.21.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2011-03-22 at 12:15 -0700, Dave Hansen wrote:
> 
>                 while (used < alloc_end) {
> -                       free_page(used);
> -                       used += PAGE_SIZE;
> +                       __free_page(page);
> +                       used++;
>                 } 

Please note that I'm a dummy and put "page" in there instead of "used".
I'll repost these with a proper inclusion request soon.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
