Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA09520
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 12:58:17 -0500
Date: Tue, 12 Jan 1999 09:54:50 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901121606.QAA04800@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990112095401.17705A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 12 Jan 1999, Stephen C. Tweedie wrote:
> 
> On 11 Jan 1999 00:04:11 -0600, ebiederm+eric@ccr.net (Eric W. Biederman)
> said:
> 
> > Oh, and just as a side note we are currently unfairly penalizing
> > threaded programs by doing for_each_task instead of for_each_mm in the
> > swapout code...
> 
> I know, on my TODO list...

Actually, this one is _really_ easy to fix.

The truly trivial fix is to just move "swap_cnt" into the mm structure,
and you're all done. You'd still walk the list with for_each_task(), but
it no longer matters.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
