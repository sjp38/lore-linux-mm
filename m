Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA08962
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 12:55:32 -0500
Date: Thu, 28 Jan 1999 09:54:07 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <199901281509.PAA02883@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990128095147.32418F-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 28 Jan 1999, Stephen C. Tweedie wrote:

> 
> > Do you want to know why last night I added a spinlock around mmget/mmput
> > without thinking twice?  Simply because mm->count was an atomic_t while it
> > doesn't need to be an atomic_t in first place.
> 
> Agreed.

Incorrect, see my previous email. It may not be strictly necessary right
now due to us probably holding the kernel lock everywhere, but it is
conceptually necessary, and it is _not_ an argument for a spinlock.

The /proc code has to be fixed, but the easy fix is to just revert to the
old one as far as I can see. I shouldn't have accepted the /proc patches
in the first place, and I'm sorry I did.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
