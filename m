Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA10564
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 02:54:23 -0500
Date: Fri, 8 Jan 1999 23:53:38 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] MM fix & improvement
In-Reply-To: <87k8yw295p.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.95.990108235255.4363A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>



On 9 Jan 1999, Zlatko Calusic wrote:
>
> OK, here it goes. Patch is unbelievably small, and improvement is
> BIG.

Looks good. Especially the fact that once again performance got a lot
better by _removing_ some silly heuristics that didn't actually work.

Applied,

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
