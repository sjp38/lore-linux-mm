Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA17084
	for <linux-mm@kvack.org>; Sun, 20 Dec 1998 09:19:05 -0500
Date: Sun, 20 Dec 1998 06:18:23 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <199812192201.WAA04889@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.981220060902.643A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Andrea Arcangeli <andrea@e-mind.com>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>


There's a new pre-patch on ftp.kernel.org.

This has Stephens page-in read-ahead code, and I clearly separated the
cases where kswapd tries to throw something out vs a normal user - I
suspect Stephen can agree with the new setup. 

I expect that it needs to be tested in different configurations to find
the optimal values for various tunables, but hopefully this is it when it
comes to basic code.

It also has everything Alan has sent me so far integrated, along with
various other peoples patches. 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
