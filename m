Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA11844
	for <linux-mm@kvack.org>; Wed, 29 Jul 1998 17:30:53 -0400
Received: from mirkwood.dummy.home (root@anx1p6.phys.uu.nl [131.211.33.95])
	by max.phys.uu.nl (8.8.7/8.8.7/hjm) with ESMTP id XAA09352
	for <linux-mm@kvack.org>; Wed, 29 Jul 1998 23:30:44 +0200 (MET DST)
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.9.0/8.8.3) with SMTP id UAA12180 for <linux-mm@kvack.org>; Wed, 29 Jul 1998 20:00:48 +0200
Date: Wed, 29 Jul 1998 20:00:48 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Page cache ageing: yae or nae?
Message-ID: <Pine.LNX.3.96.980729200036.12136H-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Jul 1998, Stephen C. Tweedie wrote:

> Right, but we don't need page aging to address that.  Currently we don't
> set the page referenced bit on a readahead IO; setting that bit will be
> sufficient to guard the page for at least one full pass of the
> shrink_mmap scan.

Hmm, one full pass of shrink_mmap will probably take quite a
number of calls to that function, since without aging we are
able to find far more freeable pages...

At the moment I'm super-busy with my (vacation) job, but I
might be able to find some time this weekend. Maybe some
folks on linux-mm have spare time?

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
