Date: Mon, 9 Oct 2000 20:16:49 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <200010092313.e99NDQX173855@saturn.cs.uml.edu>
Message-ID: <Pine.LNX.4.21.0010092015340.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Albert D. Cahalan" <acahalan@cs.uml.edu>
Cc: Jim Gettys <jg@pa.dec.com>, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Albert D. Cahalan wrote:
> Jim Gettys writes:
> >> From: Linus Torvalds <torvalds@transmeta.com>
> 
> >> One of the biggest bitmaps is the background bitmap. So you have a
> >> client that uploads it to X and then goes away. There's nobody to
> >> un-count to by the time X decides to switch to another background.
> >
> > Actually, the big offenders are things other than the background
> > bitmap: things like E do absolutely insane things, you would not
> > believe (or maybe you would).  The background pixmap is generally
> > in the worst case typically no worse than 4 megabytes (for those
> > people who are crazy enough to put images up as their root window
> > on 32 bit deep displays, at 1kX1k resolution).
> 
> Still, it would be nice to recover that 4 MB when the system
> doesn't have any memory left.
> 
> X, and any other big friendly processes, could participate in
> memory balancing operations. X could be made to clean out a
> font cache when the kernel signals that memory is low. When
> the situation becomes serious, X could just mmap /dev/zero over
> top of the background image.
> 
> Netscape could even be hacked to dump old junk... or if it is
> just too leaky, it could exec itself to fix the problem.

Which is all good and well to DELAY the task of the OOM killer
for a few more minutes.

But in the end, there will be a point where you REALLY run out
of memory and you have no other choice than the OOM killer...

(not that I'm against alternative measures, I just think they're
orthagonal to this whole discussion)

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
