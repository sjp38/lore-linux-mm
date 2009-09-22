Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0E76B0082
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 06:05:38 -0400 (EDT)
Date: Tue, 22 Sep 2009 11:05:40 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
Message-ID: <20090922100540.GD12254@csn.ul.ie>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <20090921174656.GS12726@csn.ul.ie> <alpine.DEB.1.10.0909211349530.3106@V090114053VZO-1> <20090921180739.GT12726@csn.ul.ie> <alpine.DEB.1.10.0909211412050.3106@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909211412050.3106@V090114053VZO-1>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 21, 2009 at 02:17:40PM -0400, Christoph Lameter wrote:
> On Mon, 21 Sep 2009, Mel Gorman wrote:
> > Can you spot if there is something fundamentally wrong with patch 2? I.e. what
> > is wrong with treating the closest node as local instead of only the
> > closest node?
> 
> Depends on the way locking is done for percpu queues (likely lockless).
> A misidentification of the numa locality of an object may result in locks
> not being taken that should have been taken.
> 

Ok, I'll continue looking from that perspective and see what comes out.
I've spotted a few possible anomolies which I'll stick into a separate
patch.

> > > Or just allow SLQB for !NUMA configurations and merge it now.
> > >
> >
> > Forcing SLQB !NUMA will not rattle out any existing list issues
> > unfortunately :(.
> 
> But it will make SLQB work right in permitted configurations. The NUMA
> issues can then be fixed later upstream.
> 

I'm going to punt the decision on this one to Pekka or Nick. My feeling
is leave it enabled for NUMA so it can be identified if it gets fixed
for some other reason - e.g. the stalls are due to a per-cpu problem as
stated by Sachin and SLQB happens to exasperate the problem.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
