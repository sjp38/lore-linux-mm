Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA07343
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 16:29:52 -0500
Message-Id: <m102N67-0007U1C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: BUG: deadlock in swap lockmap handling
Date: Mon, 18 Jan 1999 22:24:38 +0000 (GMT)
In-Reply-To: <Pine.LNX.3.96.990118203741.9904A-100000@laser.bogus> from "Andrea Arcangeli" at Jan 18, 99 09:26:05 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: andrea@e-mind.com
Cc: Zlatko.Calusic@CARNet.hr, sct@redhat.com, torvalds@transmeta.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> I think it will not harm too much because the window is not too big (but
> not small) and because usually one of the process not yet deadlocked will
> generate IO and will wakeup also the deadlocked process at I/O
> completation time. A very lazy ;) but at the same time obviosly right

Take it from me - the scenario you give will cause deadlocks and problems.
There were other "generating an I/O would have cleaned up" type problems in
2.0.x < .35/6. They caused a lot of grief with installers where that 
I/O assumption is not true. Another classic case is large fsck's during
boot up.

So its not just a trivial irrelevant fix.

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
