Date: Tue, 10 Oct 2000 16:37:43 +0100
From: Philipp Rumpf <prumpf@parcelfarce.linux.theplanet.co.uk>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001010163743.F3386@parcelfarce.linux.theplanet.co.uk>
References: <20001010162412.E3386@parcelfarce.linux.theplanet.co.uk> <Pine.LNX.4.21.0010101228160.11122-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010101228160.11122-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Tue, Oct 10, 2000 at 12:30:51PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 10, 2000 at 12:30:51PM -0300, Rik van Riel wrote:
> Not killing init when we "should" definately prevents
> embedded systems from auto-rebooting when they should
> do so.
> 
> (OTOH, I don't think embedded systems will run into
> this OOM issue too much)

but when they do, they're hard to fix.  Think about an elevator control
system with a single process that happens to implement a somewhat broken
version of the elevator algorithm ;)

> > that's what I said.  we need to be sure to _get_ a panic() though.
> 
> I believe the kernel automatically panic()s when init
> dies ... from kernel/exit.c::do_exit()
> 
>         if (tsk->pid == 1)
>                 panic("Attempted to kill init!");

guess who added that code.  We still kill init with SIGTERM which doesn't
seem to work though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
