Received: from penguin.e-mind.com ([195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA24862
	for <linux-mm@kvack.org>; Mon, 6 Jul 1998 08:35:05 -0400
Date: Mon, 6 Jul 1998 14:34:02 +0200 (CEST)
From: Andrea Arcangeli <arcangeli@mbox.queen.it>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807061031.LAA00800@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980706142359.169A-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Jul 1998, Stephen C. Tweedie wrote:

>On Sun, 5 Jul 1998 20:38:57 +0200 (CEST), Andrea Arcangeli
><arcangeli@mbox.queen.it> said:
>
>> kswapd must swap _nothing_ if _freeable_ cache memory is allocated.
>> kswapd _must_ consider freeable cache memory as _free_ not used memory
>> and so it must not start swapping out useful code and data for make
>> space for allocating more cache.  
>
>You just can't make blanket statements like that!  If you're on an 8MB

I' d like to not make statements like that, in that case the aging would
work ;-).

>or 16MB box doing compilations, then you desperately want unused process
>data pages --- idle bits of inetd, lpd, sendmail, init, the shell, the

Now also the process that needs memory got swapped out.

>top-level make and so on --- to be swapped out to make room for a few
>more header files in cache.  Throwing away all cache pages will also
>destroy readahead and prevent you from caching pages of a binary between
>successive invocations.

I _really_ don' t want cache and readahead when the system needs memory. 
The only important thing is to avoid the always swapin/out and provide
free memory to the process. You don' t run in a 32Mbyte box I see ;-).

Andrea[s] Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
