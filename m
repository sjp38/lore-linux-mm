Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA10332
	for <linux-mm@kvack.org>; Tue, 14 Apr 1998 16:02:57 -0400
Date: Tue, 14 Apr 1998 20:02:09 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: new kmod.c - debuggers and testers needed
In-Reply-To: <199804080001.RAA23780@sun4.apsoft.com>
Message-ID: <Pine.LNX.3.91.980414200024.1070J-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Perry Harrington <pedward@sun4.apsoft.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Apr 1998, Perry Harrington wrote:

>                                                           Threads
> are useful in their appropriate context, and kswapd, and kmod would benefit
> from them.

Hmm, maybe it would be useful for kswapd and bdflush to fork()
off threads to do the actual disk I/O, so the main thread won't
be blocked and paused... This could remove some bottlenecks.

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
