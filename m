Date: Fri, 15 Sep 2000 12:56:31 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] workaround for lost dirty bits on x86 SMP
In-Reply-To: <Pine.LNX.4.21.0009112018110.5189-100000@devserv.devel.redhat.com>
Message-ID: <Pine.LNX.4.10.10009151252580.10606-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 11 Sep 2000, Ben LaHaise wrote:
>
> The patch below is one means of working around the lost dirty bit problem
> on x86 SMP.  If possible, I'ld like to see this tested in 2.4 as it would
> be the least intrusive fix for 2.2.

Yes, I think this is the right fix.

I've seriously considered making this a architecturally visible feature:
the reason for that is that we're probably better off knowing how many
dirty pages the user has _anyway_ - just to be able to balance things off
a bit. 

So it might be a good idea to make this stuff happen for the UP case too,
instead of trying to optimize it away there..

Have you done any statistics on how many of these "clean->dirty" faults we
get? Because obviously we _will_ fault more. I don't think it happens all
that often (most of them will probably have been COW-faults anyway, the
way Linux handles anonymous pages), but it would be good to see actual
numbers like "increases system page faults by 1%" in order to get more
than just an intuitive feel for it..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
