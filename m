Date: Fri, 4 May 2007 18:07:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 2/3] SLUB: Implement targeted reclaim and partial list
 defragmentation
In-Reply-To: <20070504180401.5d5fc6dd.randy.dunlap@oracle.com>
Message-ID: <Pine.LNX.4.64.0705041807210.28556@schroedinger.engr.sgi.com>
References: <20070504221555.642061626@sgi.com> <20070504221708.596112123@sgi.com>
 <Pine.LNX.4.64.0705041603150.27790@schroedinger.engr.sgi.com>
 <20070504180401.5d5fc6dd.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Randy Dunlap wrote:

> >  	/* Perform the KICK callbacks to remove the objects */
> >  	for(p = addr; p < addr + s->objects * s->size; p += s->size)
> 
> missed a space after "for".

Thanks but I was more hoping for a higher level of review. Locking????

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
