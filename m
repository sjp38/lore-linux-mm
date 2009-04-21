Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C57656B003D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:46:28 -0400 (EDT)
Date: Tue, 21 Apr 2009 16:47:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/25] Calculate the cold parameter for allocation only
	once
Message-ID: <20090421154703.GC29083@csn.ul.ie>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie> <1237543392-11797-12-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903201109250.3740@qirst.com> <20090421151355.GA29083@csn.ul.ie> <alpine.DEB.1.10.0904211122540.21796@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904211122540.21796@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 11:25:34AM -0400, Christoph Lameter wrote:
> On Tue, 21 Apr 2009, Mel Gorman wrote:
> 
> > On Fri, Mar 20, 2009 at 11:09:40AM -0400, Christoph Lameter wrote:
> > >
> > > Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> > I apologise, I've it added now. While the patch is currently dropped from the
> > set, I'll bring it back later for further discussion when it can be
> > established if it really helps or not.
> 
> Sooo much self-doubt.....

Not as such. the objective was to get a patchset that was
uncontroversial and relatively clear wins. This is not as clear cut as I
don't have data on exactly how much it helps right now. It'll be easier
to revisit in isolation than half-way through this set.

> Could you post the not included patches at the
> end of your patchsets so that others can help improve those?
> 

When I get this set finalised, pass two will start with a posting of
everything that got thrown out during this pass such as this patch, the
high order in PCP stuff, the gfp zone patch etc.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
