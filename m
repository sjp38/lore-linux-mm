Date: Wed, 19 Sep 2007 11:03:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 6/14] Reclaim Scalability: "No Reclaim LRU Infrastructure"
In-Reply-To: <20070919111125.GD14817@skynet.ie>
Message-ID: <Pine.LNX.4.64.0709191102060.11882@schroedinger.engr.sgi.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
 <20070914205438.6536.49500.sendpatchset@localhost>
 <Pine.LNX.4.64.0709141537180.14937@schroedinger.engr.sgi.com>
 <1190042245.5460.81.camel@localhost> <Pine.LNX.4.64.0709171137360.27057@schroedinger.engr.sgi.com>
 <20070918095443.GA2035@skynet.ie> <Pine.LNX.4.64.0709181242240.3714@schroedinger.engr.sgi.com>
 <20070919111125.GD14817@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, Mel Gorman wrote:

> > RDMA is probably only temporarily pinning these while I/O is in progress?. 
> > Our applications (XPMEM) 
> > may pins them for good.
> >  
> 
> I'm not that familiar with XPMEM. What is it doing that can pin memory
> permanently?

It exports an process address space to another Linux instance over a 
network or coherent memory.

> > No. Nor in our XPMEM situation. We could move them at the point when they 
> > are pinned to another section?
> > 
> 
> XPMEM could do that all right. Allocate a non-movable page, copy and
> pin.

I think we need a general mechanism that also covers RDMA and other uses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
