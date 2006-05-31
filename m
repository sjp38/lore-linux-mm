Date: Wed, 31 May 2006 11:26:35 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [rfc][patch] remove racy sync_page?
In-Reply-To: <20060531181312.GA29535@suse.de>
Message-ID: <Pine.LNX.4.64.0605311121390.24646@g5.osdl.org>
References: <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org>
 <447BD31E.7000503@yahoo.com.au> <447BD63D.2080900@yahoo.com.au>
 <Pine.LNX.4.64.0605301041200.5623@g5.osdl.org> <447CE43A.6030700@yahoo.com.au>
 <Pine.LNX.4.64.0605301739030.24646@g5.osdl.org> <447D9A41.8040601@yahoo.com.au>
 <Pine.LNX.4.64.0605310740530.24646@g5.osdl.org> <Pine.LNX.4.64.0605310755210.24646@g5.osdl.org>
 <20060531181312.GA29535@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com
List-ID: <linux-mm.kvack.org>


On Wed, 31 May 2006, Jens Axboe wrote:
> 
> Anyway, the point I wanted to make is that this was never driven by
> scheduler activity. So there!

Heh. I confused tq_disk and tq_scheduler, methinks.

And yes, "run_task_queue(&tq_disk)" was in lock_page(), not the scheduler.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
