Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA04939
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 12:51:15 -0500
Date: Mon, 18 Jan 1999 09:49:44 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] NEW: arca-vm-21, swapout via shrink_mmap using PG_dirty
In-Reply-To: <Pine.LNX.3.96.990118095719.302B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.990118094803.2146B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On Mon, 18 Jan 1999, Andrea Arcangeli wrote:
> 
> I can't understand this. I think to know _where_ to mark the page dirty
> (in the `if (vm_op->swapout)' path) but I don't understand _where_ to
> write the page out to disk avoiding the fs deadlock. Writing them in
> shrink_mmap() would not fix the deadlock (obviously if shrink_mmap() is
> still recalled as now by try_to_free_pages() etc...). 

You'd write them out only from a separate deamon that only needs to scan
the physical page map. That separate deamon might actually be kswapd, but
that's just an implementation detail rather than a conceptual issue.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
