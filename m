Received: from chiara.csoma.elte.hu (chiara.csoma.elte.hu [157.181.71.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA27422
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 09:48:43 -0400
Date: Wed, 7 Apr 1999 15:47:50 +0200 (CEST)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [patch] only-one-cache-query [was Re: [patch] arca-vm-2.2.5]
In-Reply-To: <Pine.LNX.4.05.9904070243310.222-100000@laser.random>
Message-ID: <Pine.LNX.3.96.990407154601.30376E-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Mark Hemment <markhe@sco.COM>, Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Apr 1999, Andrea Arcangeli wrote:

>  void prune_dcache(int count)
>  {
> +	gfp_sleeping_cookie++;

this can be done via an existing variable, kstat.ctxsw, no need to add yet
another 'have we scheduled' flag. But the whole approach is quite flawed
and volatile, it simply relies on us having the big kernel lock. With more
finegrained SMP locking in that area we will have big problems preserving
that solution.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
