Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA02274
	for <linux-mm@kvack.org>; Tue, 16 Jun 1998 16:52:32 -0400
Date: Tue, 16 Jun 1998 21:04:38 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: TODO list, v0.01
In-Reply-To: <23752.199806161511@canna.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980616210146.4901A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Stephen Tweedie <sct@dcs.ed.ac.uk>
Cc: "Dr. Werner Fink" <werner@suse.de>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jun 1998, Stephen Tweedie wrote:
> In article <19980615185647.50925@boole.suse.de>, "Dr. Werner Fink"
> <werner@suse.de> writes:
> 
> > ??? == We should get a better recover time/behaviour of the mm for small
> >        systems under high load.  Currently small systems with 2.1.10X
> >        (RAM < 32MB, sometimes < 64MB) do loose in comparision to 2.0.33/34.
> 
> It's the number one problem we need to fix for 2.2.  Fortunately a lot
> of people are aware of the problem and we spent a lot of time talking
> about it at expo and Usenix.  I think we've got a good handle on how
> to start tackling the obvious problems, but there will still be a lot of
> tuning required before we can release a 2.2 kernel and call it stable.

We should probably start with Werner's patch for linux-2.1.102
(if it hasn't been integrated yet).

> I'll write up an outline of what I think we need to start doing once
> I'm back from Usenix.

I have the outlines for a nice and simple zone allocator.
We can push this in for 2.3, it's probably too late for
2.2 :(
However, if we can prove that it works correctly, we might
be able to sneak it in behind Linus' back :-)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
