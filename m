Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 298E66B005A
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 13:05:58 -0400 (EDT)
Date: Mon, 16 Mar 2009 18:05:51 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 00/35] Cleanup and optimise the page allocator V3
Message-ID: <20090316170551.GI30802@wotan.suse.de>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <20090316104054.GA23046@wotan.suse.de> <20090316111906.GA6382@csn.ul.ie> <20090316113358.GA30802@wotan.suse.de> <20090316120216.GB6382@csn.ul.ie> <20090316122505.GD30802@wotan.suse.de> <20090316133232.GA24293@csn.ul.ie> <20090316155342.GH30802@wotan.suse.de> <20090316165628.GP24293@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090316165628.GP24293@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 04:56:28PM +0000, Mel Gorman wrote:
> On Mon, Mar 16, 2009 at 04:53:42PM +0100, Nick Piggin wrote:
> > So yes definitely I think there should be a very real impact on
> > higher order coalescing no matter what you do.
> > 
> 
> Because this is not straight-forward at all, I'll put lazy buddy onto
> the back-burner and exhaust all other possibilities before revisiting it
> again.

If it is such a big improvement, I expect *most* people will want
it and we probably should do it. But just that it will not play
nicely with fragmentation and so you'd need to look into it and
devise some way those users can tune it to be nicer.

> > unmovable zone fragmentation is more important point because it
> > eventually can destroy the movable zone.
> > 
> 
> Which is why rmqueue_fallback() also merges up all buddies before making
> any decisions but I accept your points.

Right, that merge of buddies will only be able to look at what is
currently free. Wheras non-lazy buddy can pull out higher orders
before reallocating them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
