Received: from hoon.perlsupport.com (root@dt0e3na9.tampabay.rr.com [24.92.175.169])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA28116
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 01:54:55 -0500
Received: by hoon.perlsupport.com
	via sendmail from stdin
	id <m0zzbKQ-0001bsC@hoon.perlsupport.com> (Debian Smail3.2.0.102)
	for linux-mm@kvack.org; Mon, 11 Jan 1999 01:59:58 -0500 (EST)
Date: Mon, 11 Jan 1999 01:59:58 -0500
From: Chip Salzenberg <chip@perlsupport.com>
Subject: Re: testing/pre-7 and do_poll()
Message-ID: <19990111015958.E3767@perlsupport.com>
References: <19990111012620.B3767@perlsupport.com> <Pine.LNX.3.95.990110223802.1997F-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.95.990110223802.1997F-100000@penguin.transmeta.com>; from Linus Torvalds on Sun, Jan 10, 1999 at 10:46:01PM -0800
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

According to Linus Torvalds:
> On Mon, 11 Jan 1999, Chip Salzenberg wrote:
> > Well, I forgot the (unsigned long) cast, as someone else noted:
> > 	timeout = ROUND_UP((unsigned long) timeout, 1000/HZ);
> > Otherwise, the code is Just Right.
> 
> Hint: HZ is a define - not 100.
> You just ended up dividing by zero on certain architectures.

I didn't think HZ ranged over 1000 in practice, else of course I would
not have written the above.
-- 
Chip Salzenberg      - a.k.a. -      <chip@perlsupport.com>
      "When do you work?"   "Whenever I'm not busy."
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
