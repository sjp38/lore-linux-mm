Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA10134
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 14:16:08 -0500
Date: Thu, 28 Jan 1999 11:11:49 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <m105x2f-0007U2C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.95.990128110737.6130B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: sct@redhat.com, andrea@e-mind.com, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, davem@dm.COBALTMICRO.COM, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 28 Jan 1999, Alan Cox wrote:
> 
> (c) you can check if the thing has disappeared after using it and clear
> the buffer if so.

Yes, but the problem is that when there _is_ stale data (unlikely), you
can actually do the wrong thing before.

Incrementing the page counter should fix all problems, but it's such a
subtle fix (even though it's essentially just a few one-liners) that I'm
not going to do it for 2.2.1, which I want to get out later today. 

Alan, the only patch I don't have that looks likely for 2.2.1 is the
IDE-SCSI thing. Did you have that somewhere?

Right now my 2.2.1 patches are:
 - the stupid off-by-one bug found by Ingo
 - __down_interruptible on alpha
 - move "esstype" to outside a #ifdef MODULE
 - NFSD rename/rmdir fixes
 - revert to old array.c
 - change comment about __PAGE_OFFSET
 - missing "vma = NULL" case for avl find_vma()

Holler now or forever hold your peace, because I'd like to get the thing
out in a few hours. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
