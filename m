Date: Mon, 25 Sep 2000 16:33:31 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925163331.N22882@athlon.random>
References: <20000925145856.A13011@athlon.random> <Pine.LNX.4.21.0009251504220.6224-100000@elte.hu> <20000925154952.O26339@suse.de> <20000925162009.K22882@athlon.random> <20000925161134.S26339@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925161134.S26339@suse.de>; from axboe@suse.de on Mon, Sep 25, 2000 at 04:11:34PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 04:11:34PM +0200, Jens Axboe wrote:
> Interesting. I haven't done any serious benching with the CSCAN introduction
> in elevator_linus, I'll try that too.

Only changing that the performance decreased reproducibly from 16 to 14
mbyte/sec in the read test with 2 threads.

So far I'm testing only IDE with LVM striping on two equal fast disks on
separate IDE channels.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
