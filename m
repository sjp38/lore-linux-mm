Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA00385
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 13:30:23 -0500
Date: Mon, 25 Jan 1999 10:27:30 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901251625.QAA04452@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990125102428.21082D-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Jan 1999, Stephen C. Tweedie wrote:
> 
> Regarding the former, is there any chance you'd consider adding a kswapd
> wakeup when low_memory gets set in get_free_pages()?  Being able to
> respond to a burst in network traffic without locking up is not exactly
> a minor issue.

I did that, only to revert it later, because I didn't think it would make
any difference - processes that get to that point will try to free up
memory on their own anyway. 

Note that it wouldn't ever trigger for GFP_ATOMIC allocations, so I
suspect you haven't actually _tried_ it? For a machine that gets burst of
network traffic with nothing else going on, adding it should essentially
amount to a no-op.

I'll look at your other patch.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
