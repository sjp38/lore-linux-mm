Received: from chiara.csoma.elte.hu (chiara.csoma.elte.hu [157.181.71.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA18758
	for <linux-mm@kvack.ORG>; Fri, 29 Jan 1999 06:29:44 -0500
Date: Fri, 29 Jan 1999 12:20:43 +0100 (CET)
From: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Reply-To: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.96.990129015657.8557A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990129120839.22453C-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Jan 1999, Andrea Arcangeli wrote:

> Another way to tell the same: "how can I be sure that I am doing an
> atomic_inc(&mm->count) on a mm->count that was just > 0, and more
> important on an mm that is still allocated? "

you are misunderstanding how atomic_inc_and_test() works. The processor
guarantees this. This is the crux of SMP atomic operations. How otherwise
could we reliably build read-write spinlocks.

yes, there is no atomic_inc_and_test() yet. (it's a bit tricky to
implement but pretty much analogous to read-write locks, we probably need
to shift values down by one to get the 'just increased from -1 to 0' event
via the zero flag, and get the 'just decreased from 0 to -1' event via the
sign flag.) Also note that this is all fiction yet because we _are_
holding the kernel lock for these situations in 2.2.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
