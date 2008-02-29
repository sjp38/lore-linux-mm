Date: Thu, 28 Feb 2008 23:01:40 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 5/6] Filter based on a nodemask as well as a gfp_mask
Message-Id: <20080228230140.321581a4.pj@sgi.com>
In-Reply-To: <20071109143406.23540.41284.sendpatchset@skynet.skynet.ie>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
	<20071109143406.23540.41284.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, nacc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Mel wrote:
> A positive benefit of
> this is that allocations using MPOL_BIND now use the local-node-ordered
> zonelist instead of a custom node-id-ordered zonelist.

Could you update the now obsolete documentation (perhaps just delete
the no longer correct remark):

Documentation/vm/numa_memory_policy.txt:

        MPOL_BIND:  This mode specifies that memory must come from the
        set of nodes specified by the policy.

            The memory policy APIs do not specify an order in which the nodes
            will be searched.  However, unlike "local allocation", the Bind
            policy does not consider the distance between the nodes.  Rather,
            allocations will fallback to the nodes specified by the policy in
            order of numeric node id.  Like everything in Linux, this is subject
            to change.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
