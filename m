Date: Tue, 3 Mar 1998 20:17:01 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: [uPATCH] small kswapd improvement ???
In-Reply-To: <Pine.LNX.3.91.980304005820.5443F-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980303201156.14224A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

...trim...
> > Ouch --- I wonder how much this is hurting 2.0.33.  I think I'll have
> > to try that, and perhaps look at this for 2.0.34/LMP... 
> 
> It doesn't hurt _that_ much... Otherwise we wouldn't
> have left it in the swapper code for three years :-)

AHhhh!!!  That could explain the odd behaviour of my 386 (5 megs of RAM,
masquerading/ppp and sick shell scripts) - it never quite made any sense
that after the first time it swapped, forevermore until forced to clean
out memory it would continuously touch the disk (the bdflush parameters
we set to sync every 15 minutes, so only swapping could explain it).

		-ben
