Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA22034
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 14:03:43 -0500
Date: Sun, 10 Jan 1999 20:03:41 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m0zzQnp-0007U2C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.96.990110195557.1193B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linus Torvalds <torvalds@transmeta.com>, sct@redhat.com, saw@msu.ru, steve@netplus.net, ebiederm+eric@ccr.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, Zlatko.Calusic@CARNet.hr, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Jan 1999, Alan Cox wrote:

> Suspect makes me kind of nervous. Especially so close to 2.2 and given the
> normal results of making a bad file system error.

Another way to fix the thing could be to left only to kswapd the work to
sync shared-mmapped page out to disk when needed. We could wakeup kswapd
from the inside of filemap_swapout... It's dirty but should work fine
without the need of reentrant semaphores. BTW, before my
always-async-swapout idea kswapd was hiding the bug pretty well ;). 

Personally I like far more the clean solution but...

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
