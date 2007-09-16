Date: Sun, 16 Sep 2007 03:34:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/13] Reduce external fragmentation by grouping pages by
 mobility v30
Message-Id: <20070916033426.5097a5b0.akpm@linux-foundation.org>
In-Reply-To: <20070914143355.GD30407@skynet.ie>
References: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
	<20070913180156.ee0cdec4.akpm@linux-foundation.org>
	<20070914143355.GD30407@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Sep 2007 15:33:55 +0100 mel@skynet.ie (Mel Gorman) wrote:

> Go ahead with the patches you already
> have if you prefer. Just make sure not to include
> breakout-page_order-to-internalh-to-avoid-special-knowledge-of-the-buddy-allocator.patch
> as it's only required for page-owner-tracking.

memory-unplug-v7-page-isolation.patch uses page_order() also, so I brought this patch back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
