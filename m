Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA12867
	for <linux-mm@kvack.org>; Tue, 17 Nov 1998 18:01:05 -0500
Date: Tue, 17 Nov 1998 21:25:06 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: unexpected paging during large file reads in 2.1.127
In-Reply-To: <199811171206.MAA01194@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981117212245.12547D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, linux-kernel@vger.rutgers.edu, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Nov 1998, Stephen C. Tweedie wrote:
> On Tue, 17 Nov 1998 07:42:12 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > I meant the page aging that occurs in vmscan.c, where we
> > decide on which page to unmap from a program's address
> > space. 
> 
> For the last time, NO IT DOES NOT.  Read the source.  Linus removed it.
> We do not use page->age AT ALL in vmscan.c in current 2.1 kernels.

I just learned that answering questions from memory is
not a good idea when reality changes under your nose :)

I'll try to remember this, really...

> This change improves low memory performance very measurably in all
> tests I have tried so far. 

OK, I agree with these changes and have seen a bit of
improvement on my own (72M) system too.

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
