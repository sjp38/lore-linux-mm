Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA00446
	for <linux-mm@kvack.org>; Wed, 22 Jul 1998 17:31:03 -0400
Date: Wed, 22 Jul 1998 20:01:51 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <199807221036.LAA00829@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980722195943.13554A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, Zlatko.Calusic@CARNet.hr, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Jul 1998, Stephen C. Tweedie wrote:

> successfully with 8k NFS.  However, the zoned allocation can use memory
> less efficiently: the odd free pages in the paged zone cannot be used by
> non-paged users and vice versa, so overall performance may suffer.
> Right now I'm cleaning the code up for a release against 2.1.110 so
> that we can start testing.

Hmm, I'm curious as to what categories your allocator
divides memory users in. Is it just plain swappable
vs. non-swappable or is it fragmentation-causing vs.
fragmentation sensitive or something entirely different?

Btw, I'm working on version 2 of my zone allocator design
right now. Maybe we want the complex but complete version
for 2.3...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
