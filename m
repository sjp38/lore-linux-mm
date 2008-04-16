Date: Wed, 16 Apr 2008 16:02:33 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/4] Make defencive checks around PFN values registered
	for memory usage
Message-ID: <20080416140233.GC24383@elte.hu>
References: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie> <20080416135218.1346.41125.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080416135218.1346.41125.sendpatchset@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Mel Gorman <mel@csn.ul.ie> wrote:

> +	if (*start_pfn > max_sparsemem_pfn) {
> +		mminit_debug_printk(MMINIT_VERIFY, "pfnvalidation",
> +			"Start of range %lu -> %lu exceeds SPARSEMEM max %lu\n",
> +			*start_pfn, *end_pfn, max_sparsemem_pfn);

small request: please emit a WARN_ON_ONCE() as well, so that 
kerneloops.org (and automated test setups) picks it up.

> +		mminit_debug_printk(MMINIT_VERIFY, "pfnvalidation",
> +			"End of range %lu -> %lu exceeds SPARSEMEM max %lu\n",
> +			*start_pfn, *end_pfn, max_sparsemem_pfn);

ditto - all errors should be fixed up and we should try to continue as 
far as possible, but emitting a WARN_ON_ONCE() will be very useful in 
making sure people notice the warning.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
