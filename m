Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ECC4F6B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:30:54 -0400 (EDT)
Message-ID: <4DB88AF0.1050501@freescale.com>
Date: Wed, 27 Apr 2011 16:30:24 -0500
From: Timur Tabi <timur@freescale.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] make new alloc_pages_exact()
References: <20110414200139.ABD98551@kernel> <20110414200140.CDE09A20@kernel>
In-Reply-To: <20110414200140.CDE09A20@kernel>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, David Rientjes <rientjes@google.com>

Dave Hansen wrote:
> 
> What I really wanted in the end was a highmem-capable
> alloc_pages_exact(), so here it is.  This function can be used to
> allocate unmapped (like highmem) non-power-of-two-sized areas of
> memory.  This is in constast to get_free_pages_exact() which can only
> allocate from lowmem.

Is there an easy way to verify that alloc_pages_exact(5MB) really does allocate
only 5MB and not 8MB?  Is there some kind of function that returns the amount of
unallocated memory, so I can do a diff?

-- 
Timur Tabi
Linux kernel developer at Freescale

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
