Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA30816
	for <linux-mm@kvack.org>; Fri, 26 Jun 1998 01:34:00 -0400
Date: Fri, 26 Jun 1998 06:48:52 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Memory management. (fwd)
In-Reply-To: <199806252108.WAA16230@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980626064711.2529E-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jun 1998, Stephen C. Tweedie wrote:

> [...]
> 
> That's right --- it's the old problem of buffering writes through the
> buffer cache and reads through the page cache.  Do you want me to reply
> to this to say we know about it?

I already did, and also said that we're working on it.
I even said that there probably would be patches in some
6 months, which is a bit pessimistic, considering the
fact that Eric wrote he has most of the code ready...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
