Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0A66B008A
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 06:24:07 -0400 (EDT)
Date: Tue, 22 Sep 2009 11:24:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
Message-ID: <20090922102415.GF12254@csn.ul.ie>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <20090921174656.GS12726@csn.ul.ie> <alpine.DEB.1.10.0909211349530.3106@V090114053VZO-1> <20090921180739.GT12726@csn.ul.ie> <alpine.DEB.1.10.0909211412050.3106@V090114053VZO-1> <20090922100540.GD12254@csn.ul.ie> <1253614875.30406.12.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1253614875.30406.12.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 22, 2009 at 01:21:15PM +0300, Pekka Enberg wrote:
> Hi Mel,
> 
> On Tue, 2009-09-22 at 11:05 +0100, Mel Gorman wrote:
> > I'm going to punt the decision on this one to Pekka or Nick. My feeling
> > is leave it enabled for NUMA so it can be identified if it gets fixed
> > for some other reason - e.g. the stalls are due to a per-cpu problem as
> > stated by Sachin and SLQB happens to exasperate the problem.
> 
> Can I have a tested patch that uses MAX_NUMNODES to allocate the
> structs, please? We can convert SLQB over to per-cpu allocator if the
> memoryless node issue is resolved.
> 

Patch set in the process of testing. Should have something in a few
hours.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
