Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id EF8E06B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 19:20:07 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so1878820wgh.3
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 16:20:07 -0700 (PDT)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id eo10si8075828wib.91.2014.07.23.16.20.06
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 16:20:06 -0700 (PDT)
Date: Wed, 23 Jul 2014 18:20:38 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [patch] mm, thp: do not allow thp faults to avoid cpuset
 restrictions
Message-ID: <20140723232038.GV8578@sgi.com>
References: <20140723220538.GT8578@sgi.com>
 <alpine.DEB.2.02.1407231516570.23495@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1407231545520.1389@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407231545520.1389@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, lliubbo@gmail.com, Johannes Weiner <hannes@cmpxchg.org>, srivatsa.bhat@linux.vnet.ibm.com, Dave Hansen <dave.hansen@linux.intel.com>, dfults@sgi.com, hedi@sgi.com

On Wed, Jul 23, 2014 at 03:50:09PM -0700, David Rientjes wrote:
> The page allocator relies on __GFP_WAIT to determine if ALLOC_CPUSET 
> should be set in allocflags.  ALLOC_CPUSET controls if a page allocation 
> should be restricted only to the set of allowed cpuset mems.
> 
> Transparent hugepages clears __GFP_WAIT when defrag is disabled to prevent 
> the fault path from using memory compaction or direct reclaim.  Thus, it 
> is unfairly able to allocate outside of its cpuset mems restriction as a 
> side-effect.
> 
> This patch ensures that ALLOC_CPUSET is only cleared when the gfp mask is 
> truly GFP_ATOMIC by verifying it is also not a thp allocation.

Tested.  Works as expected.

Tested-by: Alex Thorlton <athorlton@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
