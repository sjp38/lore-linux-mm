Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA30823
	for <linux-mm@kvack.org>; Fri, 26 Jun 1998 01:34:02 -0400
Date: Fri, 26 Jun 1998 06:34:41 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: glibc and kernel update
In-Reply-To: <m1g1gt4h7r.fsf@flinx.npwt.net>
Message-ID: <Pine.LNX.3.96.980626063318.2529B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 25 Jun 1998, Eric W. Biederman wrote:
> RR> I still haven't resolved the problems between glibc, the
> RR> 2.1 kernel series and pppd :(
> 
> RR> Now I got a new idea: Since most of the kernel interfaces
> RR> go through glibc, does this mean that I have to get the
> RR> glibc source and recompile the whole thing in order to get
> RR> working ppp with a 2.1 kernel?
> 
> Just what problem are you having?

Pppd dies with "This kernel doesn't support PPP", while it
most certainly _does_. I traced it back to a socket operation
which isn't exported properly through glibc...

> I just got 2.3.5 to compile with glibc, but I haven't had a chance to
> test it yet..

It compiles perfectly. It just doesn't run ;(

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
