Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA11532
	for <linux-mm@kvack.org>; Sat, 4 Jul 1998 02:46:06 -0400
Date: Fri, 3 Jul 1998 22:36:06 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Thread implementations... 
In-Reply-To: <199807032005.VAA02773@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980703223314.2190A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Jul 1998, Stephen C. Tweedie wrote:
> On Fri, 3 Jul 1998 17:21:51 +0200 (CEST), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > But, ehhh, just what _is_ this random swap stats-based prediction
> > algorithm, 
> It's a per-swap-page readahead predictor which observes the access
> patterns for vmas.  
> 
> > and how far from implementation is it?
> It is implemented.  It is not in the main kernels, nor does it take
> advantage of the potential for swap readahead in the 2.1.86+ kernels.

Then where is it? It would be great to test and it
would make an excellent link with description for
the Linux MM homepage...

Besides, I'm currently somewhat memory starved and
I would really like to test and possibly improve
or integrate this piece of code with the main kernel.

I know it's too late for inclusion now, but I'm willing
to keep the patch up-to-date with the kernel up to the
date of inclusion.

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
