Date: Fri, 18 May 2001 20:58:43 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Linux 2.4.4-ac10
Message-ID: <20010518205843.T806@nightmaster.csn.tu-chemnitz.de>
References: <20010518201924.M754@nightmaster.csn.tu-chemnitz.de> <Pine.LNX.4.33.0105181521400.5251-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0105181521400.5251-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Fri, May 18, 2001 at 03:23:03PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Mike Galbraith <mikeg@wen-online.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2001 at 03:23:03PM -0300, Rik van Riel wrote:
> On Fri, 18 May 2001, Ingo Oeser wrote:
> 
> > Rik: Would you take patches for such a tradeoff sysctl?
> 
> "such a tradeoff" ?
> 
> While this sounds reasonable, I have to point out that
> up to now nobody has described exactly WHAT tradeoff
> they'd like to make tunable and why...

Amount of pages reclaimed from swapout_mm() versus amount of
pages reclaimed from caches.

A value that says: "use XX% of my main memory for RSS of
processes, even if I run heavy disk loadf now" would be nice.

For general purpose machines, where I run several services but
also play games, this would allow both to survive.

The external services would go slower. Who cares, if some CVS
updates or NFS services go slower, if I can play my favorite game
at full speed? ;-)

> I'm not against making things tunable, but I would like
> to at least see the proponents of tunable things explain
> WHAT they want tunable and exactly WHY.

Ideally: Every value that the kernel decides by heuristics,
   because heuristics can fail to get even close to an optimal
   result. 

But this is too much. Some tunables from refill_inactive would be
nice. Also the patch for honouring the soft rss limit is good (is
it in?).

Regards

Ingo Oeser
-- 
To the systems programmer,
users and applications serve only to provide a test load.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
