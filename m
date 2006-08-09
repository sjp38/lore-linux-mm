Date: Tue, 8 Aug 2006 19:00:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
In-Reply-To: <20060809103433.99f14cb7.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0608081857560.31758@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
 <20060809103433.99f14cb7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, pj@sgi.com, jes@sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Aug 2006, KAMEZAWA Hiroyuki wrote:

> Hm, passing a nodemask as argment to alloc_page_???()is too more complicated
> than GFP_THISNODE ? (it will increase # of args but...)

The node is passed via alloc_pages_node() etc already. If one uses 
__GFP_THISNODE with alloc_pages_node() then you will get the page on the 
indicated node regardless of cpusets. Currently cpuset constraints may 
lead to allocation on a different node.

If you use __GFP_THISNODE with an allocator that does not allow the 
specification of a node then you will get memory from the local node 
without regard to memory policies and cpuset constraints. In that usage 
scenario __GFP_THISNODE then behaves as if it would be 
Andy's GFP_LOCAL_NODE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
