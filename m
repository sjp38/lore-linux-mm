Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA21880
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 13:50:20 -0500
Message-Id: <m0zzQnp-0007U2C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Sun, 10 Jan 1999 19:45:36 +0000 (GMT)
In-Reply-To: <Pine.LNX.3.95.990110103201.7668D-100000@penguin.transmeta.com> from "Linus Torvalds" at Jan 10, 99 10:35:10 am
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: sct@redhat.com, saw@msu.ru, andrea@e-mind.com, steve@netplus.net, ebiederm+eric@ccr.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, Zlatko.Calusic@CARNet.hr, bmccann@indusriver.com, alan@lxorguk.ukuu.org.uk, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> point where we would otherwise deadlock on the writer semaphore it's much
> better to just allow nested writes. I suspect all filesystems can already
> handle nested writes - they are a lot easier to handle than truly
> concurrent ones.

Suspect makes me kind of nervous. Especially so close to 2.2 and given the
normal results of making a bad file system error.

Alan

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
