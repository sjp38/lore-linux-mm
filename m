Received: from fgwnews.fujitsu.co.jp (fgwnews.fujitsu.co.jp [164.71.1.134])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA07973
	for <linux-mm@kvack.org>; Tue, 8 Dec 1998 21:45:02 -0500
Message-Id: <199812090241.LAA15658@fireball.otsd.ts.fujitsu.co.jp>
Subject: Re: [PATCH] swapin readahead and fixes
From: Drago Goricanec <drago@king.otsd.ts.fujitsu.co.jp>
In-Reply-To: Your message of "Tue, 8 Dec 1998 03:31:25 +0100 (CET)"
References: <Pine.LNX.3.96.981208032438.8407C-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Date: Wed, 09 Dec 1998 11:41:52 +0900
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@phys.uu.nl
Cc: Billy.Harvey@thrillseeker.net, sct@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, 8 Dec 1998 03:31:25 +0100 (CET), Rik van Riel writes:

> On a swapout, we will scan ahead of where we are (p->swap_address)
> and swap out the next number of pages too. We break the loop if:
> - the page isn't present or already in swap
> - the next two pages were touched since our last scan
> - the page isn't allocated
> - we reach the end of a SWAP_CLUSTER area in swap space
> 
> If we write this way (no more expensive than normal because
> we write the stuff in one disk movement) swapin readahead
> will be much more effective and performance will increase.

Except for disk I/O bound processes, where the swapout writeahead
steals some extra time from the disk.  I guess this is where having
separate swap and data disks would help.

Looking forward to trying out your patches myself.

Drago


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
