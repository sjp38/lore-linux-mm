Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA13165
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 19:26:48 -0500
Date: Thu, 28 Jan 1999 16:17:42 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.96.990128205918.438B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.990128161635.956I-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 28 Jan 1999, Andrea Arcangeli wrote:
>
> If you remove the kernel lock around do_exit() you _need_ my mm_lock
> spinlock. You need it to make atomic the decreasing of mm->count and
> current->mm = &init_mm. If the two instructions are not atomic you have
> _no_ way to know if you can mmget() at any time the mm of a process.

Andrea, just go away.

The two do not _have_ to be atomic, they never had to, and they never
_will_ have to be atomic. You obviously haven't read all my email
explaining why they don't have to be atomic.

> I repeat in another way (just trying to avoid English mistakes): 
> decreasing mm->count has to go in sync with updating current->mm,

No it has not.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
