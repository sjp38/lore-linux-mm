Received: from Galois.suse.de (Galois.suse.de [195.125.217.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA11081
	for <linux-mm@kvack.org>; Tue, 9 Dec 1997 11:17:13 -0500
Date: Tue, 9 Dec 1997 17:11:20 +0100
Message-Id: <199712091611.RAA05335@boole.fs100.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <Pine.LNX.3.91.971209154819.584H-100000@mirkwood.dummy.home>
	(message from Rik van Riel on Tue, 9 Dec 1997 15:53:29 +0100 (MET))
Subject: Re: Ideas for memory management hackers.
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> I have integrated mmap aging in kswapd, without the need for
> vhand, in 2.1.71 (experimental). As ppp isn't working in 2.1.71
> I'm back to 2.1.66 now, but I have seen kswapd use over 10% of
> CPU for short times now :(

Q: if ageing is now a separate part the CPU usage of freeing a page
   in kswapd and __get_free_pages should drop, shouldn't it?

> I think I'll send it to Linus (together with Zlatko's
> big-order hack) as a bug-fix (we're on feature-freeze after all:)
> for inclusion in 2.1.72...
> 
> opinions please,

Q2: Is the patch available (ftp/http) for testing/reading?


        Werner
