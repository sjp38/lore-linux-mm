Received: from hoon.perlsupport.com (root@[24.92.174.199])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA00907
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 17:10:06 -0500
Received: by hoon.perlsupport.com
	via sendmail from stdin
	id <m0zjRYa-0001cSC@hoon.perlsupport.com> (Debian Smail3.2.0.102)
	for linux-mm@kvack.org; Fri, 27 Nov 1998 12:19:48 -0500 (EST)
Date: Fri, 27 Nov 1998 12:19:48 -0500
From: Chip Salzenberg <chip@perlsupport.com>
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
Message-ID: <19981127121948.A327@perlsupport.com>
References: <199811261236.MAA14785@dax.scot.redhat.com> <Pine.LNX.3.95.981126094159.5186D-100000@penguin.transmeta.com> <199811271602.QAA00642@dax.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199811271602.QAA00642@dax.scot.redhat.com>; from Stephen C. Tweedie on Fri, Nov 27, 1998 at 04:02:51PM +0000
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

According to Stephen C. Tweedie:
> On reflection, there is a completely natural way of distinguishing
> between these two cases, and that is to extend the size of the
> shrink_mmap() pass whenever we encounter many recently touched pages.

This patch has _vastly_ improved my subjective impression of the VM
behavior of 130-pre3.  My computer is a laptop with 32M and a fairly
slow (non-DMA) hard drive; after this patch, things that used to be
quite slow -- especially Navigator -- seem much more snappy.

Thanks!
-- 
Chip Salzenberg      - a.k.a. -      <chip@perlsupport.com>
      "When do you work?"   "Whenever I'm not busy."
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
