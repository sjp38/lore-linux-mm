Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA32575
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 18:36:54 -0500
Date: Thu, 7 Jan 1999 21:35:43 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.95.990107100923.4270L-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990107212924.1278A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 1999, Linus Torvalds wrote:

> 
> 
> On Thu, 7 Jan 1999, Andrea Arcangeli wrote:
> > 
> > This first patch allow swap_out to have a more fine grined weight. Should
> > help at least in low memory envinronments.
> 
> The basic reason I didn't want to do this was that I thought it was wrong
> to try to base _any_ decision on any virtual memory sizes. The reason is
> simply that I think RSS isn't a very interesting thing to look at.

But now I am not looking at RSS, I am looking only at total_vm. The point
of the patch is only to be _balanced_ between passes even if in the system
there are some processes with a total_vm of 1Giga and some processes that
has a total_vm of 1kbyte. In normal conditions the patch _should_ make no
differences... This in my theory at least ;)

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
