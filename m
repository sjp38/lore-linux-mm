Date: Fri, 2 Nov 2001 21:57:29 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Zlatko's I/O slowdown status
Message-ID: <20011102215729.K1274@athlon.random>
References: <Pine.LNX.4.33.0110261018270.1001-100000@penguin.transmeta.com> <87k7xfk6zd.fsf@atlas.iskon.hr> <20011102065255.B3903@athlon.random> <87g07xdj6x.fsf@atlas.iskon.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87g07xdj6x.fsf@atlas.iskon.hr>; from zlatko.calusic@iskon.hr on Fri, Nov 02, 2001 at 09:14:14PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Linus Torvalds <torvalds@transmeta.com>, Jens Axboe <axboe@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 02, 2001 at 09:14:14PM +0100, Zlatko Calusic wrote:
> It was write caching. Somehow disk was running with write cache turned

Ah, I was going to ask you to try with:

	/sbin/hdparm -d1 -u1 -W1 -c1 /dev/hda

(my settings, of course not safe for journaling fs, safe to use it only
with ext2 and I -W0 back during /etc/init.d/halt) but I assumed you were
using the same hdparm settings in -ac and mainline. Never mind, good
that it's solved now :).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
