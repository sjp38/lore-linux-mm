Received: from dm.cobaltmicro.com (davem@dm.cobaltmicro.com [209.133.34.35])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA03083
	for <linux-mm@kvack.org>; Mon, 25 May 1998 06:10:18 -0400
Date: Mon, 25 May 1998 03:07:46 -0700
Message-Id: <199805251007.DAA02073@dm.cobaltmicro.com>
From: "David S. Miller" <davem@dm.cobaltmicro.com>
In-reply-to: <199805241728.SAA02816@dax.dcs.ed.ac.uk> (sct@dcs.ed.ac.uk)
Subject: Re: patch for 2.1.102 swap code
References: <356478F0.FE1C378F@star.net> <199805241728.SAA02816@dax.dcs.ed.ac.uk>
Sender: owner-linux-mm@kvack.org
To: sct@dcs.ed.ac.uk
Cc: whawes@star.net, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com, linux-mm@kvack.org, number6@the-village.bc.nu
List-ID: <linux-mm.kvack.org>

   Date: 	Sun, 24 May 1998 18:28:48 +0100
   From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>

   The __get_free_page() may block, however, and in a threaded
   environment this will cause the loss of user data plus a memory
   leak if two threads hit this race.  However, I don't think it's
   related to the current writable cached page problems.

The mmap semaphore is held, it cannot happen.

Later,
David S. Miller
davem@dm.cobaltmicro.com
