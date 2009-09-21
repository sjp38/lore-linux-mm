Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 45C3D6B0096
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 14:07:37 -0400 (EDT)
Date: Mon, 21 Sep 2009 19:07:39 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
Message-ID: <20090921180739.GT12726@csn.ul.ie>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <20090921174656.GS12726@csn.ul.ie> <alpine.DEB.1.10.0909211349530.3106@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909211349530.3106@V090114053VZO-1>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 21, 2009 at 01:54:12PM -0400, Christoph Lameter wrote:
> Lets just keep SLQB back until the basic issues with memoryless nodes are
> resolved.

It's not even super-clear that the memoryless nodes issues are entirely
related to SLQB. Sachin for example says that there was a stall issue
with memoryless nodes that could be triggered without SLQB. Sachin, is
that still accurate?

If so, it's possible that SLQB somehow exasperates the problem in some
unknown fashion.

> There does not seem to be an easy way to deal with this. Some
> thought needs to go into how memoryless node handling relates to per cpu
> lists and locking. List handling issues need to be addressed before SLQB.
> can work reliably. The same issues can surface on x86 platforms with weird
> NUMA memory setups.
> 

Can you spot if there is something fundamentally wrong with patch 2? I.e. what
is wrong with treating the closest node as local instead of only the
closest node?

> Or just allow SLQB for !NUMA configurations and merge it now.
> 

Forcing SLQB !NUMA will not rattle out any existing list issues
unfortunately :(.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
