Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA19131
	for <linux-mm@kvack.ORG>; Fri, 29 Jan 1999 07:08:55 -0500
Date: Fri, 29 Jan 1999 13:08:28 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.96.990129120839.22453C-100000@chiara.csoma.elte.hu>
Message-ID: <Pine.LNX.3.96.990129124407.639A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Jan 1999, MOLNAR Ingo wrote:

> yes, there is no atomic_inc_and_test() yet. (it's a bit tricky to

_Where_ do you want to run atomic_inc_and_test()? On random kernel data
where incidentally a long time ago there was the just deallocated
and reused (somewhere else) mm_struct?

If we incidentally access the mm_struct and we notice that the mm->count
is zero it menas we are just buggy. 

> sign flag.) Also note that this is all fiction yet because we _are_
> holding the kernel lock for these situations in 2.2.

Sure it's finction, but _all_ complains I get against my s/atomic_t/int/
was about the future.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
