Date: Wed, 16 Apr 2008 16:00:18 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/4] [RFC] Verification and debugging of memory
	initialisation
Message-ID: <20080416140018.GB24383@elte.hu>
References: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* Mel Gorman <mel@csn.ul.ie> wrote:

> Boot initialisation has always been a bit of a mess with a number of 
> ugly points. While significant amounts of the initialisation is 
> architecture-independent, it trusts of the data received from the 
> architecture layer. This was a mistake in retrospect as it has 
> resulted in a number of difficult-to-diagnose bugs.
> 
> This patchset is an RFC to add some validation and tracing to memory 
> initialisation. It also introduces a few basic defencive measures and 
> depending on a boot parameter, will perform additional tests for 
> errors "that should never occur". I think this would have reduced 
> debugging time for some boot-related problems. The last part of the 
> patchset is a similar fix for the patch "[patch] mm: sparsemem 
> memory_present() memory corruption" that corrects a few more areas 
> where similar errors were made.
> 
> I'm not looking to merge this as-is obviously but are there opinions 
> on whether this is a good idea in principal? Should it be done 
> differently or not at all?

very nice stuff!

  Acked-by: Ingo Molnar <mingo@elte.hu>

or rather:

  Very-Strongly-Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
