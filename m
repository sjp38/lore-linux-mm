Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA22175
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 14:12:13 -0500
Date: Sun, 10 Jan 1999 11:09:31 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m0zzQnp-0007U2C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.95.990110110857.7668F-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: sct@redhat.com, saw@msu.ru, andrea@e-mind.com, steve@netplus.net, ebiederm+eric@ccr.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, Zlatko.Calusic@CARNet.hr, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Sun, 10 Jan 1999, Alan Cox wrote:
> 
> Suspect makes me kind of nervous. Especially so close to 2.2 and given the
> normal results of making a bad file system error.

Umm.. The other choice is to leave in an old deadlock condition - that is
now well documented and thus wellknown?

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
