Subject: Re: xmm2 - monitor Linux MM active/inactive lists graphically
Date: Sun, 28 Oct 2001 19:29:27 +0000 (GMT)
In-Reply-To: <Pine.LNX.4.33.0110281014300.7438-100000@penguin.transmeta.com> from "Linus Torvalds" at Oct 28, 2001 10:46:19 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15xvcd-0000FM-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Zlatko Calusic <zlatko.calusic@iskon.hr>, Jens Axboe <axboe@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Yes. My question is more: does the dpt366 thing limit the queueing some
> way?

Nope. The HPT366 is a bog standard DMA IDE controller. At least unless Andre
can point out something I've forgotten any behaviour seen on it should be
the same as seen on any other IDE controller with DMA support.

In practical terms that should mean you can obsere the same HPT366 problem
he does on whatever random IDE controller is on your desktop box

> But notice how that actually doesn't have anything to do with memory size,
> and makes your "scale by max memory" thing illogical.

When you are dealing with the VM limit which the limiter was originally
added for then it makes a lot of sense. When you want to use it solely for
other purposes then it doesnt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
