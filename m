Date: Mon, 25 Sep 2000 17:10:43 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VM
In-Reply-To: <20000925170113.S22882@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251702090.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> Signal can be trapped and ignored by malicious task. [...]

a SIGKILL? i agree with the 2.2 solution - first a soft signal, and if
it's being ignored then a SIGKILL.

> But my question isn't what you do when you're OOM, but is _how_ do you
> notice that you're OOM?

good question :-)

> In the GFP_USER case simply checking when GFP fails looks right to me.

i think the GFP_USER case should do the oom logic within __alloc_pages(),
by SIGTERM/SIGKILL-ing off abusive processes. Ie. it's *still* an infinite
loop (barring the case where *this* process is abusive, but thats a
detail).

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
