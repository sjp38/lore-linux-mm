Date: Mon, 9 Oct 2000 17:34:21 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <39E22A62.325C729E@kalifornia.com>
Message-ID: <Pine.LNX.4.21.0010091733240.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david+validemail@kalifornia.com
Cc: mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, David Ford wrote:
> Ingo Molnar wrote:
> 
> > > a good idea to have SIGKILL delivery speeded up for every SIGKILL ...
> >
> > yep.
> 
> How about SIGTERM a bit before SIGKILL then re-evaluate the OOM
> N usecs later?

And run the risk of having to kill /another/ process as well ?

I really don't know if that would be a wise thing to do
(but feel free to do some tests to see if your idea would
work ... I'd love to hear some test results with your idea).

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
