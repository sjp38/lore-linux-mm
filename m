Date: Mon, 30 Aug 1999 10:50:11 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: accel handling
In-Reply-To: <14282.37533.98879.414300@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9908301043070.3506-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The only way to do it is to flip page tables while the accel engine is
> running.  You may want to restore it on demand by trapping the page
> fault on the framebuffer and stalling until the accel lock is released.
> This can be done, but it is really expensive: you are doing a whole pile
> of messy VM operations every time you want to trigger the accel engine
> (any idea how often you want to flip the protection, btw?)
>

The way the accel engine will work is that it will batch accel commands.
Then when full flush them to the accel engine. So we can batch a hugh
number of commands to avoid the expensive process of flipping page tables.
Of course the buffer is of variable size. The size determined by how many
accel commands you want to send to the engine to display a frame. So a
complex scene would be worth it.  
 
> So you are talking several system calls, SMP inter-processor interrupts
> and piles of VM page twiddling every time you want to claim and release
> the core engine.  Sorry, folks, but there's no way of avoiding the
> conclusion that this is going to be expensive.  In the single-CPU or
> single-thread case the cost can be kept under control, but it is not
> going to be cheap.

The secert is to do a as few times possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
