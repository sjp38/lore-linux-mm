Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA31115
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 15:27:59 -0500
Date: Thu, 7 Jan 1999 12:27:19 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Results: 2.2.0-pre5 vs arcavm10 vs arcavm9 vs arcavm7
In-Reply-To: <Pine.LNX.3.96.990107123008.310G-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.990107122547.5025E-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Steve Bergman <steve@netplus.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Thu, 7 Jan 1999, Andrea Arcangeli wrote:
> 
> The changes in 2.2.0-pre5 looks really cool! I think the only missing
> thing that I would like to see in is my calc_swapout_weight() thing. This
> my change would avoid swap_out() to stall too much the system in presence
> of huge tasks and so it would allow the VM to scale better...

Note that if swap_out swaps something out, it will always return 1 (it has
to, as it sleeps), and that in turn will make us decrement our counter,
which will make us stop paging things out soon enough.. 

So I really don't think it's a scaling issue either.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
