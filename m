Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA00730
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 13:53:17 -0500
Date: Mon, 25 Jan 1999 10:49:44 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901251843.SAA08417@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990125104642.21082H-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Jan 1999, Stephen C. Tweedie wrote:
> 
> Correct: I haven't been testing any of the networking stuff myself so it
> has been a non-issue for any of my workloads here.  Obviously any check
> for this case would have to be outside the GFP_WAIT conditional, but it
> does make sense to set low_on_memory there anyway.

In fact, I wonder if we shouldn't just get rid of the GFP_WAIT conditional
in __get_free_pages(), and make all that unconditional, so that we track
low memory situations correctly even for atomic network traffic -
something that obviously is a GoodThing(tm) to do. Then we could just make
sure that try_to_free_pages() returns immediately for anything that
doesn't have GFP_WAIT set, and have all the kswapd logic there.

That would even get rid of a test in the common path.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
