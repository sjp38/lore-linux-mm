Date: Tue, 10 Oct 2000 04:23:23 +0100
From: Philipp Rumpf <prumpf@parcelfarce.linux.theplanet.co.uk>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001010042323.B3386@parcelfarce.linux.theplanet.co.uk>
References: <Pine.LNX.4.21.0010092223100.8045-100000@elte.hu> <Pine.LNX.4.21.0010091717160.1562-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010091717160.1562-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 09, 2000 at 05:18:12PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> (but I'd be curious if somebody actually manages to
> trick the OOM killer into killing init ... please
> test a bit more to see if this really happens ;))

In a non-real-world situation, yes.  (mem=3500k, many drivers, init=/bin/bash,
tried to enter a command).  Since the process in question (bash) ignores
SIGTERM, I actually got a hard hang. 

We really should turn this into a panic() (panic means your elevator control
system reboots and maybe misses the right floor.  hard hang means you need
to reboot manually).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
