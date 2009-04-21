Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 14E706B004F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 02:38:11 -0400 (EDT)
Date: Tue, 21 Apr 2009 15:33:37 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 03/25] Do not check NUMA node ID when the caller knows the node is valid
Message-ID: <20090421063337.GB15167@linux-sh.org>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-4-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1240266011-11140-4-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 20, 2009 at 11:19:49PM +0100, Mel Gorman wrote:
> Callers of alloc_pages_node() can optionally specify -1 as a node to mean
> "allocate from the current node". However, a number of the callers in fast
> paths know for a fact their node is valid. To avoid a comparison and branch,
> this patch adds alloc_pages_exact_node() that only checks the nid with
> VM_BUG_ON(). Callers that know their node is valid are then converted.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

For the SLOB NUMA bits:

Acked-by: Paul Mundt <lethal@linux-sh.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
