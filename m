Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA25436
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 11:24:57 -0500
Date: Tue, 1 Dec 1998 16:41:06 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead
In-Reply-To: <199812011513.PAA18172@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981201163806.437C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Dec 1998, Stephen C. Tweedie wrote:
> In article <Pine.LNX.3.96.981127001214.445A-100000@mirkwood.dummy.home>,
> Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> 
> > here is a very first primitive version of as swapin

I am at version 3 now (4 in a few minutes?) but your
message still seems needed...

> > The checks are all needed. The first two checks are there
> > to avoid annoying messages from swap_state.c :)) 
> 
> There's a third check needed, I think, which probably accounts for the
> swap_duplicate errors people have been noting.  You need to skip pages
> which are marked as locked in the swap_lockmap, or the async page read
> may block

OK, I'll add this test and try again.

I also noted something else -- when I free a lot of memory
(80+ MB gimp picture) the system swaps itself to death.
Could that also be because of issues with locked/unlocked
swap_cache pages which in some magical way duplicate themselves
and fill up memory? I have seen 600+ MB of shared memory :(

cheers,

Rik -- now completely used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
