Date: Wed, 4 Mar 1998 00:59:33 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: [uPATCH] small kswapd improvement ???
In-Reply-To: <199803032354.XAA02829@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980304005820.5443F-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Mar 1998, Stephen C. Tweedie wrote:

> > I remember the 1.1 or 1.2 days when Stephen reworked the
> > swap code and I played around with a small piece of
> > vmscan.c. Back then a simple bug was encountered and 'fixed'
> > by always starting the memory scan at adress 0, which gives
> > a highly unfair and inefficient aging process.
> 
> Ouch --- I wonder how much this is hurting 2.0.33.  I think I'll have
> to try that, and perhaps look at this for 2.0.34/LMP... 

It doesn't hurt _that_ much... Otherwise we wouldn't
have left it in the swapper code for three years :-)

It gives somewhat more than a smallish improvement
though...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
