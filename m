Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA31309
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 11:51:35 -0500
Date: Mon, 7 Dec 1998 16:50:44 GMT
Message-Id: <199812071650.QAA05697@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <Pine.LNX.3.95.981205102900.449A-100000@localhost>
References: <199812041434.OAA04457@dax.scot.redhat.com>
	<Pine.LNX.3.95.981205102900.449A-100000@localhost>
Sender: owner-linux-mm@kvack.org
To: Gerard Roudier <groudier@club-internet.fr>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 5 Dec 1998 10:46:40 +0100 (MET), Gerard Roudier
<groudier@club-internet.fr> said:

> You may perform read-ahead when you really swap in a process that had been
> swapped out. But about paging, you must consider that this mechanism is
> not sequential but mostly ramdom in RL. So you just want to read more data
> at the same time and near the location that faulted. Reading-ahead is
> obviously candidate for this optimization, but reading behind must also be
> considered in my opinion.

Yep: one of the things which has been talked about, and which is on my
list of things to start experimenting with in 2.3, is increasing the
granularity of paging so that we automatically try to read in (say) 16K
at a time when we start paging a binary.  Discarding unused pages can
still work on a per-page granularity, so we don't bloat memory in the
long term, but it has the potential to significantly improve loading
times for some binaries.

Of course, there are also a whole number of optimisations we can make
explicitly for sequentially accessed mapped regions, but the granularity
trick should be a pretty cheap way to wring a bit more performance out
of the normal random paging.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
