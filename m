Received: from dm.cobaltmicro.com (davem@dm.cobaltmicro.com [209.133.34.35])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA03933
	for <linux-mm@kvack.org>; Mon, 25 May 1998 09:45:18 -0400
Date: Mon, 25 May 1998 06:42:53 -0700
Message-Id: <199805251342.GAA03658@dm.cobaltmicro.com>
From: "David S. Miller" <davem@dm.cobaltmicro.com>
In-reply-to: <3569699E.6C552C74@star.net> (message from Bill Hawes on Mon, 25
	May 1998 08:52:46 -0400)
Subject: Re: patch for 2.1.102 swap code
References: <356478F0.FE1C378F@star.net> <199805241728.SAA02816@dax.dcs.ed.ac.uk> <3569699E.6C552C74@star.net>
Sender: owner-linux-mm@kvack.org
To: whawes@star.net
Cc: sct@dcs.ed.ac.uk, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com, linux-mm@kvack.org, number6@the-village.bc.nu
List-ID: <linux-mm.kvack.org>

   Date: 	Mon, 25 May 1998 08:52:46 -0400
   From: Bill Hawes <whawes@star.net>

   > Could you cast your eyes over the patch below?  It builds fine
   > and passes the tests I've thrown at it so far, but I'd like a
   > second opinion before forwarding it as a patch for 2.0.

   The patch looks reasonable to me, but as DaveM mentioned in a later
   mail, the do_wp_page case is supposed to be protected with a
   semaphore.

Alas, I thought about this some more.  And one piece of code needs to
be fixed for this invariant about the semaphore being held in the
fault processing code paths to be true everywhere... ptrace()...

Later,
David S. Miller
davem@dm.cobaltmicro.com
