Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA24415
	for <linux-mm@kvack.org>; Mon, 6 Jul 1998 07:08:06 -0400
Date: Mon, 6 Jul 1998 11:31:12 +0100
Message-Id: <199807061031.LAA00800@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980705202128.12985B-100000@dragon.bogus>
References: <Pine.LNX.3.96.980705185219.1574D-100000@mirkwood.dummy.home>
	<Pine.LNX.3.96.980705202128.12985B-100000@dragon.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <arcangeli@mbox.queen.it>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 5 Jul 1998 20:38:57 +0200 (CEST), Andrea Arcangeli
<arcangeli@mbox.queen.it> said:

> kswapd must swap _nothing_ if _freeable_ cache memory is allocated.
> kswapd _must_ consider freeable cache memory as _free_ not used memory
> and so it must not start swapping out useful code and data for make
> space for allocating more cache.  

You just can't make blanket statements like that!  If you're on an 8MB
or 16MB box doing compilations, then you desperately want unused process
data pages --- idle bits of inetd, lpd, sendmail, init, the shell, the
top-level make and so on --- to be swapped out to make room for a few
more header files in cache.  Throwing away all cache pages will also
destroy readahead and prevent you from caching pages of a binary between
successive invocations.

That's the problem with all rules of the form "memory management MUST
prioritise X over Y".  There are always cases where it is not true.
What we need is a balance, not arbitrary rules like that.  

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
