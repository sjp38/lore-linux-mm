Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA18723
	for <linux-mm@kvack.org>; Mon, 20 Jul 1998 16:12:48 -0400
Date: Mon, 20 Jul 1998 16:58:01 +0100
Message-Id: <199807201558.QAA01389@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <m1pvf3jeob.fsf@flinx.npwt.net>
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
	<199807141730.SAA07239@dax.dcs.ed.ac.uk>
	<m14swgm0am.fsf@flinx.npwt.net>
	<87d8b370ge.fsf@atlas.CARNet.hr>
	<m1pvf3jeob.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: Zlatko.Calusic@CARNet.hr, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 18 Jul 1998 11:40:20 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

>>>>>> "ZC" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:
> Let me just step back a second so I can be clear:

> A) The idea proposed by Stephen way perhaps we could use Least
> Recently Used lists instead of page aging.  It's effectively the same
> thing but shrink_mmap can find the old pages much much faster, by
> simply following a linked list.

> B) This idea intrigues me because handling of generic dirty pages
> I have about the same problem.  In cloneing bdflush for the page cache
> I discovered two fields I would need to add to struct page to do an
> exact cloning job.  A page writetime, and LRU list pointers for dirty
> pages.  I went ahead and implemented them, but also implemented an
> alternative, which is the default.

We already have all of the inode's pages on a linked list.  Extending
that to have two separate lists, one for clean pages and one for
dirty, would be cheap and would not have the extra memory overhead.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
