Date: Mon, 2 Oct 2000 12:48:50 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Ignore my: Re: [PATCH] fix for VM  test9-pre7
In-Reply-To: <39D85CBE.28783101@norran.net>
Message-ID: <Pine.LNX.4.21.0010021245570.22539-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Roger Larsson wrote:

> My report was bogus - I had forgot to do a cp...

*grin*

> I have now retried. With good results.
> The only thing that worries me is that dbench results
> has declined a little from earlier test9.
> 
> System is responsive even during mmap002,
> and run of mmap002 is much faster then before :-)

This is due partly to Ananth' bugfix (we now set the page
age right for all pages) and partly due to the dynamic free
target we have right now.

The dbench thing I have to look into. I haven't figured out
yet why dbench performs slightly worse (but maybe it's just
because dbench uses an access pattern that benefits from
having worse page replacement ;))

> Summary:
> + No lookups, kills, good performance...
> = I like it.

It seems that performance during the misc001 patch is pretty
bad at times, but indeed, during mmap001 and mmap002 the system
is quite usable (in console mode).

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
