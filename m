Date: Mon, 25 Sep 2000 16:08:38 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925160838.R26339@suse.de>
References: <20000925155650.F22882@athlon.random> <Pine.LNX.4.21.0009251555420.9122-100000@elte.hu> <20000925161358.J22882@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925161358.J22882@athlon.random>; from andrea@suse.de on Mon, Sep 25, 2000 at 04:13:58PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25 2000, Andrea Arcangeli wrote:
> > i had yesterday - those were simple VM deadlocks. I dont see any deadlocks
> 
> Definitely. They can't explain anything about the VM deadlocks. I was
> _only_ talking about the blkdev hangs that caused you to unplug the
> queue at each reschedule in tux and that Eric reported me for the SG
> driver (and I very much hope that with EXCLUSIVE gone away and the
> wait_on_* fixed those hangs will go away because I don't see anything else
> wrong at this moment).

The sg problem was different. When sg queues a request, it invokes the
request_fn to handle it. But if the queue is currently plugged, the
scsi_request_fn will not do anything.

-- 
* Jens Axboe <axboe@suse.de>
* SuSE Labs
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
