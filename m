Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA22761
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 15:11:12 -0500
Date: Sun, 10 Jan 1999 12:07:56 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m0zzRYb-0007U2C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.95.990110115354.7668H-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: sct@redhat.com, saw@msu.ru, andrea@e-mind.com, steve@netplus.net, ebiederm+eric@ccr.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, Zlatko.Calusic@CARNet.hr, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Sun, 10 Jan 1999, Alan Cox wrote:
> 
> Or to defer the I/O to the unlock

Hmm.. I don't generally like this idea because it is so easily fraught
with various nasty usage issues - just looking at the file semaphore would
probably make it fairly easy for somebody who knows how we work to come up
with some programs that may not deadlock but would create some really
pathological memory management behaviour. 

I'll think about it, though - together with some kswapd help we might well
be able to guarantee that nobody will be able to cause problems by keeping
a file busy.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
