Received: from mail.ccr.net (ccr@alogconduit1ao.ccr.net [208.130.159.15])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA25102
	for <linux-mm@kvack.org>; Wed, 6 Jan 1999 23:29:51 -0500
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
References: <Pine.LNX.3.95.990106153252.7800D-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 06 Jan 1999 22:30:59 -0600
In-Reply-To: Linus Torvalds's message of "Wed, 6 Jan 1999 15:35:01 -0800 (PST)"
Message-ID: <m1aezvg0vw.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:

LT> Oh, well.. Based on what the arca-[678] patches did, there's now a pre-5
LT> out there. Not very similar, but it should incorporate the basic idea: 
LT> namely much more aggressively asynchronous swap-outs from a process
LT> context. 

LT> Comment away,

1) With your comments on PG_dirty/(what shrink_mmap should do) you
   have worked out what needs to happen for the mapped in memory case,
   and I haven't quite gotten there.  Thank You.

2) I have tested using PG_dirty from shrink_mmap and it is a
   performance problem because it loses all locality of reference,
   and because it forces shrink_mmap into a dual role, of freeing and
   writing pages, which need seperate tuning.

Linus is this a case you feel is important to tune for 2.2?
If so I would be happy to play with it.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
