Date: Wed, 25 Feb 1998 11:41:20 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: PATCH: Swap shared pages (was: How to read-protect a vm_area?)
In-Reply-To: <199802242338.XAA03262@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980225113925.376A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Linus Torvalds <torvalds@transmeta.com>, Itai Nahshon <nahshon@actcom.co.il>, Alan Cox <alan@lxorguk.ukuu.org.uk>, paubert@iram.es, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Feb 1998, Stephen C. Tweedie wrote:

> That is already scheduled as part of phase 4 of this work.  The patch I
> have just posted is phase 2, modifying the swapper for shared pages.
> Phase three is to implement MAP_SHARED | MAP_ANONYMOUS, and part four is
> to do much what you describe, proactively soft-swapping data out

Hmm, is there anything I can do to help with this, or
will that just confuse things ? :-(
If not, I'll be working on buffer/cache memory limits
so one file/process can't clog up all of memory (a'la
badblocks -w), of course with DU like tunability...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
