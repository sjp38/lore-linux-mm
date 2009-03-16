Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6B26B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 07:46:02 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:45:55 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 00/35] Cleanup and optimise the page allocator V3
Message-ID: <20090316114555.GB30802@wotan.suse.de>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 09:45:55AM +0000, Mel Gorman wrote:
> Here is V3 of an attempt to cleanup and optimise the page allocator and should
> be ready for general testing. The page allocator is now faster (16%
> reduced time overall for kernbench on one machine) and it has a smaller cache
> footprint (16.5% less L1 cache misses and 19.5% less L2 cache misses for
> kernbench on one machine). The text footprint has unfortunately increased,
> largely due to the introduction of a form of lazy buddy merging mechanism
> that avoids cache misses by postponing buddy merging until a high-order
> allocation needs it.

BTW. I would feel better about this if it gets merged in stages, with
functional changes split out, and also code optimisations and omore
obvious performace improvements split out and preferably merged first.

At a very quick glance, the first 25 or so patches should go in first,
and that gives a much better base to compare subsequent functional
changes with. Patch 18 for example is really significant, and should
almost be 2.6.29/-stable material IMO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
