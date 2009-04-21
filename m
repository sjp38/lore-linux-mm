Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 618BC6B004D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 05:29:52 -0400 (EDT)
Date: Tue, 21 Apr 2009 10:30:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 05/25] Break up the allocator entry point into fast and
	slow paths
Message-ID: <20090421093015.GK12713@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-6-git-send-email-mel@csn.ul.ie> <20090421150235.F12A.A69D9226@jp.fujitsu.com> <1240297984.771.24.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1240297984.771.24.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 10:13:04AM +0300, Pekka Enberg wrote:
> Hi!
> 
> On Tue, 2009-04-21 at 15:35 +0900, KOSAKI Motohiro wrote:
> > > The core of the page allocator is one giant function which allocates memory
> > > on the stack and makes calculations that may not be needed for every
> > > allocation. This patch breaks up the allocator path into fast and slow
> > > paths for clarity. Note the slow paths are still inlined but the entry is
> > > marked unlikely.  If they were not inlined, it actally increases text size
> > > to generate the as there is only one call site.
> > 
> > hmm..
> > 
> > this patch have few behavior change.
> > please separate big cleanup patch and behavior patch.
> > 
> > I hope to make this patch non functional change. I'm not sure about these
> > are your intentional change or not. it cause harder reviewing...
> 
> Agreed, splitting this patch into smaller chunks would make it easier to review.
> 

Chunking this doesn't make it easier to review. As it is, it's possible
to go through the old path once and compare it to the new path. I had
this split out at one time, but it meant comparing old and new paths
multiple times instead of once.

However, there were functional changes in here and they needed to be
taken out.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
