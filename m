Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA08733
	for <linux-mm@kvack.org>; Mon, 4 Jan 1999 16:05:56 -0500
Date: Mon, 4 Jan 1999 12:56:27 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm improvement , [Re: 2.2.0 Bug summary]]
In-Reply-To: <Pine.LNX.3.96.990104183954.1944B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.990104125147.32215U-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Steve Bergman <steve@netplus.net>, Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Mon, 4 Jan 1999, Andrea Arcangeli wrote:
>
> I have a new revolutionary patch. The main thing is that I killed kswapd
> just to make Rik happy ;).

Ehh..

You may have made Rik happy, but you totally missed the reason for kswapd. 
And while your patch looked interesting (a lot cleaner than the previous
ones, and I _like_ patches that remove code), the fact that you killed
kswapd means that it is essentially useless. 

Basically, we _have_ to have kswapd, and I'll tell you why:
 - imagine running low on memory due to GFP_ATOMIC
 - imagine not having any normal processes that do memory alloction.

Boom. You just killed the machine with your patch, because maybe the
GPF_ATOMIC things are what the machine is doing. Imagine a machine that
acts as a router - it might not even be running any normal user processes
at _all_, but it had damn well better make sure that memory is always
available some way. "kswapd" did that for us, and Rik's happiness counts
as nothing in face of basic facts of life like that. Sorry.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
