Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA01961
	for <linux-mm@kvack.org>; Sun, 3 Jan 1999 12:00:13 -0500
Date: Sun, 3 Jan 1999 17:57:23 +0100 (CET)
From: Rik van Riel <riel@humbolt.geo.uu.nl>
Subject: Re: work around 1GB heap size limit
In-Reply-To: <13965.22214.171983.180152@woensel.ics.ele.tue.nl>
Message-ID: <Pine.LNX.4.03.9901031754360.32063-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Raymond Nijssen <rxtn@gte.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2 Jan 1999, Raymond Nijssen wrote:

> I was wondering if there exists a general way to work around the
> maximum heap size limit of 1 GB on Linux.  (at least on the x86
> platforms).

[snip]

> The proposal is really whether it would be possible to make the
> mappable region start at max_stack and to make it grow downward.
> 
> The proposed segmentation looks like:
> 
> 0xc0000000 - 0xffffffff : kernel memory
> min_stack  - 0xc0000000 : user stack                      -- grows downward
> MIN_mmap   - min_stack  : mapped (mmap, shared mem/libs)  -- grows DOWNward
> 'brk'      - MIN_mmap   : free
> `end'      - 'brk'      : heap                            -- grows upward
> 0x00000000 - 'end'      : text, bss, etc.

This seems like a more-than-just-a-little-bit sane idea
to me.  Like Raymond, I'm not completely aware of the
bolts and nuts we might be provoking with this action
though...

Stephen, Ben, what do you think? Did Raymond overlook
something or do we have a winner?

cheers,

Rik -- If a Microsoft product fails, who do you sue?
+-------------------------------------------------------------------+
| Linux memory management tour guide.        riel@humbolt.geo.uu.nl |
| Scouting Vries cubscout leader.    http://humbolt.geo.uu.nl/~riel |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
