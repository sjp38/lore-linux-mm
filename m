Received: from MIT.EDU (PACIFIC-CARRIER-ANNEX.MIT.EDU [18.69.0.28])
	by kvack.org (8.8.7/8.8.7) with SMTP id MAA22033
	for <linux-mm@kvack.ORG>; Fri, 29 Jan 1999 12:51:54 -0500
Date: Fri, 29 Jan 1999 12:46:55 -0500 (EST)
Message-Id: <199901291746.MAA14485@dcl>
From: "Theodore Y. Ts'o" <tytso@MIT.EDU>
In-Reply-To: Andrea Arcangeli's message of Fri, 29 Jan 1999 15:14:37 +0100
	(CET), <Pine.LNX.3.96.990129144844.886A-100000@laser.bogus>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   > note that in 99% of the cases we need the counter only in the clone(),
   > exec() and exit() path, for these three cases we know implicitly that it's
   > a valid buffer. (because we hold a reference to it) [subsequently we dont
   > need any atomic_inc_and_test thing either for clone+exec+exit] An atomic
   > counter is just about perfect for those uses, even in the 'no kernel lock'
   > case. 

   Sure, if you look at my last email to Linus, you'll see that I am _only_
   talking about getting the mm of a random process (not the current one!).

I think the important thing to remember is that Linus has said that he's
only interested in critical bug fixes at this point.  So things which
make certain other operations conceptually easier in the future are
simply not of interest at this point.  That's probably the cause of the
confusion --- you're trying to solve a general problem, and Linus is
trying to make Linus 2.2 stable.  There's a time for fixing general
problems in the kernel, and that was when we were still in the 2.1
development kernel, and it will happen again once Linus opens the 2.3
tree.

In the meantime, I suggest you save your patches; I have a number of
patches which I'm working on and saving to be sent to Linus once the 2.3
development tree opens up.  

Also, those of us who are experts with our parts of the kernel should
consider spending at least some of time investigating bug reports sent
in by users, and fixing stability problems in the 2.2 kernel, in
addition to working on future changes for 2.3.  The sooner we can get
2.2 stable, the sooner 2.3 can get opened, and the happier Linux users
(our customers!) will be.

							- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
