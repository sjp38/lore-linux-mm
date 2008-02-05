Date: Tue, 5 Feb 2008 14:31:50 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [2.6.24-rc8-mm1][regression?] numactl --interleave=all doesn't works on memoryless node.
Message-ID: <20080205143149.GA4207@csn.ul.ie>
References: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080202090914.GA27723@one.firstfloor.org> <20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1202149243.5028.61.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1202149243.5028.61.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On (04/02/08 13:20), Lee Schermerhorn didst pronounce:
> > > When the kernel behaviour changes and breaks user space then the kernel
> > > is usually wrong. Cc'ed Lee S. who maintains the kernel code now.
> 
> The memoryless nodes patch series changed a lot of things, so just
> reverting this one area [mpol_check_policy()] probably won't restore the
> prior behavior.  A fully populated node mask is not necessarily a proper
> subset of node_online_map().  And contextualize_policy() also requires
> the mask to be a subset of mems_allowed which also defaults to nodes
> with memory.
> 
> I don't know how Mel Gorman's "two zonelist" series, which is still
> awaiting a window into the -mm tree, affects this behavior.  Those
> patches will certainly be affected by whatever we decide here.
> 

I doubt they'd make a difference to this particular problem.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
