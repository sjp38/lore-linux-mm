Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA17257
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 10:00:28 -0500
Date: Wed, 13 Jan 1999 15:59:49 +0100 (CET)
From: Rik van Riel <riel@humbolt.geo.uu.nl>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990113144203.284C-100000@laser.bogus>
Message-ID: <Pine.LNX.4.03.9901131557590.295-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 1999, Andrea Arcangeli wrote:
> On Tue, 12 Jan 1999, Rik van Riel wrote:
> 
> > IIRC this facility was in the original swapin readahead
> > implementation. That only leaves the question who removed
> > it and why :))
> 
> There's another thing I completly disagree and that I just removed here. 
> It's the alignment of the offset field. I see no one point in going back
> instead of only doing real read_ahead_. 
> 
> Maybe I am missing something?

Yes, you are:

- aligned reads make sure you don't do smallish readaheads of
  only 1 block (because you've already got the rest)
- there are programs that move through the data backwards or
  tilewise
- in allocating swap space it just doesn't make sense to read
  into the next swap 'region'

Rik -- If a Microsoft product fails, who do you sue?
+-------------------------------------------------------------------+
| Linux memory management tour guide.             riel@nl.linux.org |
| Scouting Vries cubscout leader.     http://www.nl.linux.org/~riel |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
