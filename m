Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA28438
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 17:10:13 -0400
Date: Thu, 25 Jun 1998 22:08:39 +0100
Message-Id: <199806252108.WAA16230@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Memory management. (fwd)
In-Reply-To: <Pine.LNX.3.96.980625175920.31988G-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.96.980625175920.31988G-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 25 Jun 1998 18:00:15 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> From: Stefane Fermigier <fermigie@math.jussieu.fr>
> To: H.H.vanRiel@phys.uu.nl
> Subject: Memory management.

> He said that under most circumstances, Linux was able to get the best
> results, but that when huge amounts of data were to be transfered from and
> then to disk during the computations, performances were dropping badly.
> This would appear when the size of the files that are manipulated 
> is _half_ of the RAM of the systems, when one would think that RAM 
> just (approximately) _equal_ to the size of the files would be enough.
> According to Remy Card, this might be a question of ``double buffering'',
> that is, the data would go to _two_ different RAM buffers instead of just
> one.

That's right --- it's the old problem of buffering writes through the
buffer cache and reads through the page cache.  Do you want me to reply
to this to say we know about it?

--Stephen
