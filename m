Subject: Re: Getting big areas of memory, in 2.3.x?
Date: Thu, 9 Dec 1999 02:28:13 +0000 (GMT)
In-Reply-To: <384EFFD3.8DDCEF8D@mandrakesoft.com> from "Jeff Garzik" at Dec 8, 99 08:03:15 pm
Content-Type: text
Message-Id: <E11vtJW-0001YP-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> What's the best way to get a large region of DMA'able memory for use
> with framegrabbers and other greedy drivers?

Do you need physically linear memory >

> Per a thread on glx-dev, Andi Kleen mentions that the new 2.3.x MM stuff
> still doesn't allieviate the need for bigphysarea and similar patches.

It helps, however the best answer is to use sane hardware which has scatter
gather - eg the bttv frame grabbers grab 1Mb of memory or more, but they 
grab it as arbitary pages not a linear block.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
