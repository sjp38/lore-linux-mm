Date: Wed, 17 Jan 2001 18:12:03 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <Pine.LNX.4.21.0101140136200.11917-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.31.0101171809560.30841-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 14 Jan 2001, Marcelo Tosatti wrote:

> No, but I can imagine.

Please save imagination for the 2.5 kernel. 2.4.0 is
reasonably fine and nobody wants to repeat 2.2...

If you have a hunch something might help, but don't
understand why, then you probably shouldn't put it in
2.4.

(OTOH, if you can exactly explain why something is b0rked
in 2.4 and how to fix it and people agree with you, then
it should be something that can be safely applied after a
few days of stress-testing)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
