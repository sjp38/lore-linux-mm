Received: from the-village.bc.nu (lightning.swansea.uk.linux.org [194.168.151.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA03077
	for <linux-mm@kvack.org>; Thu, 27 May 1999 17:17:02 -0400
Subject: Re: Q: PAGE_CACHE_SIZE?
Date: Thu, 27 May 1999 23:06:48 +0100 (BST)
In-Reply-To: <Pine.LNX.4.03.9905252213400.25857-100000@mirkwood.nl.linux.org> from "Rik van Riel" at May 25, 99 10:16:34 pm
Content-Type: text
Message-Id: <E10n8Ic-0003h9-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@nl.linux.org>
Cc: alan@lxorguk.ukuu.org.uk, ak@muc.de, ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> A larger page size is no compensation for the lack of a decent
> read-{ahead,back,anywhere} I/O clustering algorithm in the OS.

It isnt compensating for that. If you have 4Gig of memory and a high performance
I/O controller the constant cost per page for VM management begins to dominate
the equation. Its also a win for other CPU related reasons (reduced tlb
misses and the like), and with 4Gig of RAM the argument is a larger page
size isnt a problem.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
