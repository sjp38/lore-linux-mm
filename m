Message-ID: <45074EF2.3080407@garzik.org>
Date: Tue, 12 Sep 2006 20:21:06 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [PATCH 11/20] nbd: request_fn fixup
References: <20060912143049.278065000@chello.nl> <20060912144904.197253000@chello.nl> <20060912224710.GB23515@kernel.dk>
In-Reply-To: <20060912224710.GB23515@kernel.dk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, David Miller <davem@davemloft.net>, Rik van Riel <riel@redhat.com>, Daniel Phillips <phillips@google.com>, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

Jens Axboe wrote:
> Generally the block device rule is that once you are invoked due to an
> unplug (or whatever) event, it is the responsibility of the block device
> to run the queue until it's done. So if you bail out of queue handling
> for whatever reason (might be resource starvation in hard- or software),
> you must make sure to reenter queue handling since the device will not
> get replugged while it has requests pending. Unless you run into some
> software resource shortage, running of the queue is done
> deterministically when you know resources are available (ie an io
> completes). The device plugging itself is only ever done when you
> encounter a shortage outside of your control (memory shortage, for
> instance) _and_ you don't already have pending work where you can invoke
> queueing from again.

Or he could employ the blk_{start,stop}_queue() functions, if that model 
is easier for the driver (and brain).

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
