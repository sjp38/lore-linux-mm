Date: Mon, 25 Sep 2000 23:28:55 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925232855.A5900@suse.de>
References: <20000925155650.F22882@athlon.random> <Pine.LNX.4.21.0009251555420.9122-100000@elte.hu> <20000925161358.J22882@athlon.random> <20000925160838.R26339@suse.de> <20000925162921.M22882@athlon.random> <20000925161854.T26339@suse.de> <20000925164755.Q22882@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925164755.Q22882@athlon.random>; from andrea@suse.de on Mon, Sep 25, 2000 at 04:47:55PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25 2000, Andrea Arcangeli wrote:
> > The scsi layer currently "manually" does a list_add on the queue itself,
> > which doesn't look too healthy.
> 
> It's grabbing the io_request_lock so it looks healthy for now :)

It's safe alright, but if we want to do the generic_unplug_queue
instead of just hitting the request_fn (which might do anything
anyway), it would be nicer to expose this part of the block layer
(i.e. have a general way of queueing a request to the request_queue).
But I guess just

q->plug_device_fn(q, ...);
list_add(...)
generic_unplug_device(q);

would suffice in scsi_lib for now.

-- 
* Jens Axboe <axboe@suse.de>
* SuSE Labs
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
