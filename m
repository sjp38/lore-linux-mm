Date: Mon, 9 Oct 2000 18:34:29 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010092336230.9803-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0010091833280.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Ingo Molnar wrote:
> On Mon, 9 Oct 2000, Rik van Riel wrote:
> 
> > Would this complexity /really/ be worth it for the twice-yearly OOM
> > situation?
> 
> the only reason i suggested this was the init=/bin/bash, 4MB
> RAM, no swap emergency-bootup case. We must not kill init in
> that case - if the current code doesnt then great and none of
> this is needed.

I guess this requires some testing. If anybody can reproduce
the bad effects without going /too/ much out of the way of a
realistic scenario, the code needs to be fixed.

If it turns out to be a non-issue in all scenarios, there's
no need to make the code any more complex.

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
