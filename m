Date: Fri, 2 Nov 2001 06:52:55 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Zlatko's I/O slowdown status
Message-ID: <20011102065255.B3903@athlon.random>
References: <Pine.LNX.4.33.0110261018270.1001-100000@penguin.transmeta.com> <87k7xfk6zd.fsf@atlas.iskon.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k7xfk6zd.fsf@atlas.iskon.hr>; from zlatko.calusic@iskon.hr on Sun, Oct 28, 2001 at 06:30:14PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Linus Torvalds <torvalds@transmeta.com>, Jens Axboe <axboe@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hello Zlatko,

I'm not sure how the email thread ended but I noticed different
unplugging of the I/O queues in mainline (mainline was a little more
overkill than -ac) and also wrong bdflush histeresis (pre-wakekup of
bdflush to avoid blocking if the write flood could be sustained by the
bandwith of the HD was missing for example).

So you may want to give a spin to pre6aa1 and see if it makes any
difference, if it makes any difference I'll know what your problem is
(see the buffer.c part of the vm-10 patch in pre6aa1 for more details).

thanks,

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
