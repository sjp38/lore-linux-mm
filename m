Date: Tue, 10 Oct 2000 04:29:41 +0100
From: Philipp Rumpf <prumpf@parcelfarce.linux.theplanet.co.uk>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001010042941.C3386@parcelfarce.linux.theplanet.co.uk>
References: <20001009214214.G19583@athlon.random> <Pine.LNX.4.21.0010091706100.1562-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010091706100.1562-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 09, 2000 at 05:06:48PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > The algorithm you posted on the list in this thread will kill
> > init if on 4Mbyte machine without swap init is large 3 Mbytes
> > and you execute a task that grows over 1M.
> 
> This sounds suspiciously like the description of a DEAD system ;)

But wouldn't a watchdog daemon which doesn't allocate any memory still
get run ?

> (in which case you simply don't care if init is being killed or not)

You care about getting an automatic reboot.  So you need to be sure the
watchdog daemon gets killed first or you panic() after some time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
