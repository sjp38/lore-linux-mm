Date: Mon, 9 Oct 2000 16:07:32 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <20001009210503.C19583@athlon.random>
Message-ID: <Pine.LNX.4.21.0010091606420.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Andrea Arcangeli wrote:
> On Mon, Oct 09, 2000 at 08:42:26PM +0200, Ingo Molnar wrote:
> > ignoring the kill would just preserve those bugs artificially.
> 
> If the oom killer kills a thing like init by mistake

That only happens in the "random" OOM killer 2.2 has ...

> So you have two choices:
> 
> o	math proof that the current algorithm without the magic can't end
> 	killing init (and I should be able to proof the other way around
> 	instead)
> 
> o	have a magic check for init
> 
> So the magic is _strictly_ necessary at the moment.

No. It's only needed if your OOM algorithm is so crappy that
it might end up killing init by mistake.

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
