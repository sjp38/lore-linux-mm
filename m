Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA14063
	for <linux-mm@kvack.org>; Thu, 23 Apr 1998 05:01:22 -0400
Date: Thu, 23 Apr 1998 10:28:50 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: H.H.vanRiel@phys.uu.nl
Subject: Re: Fixing private mappings
In-Reply-To: <m1ra2pnn3c.fsf@flinx.npwt.net>
Message-ID: <Pine.LNX.3.91.980423102626.4620C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 23 Apr 1998, Eric W. Biederman wrote:

> A slightly more generic solution would be to introduce a new ``inode''
> that new it was a copy of the old inode but at a different offset.  If
> these new ``inodes'' would then have a linked list of their own, that
> could be followed for update purposes.  
>
> Extra inodes for files could also be extended to allow an offset at
> say 4TB or so into a file so that we can handle any sized file.
> Though obviously you can't cache it all at once, but you could cache
> any piece ;)  

This is a nice idea indeed. Maybe we could even use the
'extra inodes' idea to implement arbitrarily large files
on _any_ architecture...
When the on-disk maximum size is reached, just grab a
slave inode and start on part two.
The same for in-memory inodes, but there the maximum
size may be different.

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.phys.uu.nl/~riel/          | <H.H.vanRiel@phys.uu.nl> |
+-------------------------------------------+--------------------------+
