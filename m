Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA03135
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 13:17:37 -0500
Date: Thu, 26 Mar 1998 15:18:26 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: 2.1.91pre2 death by swapping.
In-Reply-To: <199803261300.OAA25495@boole.suse.de>
Message-ID: <Pine.LNX.3.91.980326151717.566B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: myrdraal@jackalz.dyn.ml.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Mar 1998, Dr. Werner Fink wrote:

> I've found the following piece of code in the 2.1.91pre2:
> 
> +			/* Refuse to swap out all buffer pages */
> +			if ((buffermem >> PAGE_SHIFT) * 100 > (buffer_mem.min_percent * num_physpages))
> +				goto next;
> 
> IMHO the `>' should be a `<', shouldn't it?

Yes, it should.

> .... and the better place fur such a statement is IMHO
> linux/mm/vmscan.c:do_try_to_free_page() which would avoid the shrink_mmap()
> and its do-while-loop.

shrink_mmap() also shrinks page-cache pages, so it needs
to be called. (unless someone changed the pagecache
semantics too :)

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
