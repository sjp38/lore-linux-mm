From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14476.42622.777454.521474@dukat.scot.redhat.com>
Date: Mon, 24 Jan 2000 19:22:38 +0000 (GMT)
Subject: Re: [PATCH] 2.2.14 VM fix #3
In-Reply-To: <Pine.LNX.4.21.0001211425210.486-100000@alpha.random>
References: <Pine.LNX.4.10.10001210425250.27593-100000@mirkwood.dummy.home>
	<Pine.LNX.4.21.0001211425210.486-100000@alpha.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@nl.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 21 Jan 2000 14:34:14 +0100 (CET), Andrea Arcangeli
<andrea@suse.de> said:

> Sorry but I will never agree with your patch. The GFP_KERNEL change is not
> something for 2.2.x. We have major deadlocks in getblk for example and you
> may trigger tham more easily forbidding GFP_MID allocations to
> succeed. 

Agreed, definitely.

> Also killing the low_on_memory will harm performance. You doesn't seems to
> see what such bit (that should be a per-process thing) is good for.

Also agreed --- removing the per-process flag will just penalise _all_
processes when we enter thrashing.

> And the 1-second polling loop has to be killed since it make no sense.

Actually, that probably isn't too bad, as long as we make sure we wake
up kswapd on GFP_ATOMIC allocations when the free page count gets below
freepages.min, even if the allocation succeeded (and Rik's patch does
do that).

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
