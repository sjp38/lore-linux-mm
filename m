Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA29470
	for <linux-mm@kvack.org>; Fri, 4 Sep 1998 05:54:09 -0400
Date: Fri, 4 Sep 1998 11:53:55 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [Q] MMU & VM
In-Reply-To: <19980904002057.A5268@ds23-ca-us.dialup>
Message-ID: <Pine.OSF.3.95.980904115231.12046A-100000@ruunat.phys.uu.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Graffiti <ramune@bigfoot.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Sep 1998, Graffiti wrote:

> 	Just how does an MMU work, and why do we need it to implement
> virtual memory instead of handling it all in the kernel?
> 	I've found quite a few texts on how VM works, but never why we
> need an MMU or what an MMU does.
> 
> 	Can anyone recommend a good book on this?

Well, there's Tanenbaum's "Modern Operating Systems".

There's also a nice VM tutorial from CNE/CMU(?), which
is linked to from the Linux-MM homepage, VM Links.

http://www.phys.uu.nl/~riel/mm-patch/

Rik.

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
