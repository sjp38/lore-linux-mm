Date: Wed, 4 Mar 1998 12:54:12 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: [uPATCH] small kswapd improvement ???
In-Reply-To: <Pine.LNX.3.95.980303201156.14224A-100000@as200.spellcast.com>
Message-ID: <Pine.LNX.3.91.980304124951.20479B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Mar 1998, Benjamin C.R. LaHaise wrote:

> AHhhh!!!  That could explain the odd behaviour of my 386 (5 megs of RAM,
> masquerading/ppp and sick shell scripts) - it never quite made any sense
> that after the first time it swapped, forevermore until forced to clean
> out memory it would continuously touch the disk (the bdflush parameters
> we set to sync every 15 minutes, so only swapping could explain it).

My disk is a _lot_ more quiet than it used to be... This
patch didn't have the you-can-push-linux-further effect
I had hoped for, but it makes Linux a lot quieter under
the same load.

Actually, I was planning on a complete revamp of the
scan-by-VMA algorithm in mm/vmscan.c, beginning with
the removal of AGE_CLUSTER_FRACT, but maybe it works
now :-)

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
