Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA20920
	for <linux-mm@kvack.org>; Wed, 6 Jan 1999 09:48:56 -0500
Date: Wed, 6 Jan 1999 15:48:20 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.96.990105162541.3527A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990106153725.714A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Jan 1999, Andrea Arcangeli wrote:

> I fixed some thing in arca-vm-7. This new is arca-vm-8.

I've put out arca-vm-9.

It seems that it's a lose marking as not referenced all freed pages in
__free_pages(). Probably because shrink_mmap() doesn't like to decrease
the `count' on just freed pages. So now I mark all freed pages as
referenced.

In the last patches (arca-vm[78] I forgot to include the filemap.c diff)
that seems to improve performances here (allowing the swap cache to be
shrunk without care about pgcache_under_min()).

arca-vm-9 return to a linear behavior in cacluating the swapout weight.

You can donwload arca-vm-9 from here:

ftp://e-mind.com/pub/linux/kernel-patches/2.2.0-pre4-arca-VM-9

Let me know if you'll try it. Thanks!

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
