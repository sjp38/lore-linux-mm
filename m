Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA32702
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 18:53:15 -0500
Date: Thu, 7 Jan 1999 15:51:11 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.96.990107212924.1278A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.990107154908.5025Q-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Thu, 7 Jan 1999, Andrea Arcangeli wrote:
> > The basic reason I didn't want to do this was that I thought it was wrong
> > to try to base _any_ decision on any virtual memory sizes. The reason is
> > simply that I think RSS isn't a very interesting thing to look at.
> 
> But now I am not looking at RSS, I am looking only at total_vm. The point
> of the patch is only to be _balanced_ between passes even if in the system
> there are some processes with a total_vm of 1Giga and some processes that
> has a total_vm of 1kbyte. In normal conditions the patch _should_ make no
> differences... This in my theory at least ;)

Ehh, and how do you protect against somebody playing games with your mind
by doing _huge_ mappings of something that takes no real memory? The VM
footprint of a process is not necessarily related to how much physical
memory you use. 

Basically, I think the thing should either be simple or right, and yours
is somewhere in between - neither simple nor strictly correct.

Also, I've been happily deleting code, and it has worked wonderfully. This
patch adds logic and code back.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
