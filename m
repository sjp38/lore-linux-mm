Received: from post.mail.nl.demon.net (post-10.mail.nl.demon.net [194.159.73.20])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA04780
	for <linux-mm@kvack.org>; Wed, 5 May 1999 06:58:17 -0400
Received: from [212.238.108.69] (helo=mirkwood.dummy.home)
	by post.mail.nl.demon.net with esmtp (Exim 2.02 #1)
	id 10ezN3-0004C4-00
	for linux-mm@kvack.org; Wed, 5 May 1999 10:57:46 +0000
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.9.0/8.8.3) with ESMTP id MAA02077 for <linux-mm@kvack.org>; Wed, 5 May 1999 12:52:29 +0200
Message-ID: <19990504080917.A3700@uni-koblenz.de>
Date: Tue, 4 May 1999 08:09:17 +0200
From: Ralf Baechle <ralf@uni-koblenz.de>
Subject: Re: Memory problems
References: <Pine.LNX.4.04.9905021624570.18784-100000@ps.cus.umist.ac.uk> <Pine.LNX.4.03.9905031237130.219-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.03.9905031237130.219-100000@mirkwood.dummy.home>; from Rik van Riel on Mon, May 03, 1999 at 12:40:11PM +0200
ReSent-To: Linux MM <linux-mm@kvack.org>
ReSent-Message-ID: <Pine.LNX.4.03.9905051252260.219@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@nl.linux.org>
List-ID: <linux-mm.kvack.org>

On Mon, May 03, 1999 at 12:40:11PM +0200, Rik van Riel wrote:

> > Would it help to do all non-DMA allocations from memory above the 16M
> > mark if possible, and only allocate them lower than that if there was
> > no memory above that mark available?
> 
> Some time ago I wrote a quick and dirty design for a zone
> allocator. I guess now is the time to dust off the design
> (http://www.nl.linux.org/~riel/zone-alloc.html) and think
> up a good allocator for 2.3 and  beyond.

Here is another requirement for a future allocator - it should be ccNUMA
aware, that is it should try to allocate pages as close to the local node
as possible.

That one may be fun ...

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
