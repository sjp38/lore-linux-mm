Date: Fri, 4 May 2007 18:04:01 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC 2/3] SLUB: Implement targeted reclaim and partial list
 defragmentation
Message-Id: <20070504180401.5d5fc6dd.randy.dunlap@oracle.com>
In-Reply-To: <Pine.LNX.4.64.0705041603150.27790@schroedinger.engr.sgi.com>
References: <20070504221555.642061626@sgi.com>
	<20070504221708.596112123@sgi.com>
	<Pine.LNX.4.64.0705041603150.27790@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007 16:03:43 -0700 (PDT) Christoph Lameter wrote:

> Fixes suggested by Andrew
> 
> ---
>  include/linux/slab.h |   12 ++++++++++++
>  mm/slub.c            |   32 +++++++++++++++++++++-----------
>  2 files changed, 33 insertions(+), 11 deletions(-)
> 
>  	/* Perform the KICK callbacks to remove the objects */
>  	for(p = addr; p < addr + s->objects * s->size; p += s->size)

missed a space after "for".

> -		if (!test_bit((p - addr) / s->size, map))
> +		if (test_bit((p - addr) / s->size, map))
>  			s->slab_ops->kick_object(p);

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
