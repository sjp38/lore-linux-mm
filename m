Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA09079
	for <linux-mm@kvack.org>; Mon, 4 Jan 1999 16:58:07 -0500
Date: Mon, 4 Jan 1999 13:55:43 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm improvement , [Re: 2.2.0 Bug summary]]
In-Reply-To: <m0zxI6a-0007U1C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.95.990104135333.32215W-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: andrea@e-mind.com, steve@netplus.net, bredelin@ucsd.edu, sct@redhat.com, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Mon, 4 Jan 1999, Alan Cox wrote:
> > Boom. You just killed the machine with your patch, because maybe the
> > GPF_ATOMIC things are what the machine is doing. Imagine a machine that
> > acts as a router - it might not even be running any normal user processes
> > at _all_, but it had damn well better make sure that memory is always
> > available some way. "kswapd" did that for us, and Rik's happiness counts
> > as nothing in face of basic facts of life like that. Sorry.
> 
> Its performance properties are very interesting however. They do seem to suggest
> kswapd should be more of a last resort. 

Agreed, I found that interesting too. The solution may just be to make
kswapd run a lot less often rather than removing it - for the
machine-killing out-of-memory situation it doesn't matter if kswapd runs
just a few times a second or something like that. 

However, one of the things I found so appealing with the patch was the
fact that it removed a lot of code, and that wouldn't be true for
something that just changed kswapd to run less often. Oh, well. 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
