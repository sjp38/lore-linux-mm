Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA28862
	for <linux-mm@kvack.org>; Sat, 2 Jan 1999 13:12:56 -0500
Date: Sat, 2 Jan 1999 10:10:31 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Reply-To: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
In-Reply-To: <Pine.LNX.3.96.990102162944.176A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.990102100512.18853G-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Steve Bergman <steve@netplus.net>, Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Sat, 2 Jan 1999, Andrea Arcangeli wrote:
> 
> > The other thing I'd like to hear is how pre3 looks with this patch, which
> > should behave basically like Andrea's latest patch but without the
> > obfuscation he put into his patch..
> 
> I rediffed my latest swapout stuff against your latest tree (I consider
> your latest patch as test1-pre4, right?).

Andrea, I already told you that I refuse to apply patches that include
this many obvious cases of pure obfuscation.

As I already told you in an earlier mail, your state machine only has two
states, not three like the code makes you believe. Gratuitous changes like
that that only show that the writer didn't actually _think_ about the code
is not something I want at any stage, much less now.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
