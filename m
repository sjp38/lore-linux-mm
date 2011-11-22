Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA806B009F
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 16:33:01 -0500 (EST)
Date: Tue, 22 Nov 2011 16:32:57 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH] block: initialize request_queue's numa node during
 allocation
Message-ID: <20111122213257.GF5663@redhat.com>
References: <4ECB5C80.8080609@redhat.com>
 <alpine.DEB.2.00.1111220140470.4306@chino.kir.corp.google.com>
 <20111122152739.GA5663@redhat.com>
 <20111122211954.GA17120@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111122211954.GA17120@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Dave Young <dyoung@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

On Tue, Nov 22, 2011 at 04:19:58PM -0500, Mike Snitzer wrote:

[..]
> > Storing q->node info at queue allocation time makes sense to me. In fact
> > it might make sense to clean it up from blk_init_allocated_queue_node
> > and assume that passed queue has queue->node set at the allocation time.
> >
> > CCing Mike Snitzer who introduced blk_init_allocated_queue_node(). Mike
> > what do you think. I am not sure it makes sense to pass in nodeid, both
> > at queue allocation and queue initialization time. To me, it should make
> > more sense to allocate the queue at one node and that becomes the default
> > node for reset of the initialization.
> 
> Yeah, that makes sense to me too:
> 
> From: Mike Snitzer <snitzer@redhat.com>
> Subject: block: initialize request_queue's numa node during allocation
> 
> Set request_queue's node in blk_alloc_queue_node() rather than
> blk_init_allocated_queue_node().  This avoids blk_throtl_init() using
> q->node before it is initialized.
> 
> Rename blk_init_allocated_queue_node() to blk_init_allocated_queue().
> 
> Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Thanks Mike. Looks good to me.

Acked-by: Vivek Goyal <vgoyal@redhat.com>

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
