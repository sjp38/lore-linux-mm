Received: from the-village.bc.nu (lightning.swansea.uk.linux.org [194.168.151.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA02725
	for <linux-mm@kvack.org>; Tue, 25 May 1999 11:39:45 -0400
Subject: Re: Q: PAGE_CACHE_SIZE?
Date: Tue, 25 May 1999 17:29:23 +0100 (BST)
In-Reply-To: <19990518170401.A3966@fred.muc.de> from "Andi Kleen" at May 18, 99 05:04:01 pm
Content-Type: text
Message-Id: <E10mK50-0001eC-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@muc.de>
Cc: ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Who's idea was it start the work to make the granularity of the page
> > cache larger?
> 
> I guess the main motivation comes from the ARM port, where some versions
> have PAGE_SIZE=32k.

For large amounts of memory on fast boxes you want a higher page size. Some
vendors even pick page size based on memory size at boot up. 

Alan


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
