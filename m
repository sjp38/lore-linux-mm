Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA12006
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 17:35:46 -0500
Date: Thu, 28 Jan 1999 23:33:03 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <199901281807.SAA03328@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.990128232118.797B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jan 1999, Stephen C. Tweedie wrote:

> Linus, we are in violent agreement: see my previous email. :)  I agree
> with both you and Andrea that the atomic_t is not strictly necessary,
> and agree vigorously that removing it is wrong because it will just make
> the job of fine-graining the locking ever more harder.  As we relax the
> kernel locks, the atomic_t becomes more and more important.

I'm afraid. I still think that it will never be needed even removing
lock_kernel(), because doing that we would need to make atomic the
decreasing of mm->count with current->mm = &init_mm, otherwise we would
not know if we can touch the current->mm of a process at any time. 

It's far from be like the semaphore case where we avoid the spinlock to
not race because we can order our moves differently if we are in down() or
in up(). 

But maybe I am missing something, but it's what I think though.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
