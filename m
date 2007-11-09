Date: Fri, 9 Nov 2007 08:19:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
In-Reply-To: <20071109161455.GB32088@skynet.ie>
Message-ID: <Pine.LNX.4.64.0711090818100.14292@schroedinger.engr.sgi.com>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
 <20071109143426.23540.44459.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0711090741120.13932@schroedinger.engr.sgi.com>
 <20071109161455.GB32088@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, nacc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Nov 2007, Mel Gorman wrote:

> > Argh.... GFP_THISNODE must use the nid passed to alloc_pages_node and 
> > *not* the local numa node id. Only if the node specified to alloc_pages 
> > nodes is -1 will this work.
> > 
> 
> alloc_pages_node() calls __alloc_pages_nodemask() though where in this
> function if I'm reading it right is called without a node id. Given no
> other details on the nid, the current one seemed a logical choice.

If the function only called when the first zone == numa_node_id then 
the use of numa_node_id here is okay.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
