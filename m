Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA16938
	for <linux-mm@kvack.org>; Thu, 10 Dec 1998 08:53:29 -0500
Date: Thu, 10 Dec 1998 13:52:55 GMT
Message-Id: <199812101352.NAA03129@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] VM improvements for 2.1.131
In-Reply-To: <Pine.LNX.3.96.981210001237.792A-100000@laser.bogus>
References: <Pine.LNX.3.96.981209220124.25588B-100000@mirkwood.dummy.home>
	<Pine.LNX.3.96.981210001237.792A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 10 Dec 1998 00:15:50 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> Nono, I reversed the vmscan changes on my tree. On my tree when swap_out
> returns 1 it has really freed a page ;). 

There are other issues with respect to the swap_out return value: in
particular, you MUST return 1 if you block (because during the block
interval the process underneath may have been killed), no matter what
state the current page is.  Be careful with this!

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
