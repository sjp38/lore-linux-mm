Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA09665
	for <linux-mm@kvack.org>; Mon, 4 Jan 1999 18:25:24 -0500
Date: Mon, 4 Jan 1999 22:10:11 +0100 (CET)
From: Rik van Riel <riel@humbolt.geo.uu.nl>
Subject: Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm
 improvement , [Re: 2.2.0 Bug summary]]
In-Reply-To: <Pine.LNX.3.95.990104125147.32215U-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.03.9901042208440.27900-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Steve Bergman <steve@netplus.net>, Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jan 1999, Linus Torvalds wrote:
> On Mon, 4 Jan 1999, Andrea Arcangeli wrote:
> >
> > I have a new revolutionary patch. The main thing is that I killed kswapd
> > just to make Rik happy ;).
> 
> You may have made Rik happy,

Not even that -- I really like the concept of a separate
thread doing the much needed page freeing...

> but you totally missed the reason for kswapd.  And while your
> patch looked interesting (a lot cleaner than the previous ones,
> and I _like_ patches that remove code), the fact that you killed
> kswapd means that it is essentially useless.

Yup -- a definite No-No.
(just to make sure that nobody would have really gotten
the impression that I would be happy with the removal
of kswapd)

cheers,

Rik -- If a Microsoft product fails, who do you sue?
+-------------------------------------------------------------------+
| Linux memory management tour guide.        riel@humbolt.geo.uu.nl |
| Scouting Vries cubscout leader.    http://humbolt.geo.uu.nl/~riel |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
