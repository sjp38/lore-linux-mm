Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA23634
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 16:40:01 -0500
Date: Sun, 10 Jan 1999 21:39:27 GMT
Message-Id: <199901102139.VAA01366@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990110195557.1193B-100000@laser.bogus>
References: <m0zzQnp-0007U2C@the-village.bc.nu>
	<Pine.LNX.3.96.990110195557.1193B-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>, sct@redhat.com, saw@msu.ru, steve@netplus.net, ebiederm+eric@ccr.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, Zlatko.Calusic@CARNet.hr, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 10 Jan 1999 20:03:41 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> Another way to fix the thing could be to left only to kswapd the work to
> sync shared-mmapped page out to disk when needed. We could wakeup kswapd
> from the inside of filemap_swapout... It's dirty but should work fine
> without the need of reentrant semaphores. 

Yep.  I had this working for swap a long time ago via a separate kswiod
thread for swap IO, but it didn't make a lot of difference at the time
(we weren't swapping very intelligently in those days, though).  It's
something I have thought of resurrecting, mainly because I'm nervous
that if kswapd spends too much time swapping asynchronously then we can
be left starved of real free pages on the free lists for interrupts. 

--Stephen

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
