Date: Mon, 25 Sep 2000 17:24:12 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000925172412.A25814@athlon.random>
References: <20000925170113.S22882@athlon.random> <Pine.LNX.4.21.0009251702090.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251702090.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 05:10:43PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 05:10:43PM +0200, Ingo Molnar wrote:
> a SIGKILL? i agree with the 2.2 solution - first a soft signal, and if
> it's being ignored then a SIGKILL.

Actually we do the soft signal try (SIGTERM) only if the task was running
with iopl privilegies (and that means on alpha and other archs where
there isn't the iopl we send a SIGKILL to X immediatly).

Extending it to all tasks looked a bit riskious solution because then we would
even less probability to kill the right task since all tasks would run oom
while the first is put to sleep for a while. With X we really prefer to kill
another task than screwup the console instead (even when X is the real hog, and
X can be made the real hog by any tasks that allocates huge xshm). Kray
reproduces this easily.

> > But my question isn't what you do when you're OOM, but is _how_ do you
> > notice that you're OOM?
> 
> good question :-)

:))

> i think the GFP_USER case should do the oom logic within __alloc_pages(),

What's the difference of implementing the logic outside alloc_pages? Putting
the logic inside looks not clean design to me.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
