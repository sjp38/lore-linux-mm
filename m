Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA22503
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 14:38:14 -0500
Message-Id: <m0zzRYb-0007U2C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Sun, 10 Jan 1999 20:33:57 +0000 (GMT)
In-Reply-To: <Pine.LNX.3.95.990110110857.7668F-100000@penguin.transmeta.com> from "Linus Torvalds" at Jan 10, 99 11:09:31 am
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: alan@lxorguk.ukuu.org.uk, sct@redhat.com, saw@msu.ru, andrea@e-mind.com, steve@netplus.net, ebiederm+eric@ccr.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, Zlatko.Calusic@CARNet.hr, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Sun, 10 Jan 1999, Alan Cox wrote:
> > 
> > Suspect makes me kind of nervous. Especially so close to 2.2 and given the
> > normal results of making a bad file system error.
> 
> Umm.. The other choice is to leave in an old deadlock condition - that is
> now well documented and thus wellknown?

Or to defer the I/O to the unlock

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
