From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2/5] Light Fragmentation Avoidance V20: 002_usemap
Date: Wed, 16 Nov 2005 00:36:53 +0100
References: <20051115164946.21980.2026.sendpatchset@skynet.csn.ul.ie> <20051115164957.21980.8731.sendpatchset@skynet.csn.ul.ie>
In-Reply-To: <20051115164957.21980.8731.sendpatchset@skynet.csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511160036.54461.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, mingo@elte.hu, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Tuesday 15 November 2005 17:49, Mel Gorman wrote:
> This patch adds a "usemap" to the allocator. Each bit in the usemap indicates
> whether a block of 2^(MAX_ORDER-1) pages are being used for kernel or
> easily-reclaimed allocations. This enumerates two types of allocations;

This will increase cache line footprint, which is costly.
Why can't this be done in the page flags?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
