Date: Mon, 30 Oct 2006 15:52:11 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/3]: leak tracking for kmalloc node
Message-ID: <20061030145211.GA9238@lst.de>
References: <20061030141454.GB7164@lst.de> <84144f020610300632i799214a6p255e1690a93a95d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020610300632i799214a6p255e1690a93a95d4@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 30, 2006 at 04:32:57PM +0200, Pekka Enberg wrote:
> On 10/30/06, Christoph Hellwig <hch@lst.de> wrote:
> >If we want to use the node-aware kmalloc in __alloc_skb we need
> >the tracker is responsible for leak tracking magic for it.  This
> >patch implements it.  The code is far too ugly for my taste, but it's
> >doing exactly what the regular kmalloc is doing and thus follows it's
> >style.
> 
> Yeah, the allocation paths are ugly. If only someone with NUMA machine
> could give this a shot so we can get it merged:
> 
> http://marc.theaimsgroup.com/?l=linux-kernel&m=115952740803511&w=2
> 
> Should clean up NUMA kmalloc tracking too.

I'll give this a try on a small numa machine (CELL with 2 nodes).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
