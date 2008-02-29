Subject: Re: [PATCH 5/6] Filter based on a nodemask as well as a gfp_mask
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080228230140.321581a4.pj@sgi.com>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
	 <20071109143406.23540.41284.sendpatchset@skynet.skynet.ie>
	 <20080228230140.321581a4.pj@sgi.com>
Content-Type: text/plain
Date: Fri, 29 Feb 2008 09:49:24 -0500
Message-Id: <1204296564.5311.10.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, nacc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 2008-02-28 at 23:01 -0600, Paul Jackson wrote:
> Mel wrote:
> > A positive benefit of
> > this is that allocations using MPOL_BIND now use the local-node-ordered
> > zonelist instead of a custom node-id-ordered zonelist.
> 
> Could you update the now obsolete documentation (perhaps just delete
> the no longer correct remark):
> 
> Documentation/vm/numa_memory_policy.txt:
> 
>         MPOL_BIND:  This mode specifies that memory must come from the
>         set of nodes specified by the policy.
> 
>             The memory policy APIs do not specify an order in which the nodes
>             will be searched.  However, unlike "local allocation", the Bind
>             policy does not consider the distance between the nodes.  Rather,
>             allocations will fallback to the nodes specified by the policy in
>             order of numeric node id.  Like everything in Linux, this is subject
>             to change.
> 

Yes, will do.  

Thanks, Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
