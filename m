Date: Tue, 10 Oct 2000 12:06:07 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <20001010042941.C3386@parcelfarce.linux.theplanet.co.uk>
Message-ID: <Pine.LNX.4.21.0010101205100.11122-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Philipp Rumpf <prumpf@parcelfarce.linux.theplanet.co.uk>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Oct 2000, Philipp Rumpf wrote:

> > > The algorithm you posted on the list in this thread will kill
> > > init if on 4Mbyte machine without swap init is large 3 Mbytes
> > > and you execute a task that grows over 1M.
> > 
> > This sounds suspiciously like the description of a DEAD system ;)
> 
> But wouldn't a watchdog daemon which doesn't allocate any memory
> still get run ?

Indeed, it would. It would also /prevent/ the system
from automatically rebooting itself into a usable state ;)

> > (in which case you simply don't care if init is being killed or not)
> 
> You care about getting an automatic reboot.  So you need to be sure the
> watchdog daemon gets killed first or you panic() after some time.

echo 30 > /proc/sys/kernel/panic

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
