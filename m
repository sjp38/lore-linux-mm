Date: Wed, 12 Jul 2000 15:02:26 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <396bb43f.25232236@mail.mbay.net>
Message-ID: <Pine.LNX.4.21.0007121453460.18392-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Alvord <jalvo@mbay.net>
Cc: Andrea Arcangeli <andrea@suse.de>, "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jul 2000, John Alvord wrote:

> One question that puzzles me... cache for disk files and cache
> for program data will have very unlike characteristics.
> Executable program storage is typically more constant. Often
> disk files are read once and throw away and program data is
> often reused. This isn't always true, but it is very common.

Page aging is the solution here. Doing proper page aging
allows us to make the distinction between use-once pages
and pages which are used over and over again.

And the best part is that we can do that without regard
for what type of cache a page happens to be in. We replace
pages based on observing their usage pattern and not on
some assumptions we make based on what is (should be) in
the page....

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
