Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0B34B6B0023
	for <linux-mm@kvack.org>; Wed,  4 May 2011 18:11:28 -0400 (EDT)
Date: Thu, 5 May 2011 00:11:25 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Allocate memory cgroup structures in local nodes v2 II
Message-ID: <20110504221125.GB2925@one.firstfloor.org>
References: <1304540783-8247-1-git-send-email-andi@firstfloor.org> <20110504213850.GA16685@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110504213850.GA16685@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, rientjes@google.com, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>

> alloc_pages_exact_node takes an order, not a size argument.
> 
> alloc_pages_exact_node returns a pointer to the struct page, not to
> the allocated memory, like all other alloc_pages* functions with the
> exception of alloc_pages_exact.

In addition to all of this it's also not exact, but just a normal
order of two allocation.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
