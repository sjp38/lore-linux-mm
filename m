Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D67166B004D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 11:37:23 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 537B982C879
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 11:42:13 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 3UG0IrArSBwZ for <linux-mm@kvack.org>;
	Thu, 26 Feb 2009 11:42:13 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DFB6182C87A
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 11:42:12 -0500 (EST)
Date: Thu, 26 Feb 2009 11:28:03 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
In-Reply-To: <1235647139.16552.34.camel@penberg-laptop>
Message-ID: <alpine.DEB.1.10.0902261127230.17756@qirst.com>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>  <1235639427.11390.11.camel@minggr>  <20090226110336.GC32756@csn.ul.ie> <1235647139.16552.34.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Lin Ming <ming.m.lin@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Feb 2009, Pekka Enberg wrote:

> > > UDP-U-4k	-2%		0%		-2%
> >
> > Pekka, for this test was SLUB or the page allocator handling the 4K
> > allocations?
>
> The page allocator. The pass-through revert is not in 2.6.29-rc6 and I
> won't be sending it until 2.6.30 opens up.

The page allocator will handle allocs >4k. 4k itself is already buffered
since we saw tbench regressions if we passed 4k through.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
