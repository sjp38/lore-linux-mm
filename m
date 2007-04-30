Subject: Re: Antifrag patchset comments
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0704301016180.32439@skynet.skynet.ie>
References: <Pine.LNX.4.64.0704271854480.6208@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0704281229040.20054@skynet.skynet.ie>
	 <Pine.LNX.4.64.0704281425550.12304@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0704301016180.32439@skynet.skynet.ie>
Content-Type: text/plain
Date: Mon, 30 Apr 2007 14:35:04 +0200
Message-Id: <1177936504.4843.20.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-04-30 at 10:37 +0100, Mel Gorman wrote:

> >>> 10. Radix tree as reclaimable? radix_tree_node_alloc()
> >>>
> >>> 	Ummm... Its reclaimable in a sense if all the pages are removed
> >>> 	but I'd say not in general.
> >>>
> >>
> >> I considered them to be indirectly reclaimable. Maybe it wasn't the best
> >> choice.
> >
> > Maybe we need to ask Nick about this one.
> 
> Nick, at what point are nodes allocated with radix_tree_node_alloc() 
> freed?
> 
> My current understanding is that some get freed when pages are removed 
> from the page cache but I haven't looked closely enough to be certain.

Indeed, radix tree nodes are freed when the tree loses elements. Both
through freeing nodes that have no elements left, and shrinking the tree
when the top node has only the first entry in use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
