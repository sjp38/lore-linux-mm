Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA17944
	for <linux-mm@kvack.org>; Thu, 22 Oct 1998 07:31:32 -0400
Date: Thu, 22 Oct 1998 12:26:07 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: MM with fragmented memory
In-Reply-To: <199810220948.LAA06921@lrcsun15.epfl.ch>
Message-ID: <Pine.LNX.3.96.981022122457.1419C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Werner Almesberger <almesber@lrc.di.epfl.ch>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Oct 1998, Werner Almesberger wrote:

> >>  - allocations from start_mem and end_mem are each limited to a total of
> >>    512kB
> > 
> > Allocations are limited to 128kB already.
> 
> Are you sure this limit also applies to linear allocations, i.e.
>     my_huge_buffer = start_mem;
>     start_mem += 5*1024*1024;

Things like this will have to be done at kernel initialization.
The code is arch-specific and the number of occurances will be
absolutely minimal. Unless, of course, you will want to have
multiple multi-megabyte buffers on your Psion-5 ;)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
