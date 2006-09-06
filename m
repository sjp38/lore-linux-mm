Date: Wed, 6 Sep 2006 19:45:01 +0200
From: Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 11/21] nbd: limit blk_queue
Message-ID: <20060906174500.GK14565@kernel.dk>
References: <20060906131630.793619000@chello.nl>> <20060906133954.845224000@chello.nl> <20060906151716.GG16721@harddisk-recovery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060906151716.GG16721@harddisk-recovery.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erik Mouw <erik@harddisk-recovery.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 06 2006, Erik Mouw wrote:
> On Wed, Sep 06, 2006 at 03:16:41PM +0200, Peter Zijlstra wrote:
> > -		disk->queue = blk_init_queue(do_nbd_request, &nbd_lock);
> > +		disk->queue = blk_init_queue_node_elv(do_nbd_request,
> > +				&nbd_lock, -1, "noop");
> 
> So what happens if the noop scheduler isn't compiled into the kernel?

You can't de-select noop, so that cannot happen. But the point is valid
for other choices of io schedulers, which is another reason why this
_elv api addition is a bad idea.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
