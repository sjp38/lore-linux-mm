Date: Mon, 9 Oct 2000 17:06:48 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <20001009214214.G19583@athlon.random>
Message-ID: <Pine.LNX.4.21.0010091706100.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Andrea Arcangeli wrote:
> On Mon, Oct 09, 2000 at 04:07:32PM -0300, Rik van Riel wrote:
> > No. It's only needed if your OOM algorithm is so crappy that
> > it might end up killing init by mistake.
> 
> The algorithm you posted on the list in this thread will kill
> init if on 4Mbyte machine without swap init is large 3 Mbytes
> and you execute a task that grows over 1M.

This sounds suspiciously like the description of a DEAD system ;)

(in which case you simply don't care if init is being killed or not)

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
