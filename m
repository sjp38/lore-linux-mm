Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA00010
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 18:58:27 -0500
Date: Fri, 8 Jan 1999 00:56:16 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Results: 2.2.0-pre5 vs arcavm10 vs arcavm9 vs arcavm7
In-Reply-To: <Pine.LNX.3.95.990107122547.5025E-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990108005308.1364E-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 1999, Linus Torvalds wrote:

> Note that if swap_out swaps something out, it will always return 1 (it has
> to, as it sleeps), and that in turn will make us decrement our counter,

Side note, when we swapout something we stop completly swapping out and we
return to try_to_free_pages() (still better for the issue we was talking
about ;). 

> So I really don't think it's a scaling issue either.

Yes, I think you are right. I am rejecting the calc_swapout_weight code.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
