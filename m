Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA28044
	for <linux-mm@kvack.org>; Wed, 25 Mar 1998 08:39:37 -0500
Date: Wed, 25 Mar 1998 10:08:00 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: Lazy page reclamation on SMP machines: memory barriers
In-Reply-To: <199803242254.WAA03274@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980325100623.371C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-smp@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, 24 Mar 1998, Stephen C. Tweedie wrote:

> I'm in London until the weekend, but I hope to have the lazy page
> stealing in a fit state to release shortly after getting back thanks to
> this.

Then that would be the end of memory fragmentation. Since
marking something as stealable has no real performance penalty,
we could just mark so much memory stealable that we've got
3 128k area's stealable...

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
