Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA30712
	for <linux-mm@kvack.org>; Wed, 27 Jan 1999 16:59:57 -0500
Date: Wed, 27 Jan 1999 13:45:22 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <199901272138.VAA12114@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990127134448.30467Z-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.cobaltmicro.com>, gandalf@szene.ch, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.com, djf-lists@ic.net, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 27 Jan 1999, Stephen C. Tweedie wrote:
> 
> In other words, we are grabbing a task, pinning the mm_struct, blocking
> for the mm semaphore and releasing the task's *current* mm_struct, which
> is not necessarily the same as it was before we blocked.  In particular,
> if we catch the process during a fork+exec, then it is perfectly
> possible for tsk->mm to change here.

Good point. I reverted part of the array.c patches in the released 2.2.0,
it seems I should really have reverted them all.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
