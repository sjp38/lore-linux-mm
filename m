Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA19700
	for <linux-mm@kvack.org>; Fri, 19 Jun 1998 14:39:01 -0400
Date: Fri, 19 Jun 1998 18:59:56 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: update re: fork() failures [in 2.1.103]
In-Reply-To: <19980619110148.53909@adore.lightlink.com>
Message-ID: <Pine.LNX.3.96.980619185625.6318F-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Paul Kimoto <kimoto@lightlink.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Jun 1998, Paul Kimoto wrote:

> On Fri, Jun 19, 1998 at 09:33:54AM +0200, Rik van Riel wrote:
> > I wonder what kind of software / networking app you are using,
> > and what memory usage those programs have...
> 
> It's a mixed libc5/libc6 system.  
> Here is a snapshot of the Top 20 in RSS:
> 
> %CPU %MEM  SIZE   RSS
>  1.3 18.9 13552  5876 Xwrapper        XFree 3.3.2.2
>  1.0 18.4 10612  5716 netscape        3.01

> 95.7  1.6  9364   520 mprime          15.4.2 (internet Mersenne prime search)

Shouldn't be much of a problem... But 'eh, does the
Mersenne program regularly do memory I/O?
It could be that it loads large chunks of memory and
frees small portions from the middle of it. The Linux
MM system could have a problem with that...

Of course we should be able to handle such stuff, but
with the current buddy allocator things might just get
a little bit tricky :(

The reason I picked this process, is that it's RSS is
only one 18th of it's total size, which is somewhat
weird for a 'normal' Unix process.

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
