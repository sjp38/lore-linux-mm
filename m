Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 07EE98D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 15:42:57 -0400 (EDT)
Date: Tue, 22 Mar 2011 20:42:54 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH 1/2] rename alloc_pages_exact()
Message-ID: <20110322194254.GB21838@one.firstfloor.org>
References: <20110322191501.7EEC645D@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110322191501.7EEC645D@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Mar 22, 2011 at 12:15:02PM -0700, Dave Hansen wrote:
> 
> alloc_pages_exact() returns a virtual address.  But, alloc_pages() returns
> a 'struct page *'.  That makes for very confused kernel hackers.
> 
> __get_free_pages(), on the other hand, returns virtual addresses.  That
> makes alloc_pages_exact() a much closer match to __get_free_pages(), so
> rename it to get_free_pages_exact().
> 
> Note that alloc_pages_exact()'s partner, free_pages_exact() already
> matches free_pages(), so we do not have to touch the free side of things.

Yes, that was wrong from the start. Thanks for fixing.

Acked-by: Andi Kleen <ak@linux.intel.com>

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
