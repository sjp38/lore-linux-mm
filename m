Received: from twinlark.arctic.org (twinlark.arctic.org [204.62.130.91])
	by kvack.org (8.8.7/8.8.7) with SMTP id PAA23380
	for <linux-mm@kvack.org>; Tue, 30 Jun 1998 15:35:48 -0400
Date: Tue, 30 Jun 1998 12:35:35 -0700 (PDT)
From: Dean Gaudet <dgaudet-list-linux-kernel@arctic.org>
Subject: Re: Thread implementations...
In-Reply-To: <199806301310.OAA00911@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96dg4.980630122740.23907D-100000@twinlark.arctic.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, Christoph Rohland <hans-christoph.rohland@sap-ag.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 30 Jun 1998, Stephen C. Tweedie wrote:

> Not for very large files: the forget-behind is absolutely critical in
> that case.

I dunno why you're thinking of unmapping pages though... isn't an mmap
cache the best way to amortize the extra cost of mmap()ing?  In that case
you don't want the forget-behind pages to be unmapped.  But you do want
them to be dropped from memory when appropriate.

Another thought re: sendfile.  The network layer could hint to sendfile as
to the speed of the socket it's delivering to.  With that hint and some
suitable queueing theory someone should be able to get a nifty little
algorithm that will "synchronize" sockets as much as possible without
noticeable delays to the user.  By "synchronize" I mean getting them going
from the same, or nearby pages.  That way on larger than memory data sets
the kernel can sacrifice some latency on a few connections in order to
improve the total throughput. 

I won't pretend to have a good heuristic for it ;) 

applications:  multimedia servers -- audio/video streaming.  These boxes
can be limited by disk bandwidth because their data sets are typically
much larger than RAM. 

Dean
