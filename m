Date: Mon, 25 Sep 2000 16:11:34 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925161134.S26339@suse.de>
References: <20000925145856.A13011@athlon.random> <Pine.LNX.4.21.0009251504220.6224-100000@elte.hu> <20000925154952.O26339@suse.de> <20000925162009.K22882@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925162009.K22882@athlon.random>; from andrea@suse.de on Mon, Sep 25, 2000 at 04:20:09PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25 2000, Andrea Arcangeli wrote:
> > And a new elevator was introduced some months ago to solve this.
> 
> And now that I done some benchmark it seems the major optimization consists in
> the implementation of the new _ordering_ algorithm in test2, not really from
> the removal of the more finegrined latency control (said that I'm not going to
> reintroduce the previous latency control, the current one doesn't provide
> great latency but it's ok).

Yes, I found this the greatest improvement too.

> As soon I patch my tree with Peter's perfect CSCAN ordering (that only changes
> the ordering algorithm), tiotest performance drops significantly in the
> 2-thread-reading case. elvtune settings doesn't matter, that's only a matter
> of the ordering.

Interesting. I haven't done any serious benching with the CSCAN introduction
in elevator_linus, I'll try that too.

-- 
* Jens Axboe <axboe@suse.de>
* SuSE Labs
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
