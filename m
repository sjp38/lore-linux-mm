Received: from ferret.lmh.ox.ac.uk (qmailr@ferret.lmh.ox.ac.uk [163.1.138.204])
	by kvack.org (8.8.7/8.8.7) with SMTP id IAA16869
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 08:58:19 -0500
Date: Wed, 13 Jan 1999 13:58:01 +0000 (GMT)
From: Chris Evans <chris@ferret.lmh.ox.ac.uk>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990113144203.284C-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990113135623.12654A-100000@ferret.lmh.ox.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
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

Yes. Imagine the paging in of big binary case. The page faults will occur
all over the place, not in a nice sequential order. The page-in clusters
stuff _doubled_ performance of paging in certain big static binaries.

Chris

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
