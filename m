Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA10214
	for <linux-mm@kvack.org>; Sat, 23 Jan 1999 19:22:01 -0500
Date: Sat, 23 Jan 1999 16:19:13 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m104CMO-0007U1C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.95.990123161758.12138B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 23 Jan 1999, Alan Cox wrote:
> 
> Thats a bug in our current vm structures, like the others - inability to
> throw out page tables, inability to find memory easily, inability to move
> blocks to allocate large areas in a target space, inability to handle
> large user spaces etc.

What? None of those are bugs, they are features.

Complexity is not a goal to be reached. Complexity is something to be
avoided at all cost. If you don't believe me, look at NT.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
