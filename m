Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA04079
	for <linux-mm@kvack.org>; Tue, 8 Dec 1998 07:21:26 -0500
Date: Tue, 8 Dec 1998 12:21:04 GMT
Message-Id: <199812081221.MAA02301@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <366C8214.F58091FF@thrillseeker.net>
References: <199812041434.OAA04457@dax.scot.redhat.com>
	<Pine.LNX.3.95.981205102900.449A-100000@localhost>
	<199812071650.QAA05697@dax.scot.redhat.com>
	<366C8214.F58091FF@thrillseeker.net>
Sender: owner-linux-mm@kvack.org
To: Billy Harvey <Billy.Harvey@thrillseeker.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 07 Dec 1998 20:34:12 -0500, Billy Harvey
<Billy.Harvey@thrillseeker.net> said:

> Has anyone ever looked at the following concept?  In addition to a
> swap-in read-ahead, have a swap-out write-ahead.  The idea is to use all
> the avaialble swap space as a mirror of memory.  

We already do that.  That's what the swap cache is.  When kswapd swaps
stuff out, it does so asynchronously, but leaves the data in the swap
cache where it can be picked up again if another process wants the
swap entry back.  Most importantly, it lets us do the writing to swap
very rapidly, as we can efficiently stream the updates to disk.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
