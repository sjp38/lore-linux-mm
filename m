Received: from dm.cobaltmicro.com (davem@dm.cobaltmicro.com [209.133.34.35])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA06212
	for <linux-mm@kvack.org>; Wed, 19 Aug 1998 10:23:11 -0400
Date: Wed, 19 Aug 1998 07:20:29 -0700
Message-Id: <199808191420.HAA04726@dm.cobaltmicro.com>
From: "David S. Miller" <davem@dm.cobaltmicro.com>
In-reply-to: <199808182138.OAA00489@penguin.transmeta.com> (message from Linus
	Torvalds on Tue, 18 Aug 1998 14:38:07 -0700)
Subject: Re: Notebooks
References: <19980814115843.43989@orci.com> <m0z88bh-000aNFC@the-village.bc.nu> <199808182138.OAA00489@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: torvalds@transmeta.com
Cc: alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I have this fixed in my tree, it's been fixed in my tree for 3 months,
and if you hadn't stopped me half-way through my last merge to you,
you would have gotten it.  Don't blame slab in this case, that
original loopback MTU value was tuned for the old kmalloc and old skb
allocation routines.

Later,
David S. Miller
davem@dm.cobaltmicro.com
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
