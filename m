Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA09352
	for <linux-mm@kvack.org>; Mon, 4 Jan 1999 17:54:09 -0500
Date: Mon, 4 Jan 1999 23:29:16 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm improvement , [Re: 2.2.0 Bug summary]]
In-Reply-To: <Pine.LNX.3.95.990104125147.32215U-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990104232257.270C-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jan 1999, Linus Torvalds wrote:

> GPF_ATOMIC things are what the machine is doing. Imagine a machine that
> acts as a router - it might not even be running any normal user processes

Argg, I didn't thought at that, now I understood the point... But I am
pretty sure we can continue to do async swapout also from the process
path. I think it works fine because now swapout is only a bank credit. It
works faster obviously because the process doesn't need to block and so
requesting many swapout at one time will drammatically improve swapout
I/O performances... 

I am going to re-insert the poor kswapd now ;)

Thanks.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
