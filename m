Received: from post.mail.nl.demon.net (post-10.mail.nl.demon.net [194.159.73.20])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA05352
	for <linux-mm@kvack.org>; Tue, 25 May 1999 16:20:04 -0400
Date: Tue, 25 May 1999 22:16:34 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: Q: PAGE_CACHE_SIZE?
In-Reply-To: <E10mK50-0001eC-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.03.9905252213400.25857-100000@mirkwood.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andi Kleen <ak@muc.de>, ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 1999, Alan Cox wrote:

> > > Who's idea was it start the work to make the granularity of the page
> > > cache larger?
> > 
> > I guess the main motivation comes from the ARM port, where some versions
> > have PAGE_SIZE=32k.
> 
> For large amounts of memory on fast boxes you want a higher page
> size. Some vendors even pick page size based on memory size at
> boot up.

This sounds suspiciously like the 'larger-blocks-for-larger-FSes'
tactic other systems have been using to hide the bad scalability
of their algorithms.

A larger page size is no compensation for the lack of a decent
read-{ahead,back,anywhere} I/O clustering algorithm in the OS.
I believe we should take the more appropriate path and build
a proper 'smart' algorithm. Once we're optimizing for I/O
minimization, CPU is relatively cheap anyway...

Rik -- Open Source: you deserve to be in control of your data.
+-------------------------------------------------------------------+
| Le Reseau netwerksystemen BV:               http://www.reseau.nl/ |
| Linux Memory Management site:   http://www.linux.eu.org/Linux-MM/ |
| Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
