Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA09353
	for <linux-mm@kvack.org>; Mon, 4 Jan 1999 17:54:10 -0500
Date: Mon, 4 Jan 1999 23:51:03 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm improvement , [Re: 2.2.0 Bug summary]]
In-Reply-To: <Pine.LNX.3.95.990104135333.32215W-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990104234647.270F-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, steve@netplus.net, bredelin@ucsd.edu, sct@redhat.com, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jan 1999, Linus Torvalds wrote:

> However, one of the things I found so appealing with the patch was the
> fact that it removed a lot of code, and that wouldn't be true for
> something that just changed kswapd to run less often. Oh, well. 

We can still remove the dynamic prio thing and the
run-one-jiffy-and-schedule thing since we don't need to give
swapout performances via kswapd anymore allowing the process to swapout
async and take credits from the bank some time after...

We can more simply schedule() if need_resched is set inside the kswapd
engine.

I am going to do something like that right now...

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
