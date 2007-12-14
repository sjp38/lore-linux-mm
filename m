Date: Thu, 13 Dec 2007 21:00:57 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] fix page_alloc for larger I/O segments
Message-ID: <20071214040056.GS26334@parisc-linux.org>
References: <20071213200958.GK10104@kernel.dk> <20071213140207.111f94e2.akpm@linux-foundation.org> <1197584106.3154.55.camel@localhost.localdomain> <20071213142935.47ff19d9.akpm@linux-foundation.org> <4761B32A.3070201@rtr.ca> <4761BCB4.1060601@rtr.ca> <4761C8E4.2010900@rtr.ca> <4761CE88.9070406@rtr.ca> <4761D0E9.4010701@rtr.ca> <20071213170308.d4ce5889.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071213170308.d4ce5889.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Lord <liml@rtr.ca>, James.Bottomley@HansenPartnership.com, jens.axboe@oracle.com, lkml@rtr.ca, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Thu, Dec 13, 2007 at 05:03:08PM -0800, Andrew Morton wrote:
> +		/*
> +		 * Find a page of the appropriate migrate type.  Doing a
> +		 * reverse-order search here helps us to hand out pages in
> +		 * ascending physical-address order.
> +		 */
> +		list_for_each_entry_reverse(page, &pcp->list, lru)

It's not obvious why ascending physical order is a good thing.  How
about:

+		/*
+		 * Find a page of the appropriate migrate type.  Doing a
+		 * reverse-order search here helps us to hand out pages in
+		 * ascending physical-address order, which improves our
+		 * chances of coalescing scatter-gather pages.
+		 */

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
