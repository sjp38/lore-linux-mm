Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA08773
	for <linux-mm@kvack.org>; Mon, 4 Jan 1999 16:08:40 -0500
Message-Id: <m0zxI6a-0007U1C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm improvement , [Re: 2.2.0 Bug summary]]
Date: Mon, 4 Jan 1999 22:04:08 +0000 (GMT)
In-Reply-To: <Pine.LNX.3.95.990104125147.32215U-100000@penguin.transmeta.com> from "Linus Torvalds" at Jan 4, 99 12:56:27 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: andrea@e-mind.com, steve@netplus.net, bredelin@ucsd.edu, sct@redhat.com, linux-kernel@vger.rutgers.edu, alan@lxorguk.ukuu.org.uk, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Boom. You just killed the machine with your patch, because maybe the
> GPF_ATOMIC things are what the machine is doing. Imagine a machine that
> acts as a router - it might not even be running any normal user processes
> at _all_, but it had damn well better make sure that memory is always
> available some way. "kswapd" did that for us, and Rik's happiness counts
> as nothing in face of basic facts of life like that. Sorry.

Its performance properties are very interesting however. They do seem to suggest
kswapd should be more of a last resort. 

Alan


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
