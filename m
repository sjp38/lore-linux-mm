Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA18555
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 13:10:50 -0500
Message-Id: <m100Vbm-0007U2C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Wed, 13 Jan 1999 19:05:37 +0000 (GMT)
In-Reply-To: <199901131748.RAA06406@dax.scot.redhat.com> from "Stephen C. Tweedie" at Jan 13, 99 05:48:13 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: andrea@e-mind.com, Zlatko.Calusic@CARNet.hr, torvalds@transmeta.com, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, alan@lxorguk.ukuu.org.uk, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >> Could somebody spare a minute to explain why is that so, and what
> >> needs to be done to make SHM swapping asynchronous?
> 
> > Maybe because nobody care about shm? I think shm can wait for 2.3 to be
> > improved.
> 
> "Nobody"?  Oracle uses large shared memory regions for starters.

All the big databases use large shared memory objects. 

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
