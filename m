Date: Wed, 4 Mar 1998 15:00:24 +0100
Message-Id: <199803041400.PAA06227@boole.fs100.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <Pine.LNX.3.91.980304005820.5443F-100000@mirkwood.dummy.home>
	(message from Rik van Riel on Wed, 4 Mar 1998 00:59:33 +0100 (MET))
Subject: Re: [uPATCH] small kswapd improvement ???
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: sct@dcs.ed.ac.uk, torvalds@transmeta.com, blah@kvack.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> > > vmscan.c. Back then a simple bug was encountered and 'fixed'
> > > by always starting the memory scan at adress 0, which gives
> > > a highly unfair and inefficient aging process.
> > 
> > Ouch --- I wonder how much this is hurting 2.0.33.  I think I'll have
> > to try that, and perhaps look at this for 2.0.34/LMP... 
> 
> It doesn't hurt _that_ much... Otherwise we wouldn't
> have left it in the swapper code for three years :-)

Maybe that's the reason why the bigger initial age for swapped in pages gives
an improvement in 2.0.33 ... it's a ``better protection'' for often needed
pages.


          Werner
