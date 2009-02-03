Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DCE175F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 06:26:21 -0500 (EST)
Date: Tue, 3 Feb 2009 11:26:19 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] SLQB slab allocator (try 2)
Message-ID: <20090203112618.GI9840@csn.ul.ie>
References: <20090123154653.GA14517@wotan.suse.de> <1232959706.21504.7.camel@penberg-laptop> <20090203101205.GF9840@csn.ul.ie> <200902032136.26022.nickpiggin@yahoo.com.au> <20090203112226.GG9840@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090203112226.GG9840@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 03, 2009 at 11:22:26AM +0000, Mel Gorman wrote:
> > <SNIP>
> > This is very nice, thanks for testing.
> 
> Sure. It's been on my TODO list for long enough :). I should have been
> clear that the ratios are performance improvements based on wall time.

/me slaps self

For SPEC, it's performance improvements based on wall time as measured
by the suite. For sysbench, it's performance improvements based on operations
per second.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
