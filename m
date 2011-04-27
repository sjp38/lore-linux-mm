Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DE1DA6B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:37:38 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3RLPJ30028727
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 15:25:19 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p3RLbXTf095508
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 15:37:33 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3RLb5vT027539
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 15:37:06 -0600
Subject: Re: [PATCH 2/3] make new alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4DB88AF0.1050501@freescale.com>
References: <20110414200139.ABD98551@kernel>
	 <20110414200140.CDE09A20@kernel>  <4DB88AF0.1050501@freescale.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 27 Apr 2011 14:37:29 -0700
Message-ID: <1303940249.9516.366.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timur Tabi <timur@freescale.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, David Rientjes <rientjes@google.com>

On Wed, 2011-04-27 at 16:30 -0500, Timur Tabi wrote:
> Dave Hansen wrote:
> > What I really wanted in the end was a highmem-capable
> > alloc_pages_exact(), so here it is.  This function can be used to
> > allocate unmapped (like highmem) non-power-of-two-sized areas of
> > memory.  This is in constast to get_free_pages_exact() which can only
> > allocate from lowmem.
> 
> Is there an easy way to verify that alloc_pages_exact(5MB) really does allocate
> only 5MB and not 8MB?

I'm not sure why you're asking.  How do we know that the _normal_
allocator only gives us 4k when we ask for 4k?  Well, that's just how it
works.  If alloc_pages_exact() returns success, you know it's got the
amount of memory that you asked for, and only that plus a bit of masking
for page alignment.

Have you seen alloc_pages_exact() behaving in some other way?

> Is there some kind of function that returns the amount of
> unallocated memory, so I can do a diff?

Nope.  Even if there was, it would be worthless.  Calls to this might
also cause the system to swap or reclaim memory, so you might end up
with the same amount of free memory before and after the call.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
