Date: Mon, 9 Oct 2000 18:54:04 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010091747450.30915-100000@squeaker.ratbox.org>
Message-ID: <Pine.LNX.4.21.0010091853030.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aaron Sethman <androsyn@ratbox.org>
Cc: James Sutherland <jas88@cam.ac.uk>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Aaron Sethman wrote:

> I think the run time should probably be accounted into to this
> as well. Basically start knocking off recent processes first,
> which are likely to be childless, and start working your way up
> in age.

I'm almost getting USENET flashbacks ...  ;)

Please look at the code before suggesting something that
is already there (and has been in the code for some 2 years).

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
