Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA06009
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 14:28:51 -0500
Date: Mon, 18 Jan 1999 20:22:57 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] NEW: arca-vm-21, swapout via shrink_mmap using PG_dirty
In-Reply-To: <Pine.LNX.3.96.990118001901.263A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990118200756.9003C-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>, dlux@dlux.sch.bme.hu, "Nicholas J. Leon" <nicholas@binary9.net>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Kalle Andersson <kalle@sslug.dk>
Cc: Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Heinz Mauelshagen <mauelsha@ez-darmstadt.telekom.de>, Max <max@Linuz.sns.it>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jan 1999, Andrea Arcangeli wrote:

> Also you Kelle, could you try my new arca-vm-24 on your 16Mbyte machine? I
> think that you'll be very happy ;).
> 
> Note, arca-vm-24 is tunable:

Ehmmm, ohoh, I did a little mistake in arca-vm-24 that was causing a
lockup under heavy swapping ;) (I was still decrementing counter in the
grow_freeable() while loop...) 

So I diffed a fixed arca-vm-25 that rocks here. It's against pre-8.gz in
testing. This new one should be really safe (and pre8 is also fixing also
the swapout deadlock making the semaphores recursive). Give me comments if
you'll try it. arca-vm-24/25 still seems far better than anything tried
before here. I don't think I could do something better than it for 2.2.

ftp://e-mind.com/pub/linux/kernel-patches/2.2.0-pre8testing-arca-VM-25.gz

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
