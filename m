Date: Tue, 9 Oct 2007 11:47:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
In-Reply-To: <20071009162526.GC26472@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0710091146360.32162@schroedinger.engr.sgi.com>
References: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie>
 <20070928142526.16783.97067.sendpatchset@skynet.skynet.ie>
 <20071009011143.GC14670@us.ibm.com> <20071009154052.GC12632@skynet.ie>
 <20071009162526.GC26472@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 9 Oct 2007, Nishanth Aravamudan wrote:

> > > And nodemask_thisnode() always gives us a nodemask with only the node
> > > the current process is running on set, I think?
> > > 
> > 
> > Yes, I interpreted THISNODE to mean "this node I am running on".
> > Callers seemed to expect this but the memoryless needs it to be "this
> > node I am running on unless I specify a node in which case I mean that
> > node.".
> 
> I think that is only true (THISNODE = local node) if the callpath is not
> via alloc_pages_node(). If the callpath is via alloc_pages_node(), then
> it depends on whether the nid parameter is -1 (in which case it is also
> local node) or anything (in which case it is the nid specified). Ah,
> reading further along, that's exactly what your changelog indicates too
> :)

Right. THISNODE means the node we are on or the node that we indicated we 
want to allocate from. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
