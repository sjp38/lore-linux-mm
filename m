Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA04726
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 14:00:29 -0500
Date: Mon, 16 Nov 1998 19:43:41 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: 4M kernel pages
In-Reply-To: <364FE29E.2CF14EEA@varel.bg>
Message-ID: <Pine.LNX.3.96.981116194249.23633A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Petko Manolov <petkan@varel.bg>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Nov 1998, Petko Manolov wrote:

> I red in the intel docs that it is possile to have mixed
> 4K and 4M pages for pentium+ machines. Also we have less
> TLB misses when the kernel is in 4M page. I know Linus 
> don't like the idea of mixing different page sizes but
> if this a improvemet...

Been there, done that. Linux has had this implemented for
ages, in fact it's such a long time ago that I don't
remember when it was :)

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
