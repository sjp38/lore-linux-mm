Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EA8776B00A7
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 17:02:23 -0500 (EST)
Date: Tue, 22 Nov 2011 17:02:18 -0500
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: block: initialize request_queue's numa node during allocation
Message-ID: <20111122220218.GA17543@redhat.com>
References: <4ECB5C80.8080609@redhat.com>
 <alpine.DEB.2.00.1111220140470.4306@chino.kir.corp.google.com>
 <20111122152739.GA5663@redhat.com>
 <20111122211954.GA17120@redhat.com>
 <alpine.DEB.2.00.1111221342320.2621@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111221342320.2621@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jens Axboe <axboe@kernel.dk>, Vivek Goyal <vgoyal@redhat.com>, Dave Young <dyoung@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

On Tue, Nov 22 2011 at  4:45pm -0500,
David Rientjes <rientjes@google.com> wrote:

> On Tue, 22 Nov 2011, Mike Snitzer wrote:
> 
> > From: Mike Snitzer <snitzer@redhat.com>
> > Subject: block: initialize request_queue's numa node during allocation
> > 
> > Set request_queue's node in blk_alloc_queue_node() rather than
> > blk_init_allocated_queue_node().  This avoids blk_throtl_init() using
> > q->node before it is initialized.
> > 
> > Rename blk_init_allocated_queue_node() to blk_init_allocated_queue().
> > 
> > Signed-off-by: Mike Snitzer <snitzer@redhat.com>
> 
> When I debug an issue and suggest a patch to fix it in addition to 
> suggesting the possible cleanup for blk_init_allocated_queue_node(), I 
> don't expect that you'll just take it and claim it as your own, sheesh.

Sorry I pissed you off.  But I'm not that hard up for credit.  I was
just looking to make sure proper _code_ changes occurred ;)  I didn't
take enough time to fully appreciate the long road you've travelled on
this.

Jens, I'll defer to David to post a proper patch header.  David please
claim the patch and its contents as your own in v2.  But feel free to
add my Signed-off-by.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
