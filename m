Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA11741
	for <linux-mm@kvack.org>; Tue, 26 May 1998 17:49:06 -0400
Date: Tue, 26 May 1998 23:46:35 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: patch for 2.1.102 swap code
In-Reply-To: <199805262138.WAA02811@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980526234356.11319A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Bill Hawes <whawes@star.net>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 May 1998, Stephen C. Tweedie wrote:

> That's why read_swap_cache_async repeats the initial entry lookup after
> calling __get_free_page().  Unfortunately, I hadn't realised that
> swap_duplicate() had the error check against swap_map[entry]==0.  Moving
> the swap_duplicate up to before the call to __get_free_page should avoid
> that case.

Hmm, could read_swap_cache_async() be used to implement swap
readahead?

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.phys.uu.nl/~riel/          | <H.H.vanRiel@phys.uu.nl> |
+-------------------------------------------+--------------------------+
