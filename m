Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA14461
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 22:06:11 -0500
Date: Sat, 19 Dec 1998 19:05:23 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <199812192201.WAA04889@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.981219190346.5560A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Andrea Arcangeli <andrea@e-mind.com>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>



On Sat, 19 Dec 1998, Stephen C. Tweedie wrote:
> 
> That is precisely the compromise I reached in the patch I sent you,
> courtesy of the test above. 

The problem I have with your version is that it's not at all obvious. It's
just another "magic test" rather than being clearly split out. We've had
too many of those already, and we've had too many people just adding more
and more magic tests on top of the old ones. 

I want a _design_, not just something that happens to work. See my point?

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
