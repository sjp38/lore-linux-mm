Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA30830
	for <linux-mm@kvack.org>; Fri, 26 Jun 1998 01:34:04 -0400
Date: Fri, 26 Jun 1998 06:32:50 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: glibc and kernel update
In-Reply-To: <199806251634.RAA07815@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980626063111.2529A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jun 1998, Stephen C. Tweedie wrote:
> On Thu, 25 Jun 1998 15:58:12 +0200 (CEST), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > I still haven't resolved the problems between glibc, the
> > 2.1 kernel series and pppd :(
> 
> What problems?

The glibc I have is compiled with a 2.0 kernel. I can
recompile pppd-2.3.5 as much as I like, but it refuses
to work with 2.1 kernels...

It says something like: "This kernel doesn't support ppp",
while that exact same kernel works perfectly with libc5
and the same pppd version :(

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
