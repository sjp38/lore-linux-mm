Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA10353
	for <linux-mm@kvack.org>; Wed, 9 Dec 1998 07:12:31 -0500
Date: Wed, 9 Dec 1998 11:58:00 GMT
Message-Id: <199812091158.LAA01234@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <199812090241.LAA15658@fireball.otsd.ts.fujitsu.co.jp>
References: <Pine.LNX.3.96.981208032438.8407C-100000@mirkwood.dummy.home>
	<199812090241.LAA15658@fireball.otsd.ts.fujitsu.co.jp>
Sender: owner-linux-mm@kvack.org
To: Drago Goricanec <drago@king.otsd.ts.fujitsu.co.jp>
Cc: H.H.vanRiel@phys.uu.nl, Billy.Harvey@thrillseeker.net, sct@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 09 Dec 1998 11:41:52 +0900, Drago Goricanec
<drago@king.otsd.ts.fujitsu.co.jp> said:

>> If we write this way (no more expensive than normal because
>> we write the stuff in one disk movement) swapin readahead
>> will be much more effective and performance will increase.

> Except for disk I/O bound processes, where the swapout writeahead
> steals some extra time from the disk.  

Not necessarily: having to do extra seeks hurts the throughput MUCH
more than doing a bit more IO when the disk head is already in position.

> I guess this is where having separate swap and data disks would
> help.

That is _always_ a good idea, anyway.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
