Subject: Re: [PATCH] swap_state.c thinko
Message-ID: <OFF70E8B5F.A2073252-ON85256A26.006E7BF4@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Fri, 6 Apr 2001 16:20:17 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


>So I don't think it would necessarily be wrong to say
>something like
>
>    free -= num_physpages >> 6;
>
>to approximate the notion of "keep 1 percent slop" (remember, the 1% may
>well be on the swap device, not actually kept as free memory).


Hi,

I suggested the same thing to Rik but he rightfully said that it would
not work well for diskless (or swap-less) machines.  You may want to
consider the following instead.

     free -= (nr_swap_pages)? num_physpages >> 6 : 0;

By the way, disk space is cheap why not give more than 1 percent slop?
This is really accounted in the swap space and not the memory.
It will also help system out of oom_killer's radar.

Bulent Abali  (abali@us.ibm.com)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
