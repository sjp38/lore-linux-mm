Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA27871
	for <linux-mm@kvack.org>; Sat, 2 Jan 1999 09:50:02 -0500
Date: Sat, 2 Jan 1999 15:48:19 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
In-Reply-To: <Pine.LNX.3.95.990101225111.16066K-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990102154225.1302B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Jan 1999, Linus Torvalds wrote:

> The other thing I'd like to hear is how pre3 looks with this patch, which
> should behave basically like Andrea's latest patch but without the
> obfuscation he put into his patch..

I still think the most important part of all my latest VM patches is my
new do_free_user_and_cache(). It allow the VM to scale very better and be
perfectly balanced. 

Why to run `count' times swap_out() without take a look if the cache grows
too much?

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
