Date: Wed, 4 Oct 2000 18:46:25 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Odd swap behavior
In-Reply-To: <39DBA38F.B2607361@sgi.com>
Message-ID: <Pine.LNX.4.21.0010041844510.1054-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Oct 2000, Rajagopal Ananthanarayanan wrote:
> Rik van Riel wrote:
> > On Tue, 3 Oct 2000, Rajagopal Ananthanarayanan wrote:
> > 
> > > I'm running fairly stressful tests like dbench with lots of
> > > clients. Since the new VM changes (now in test9), I haven't
> > > noticed _any_ swap activity, in spite of the enormous memory

> > Small code changes in deactivate_page() have caused the
> > drop_behind() code to actually WORK AS ADVERTISED right
> > now, and because of that streaming IO doesn't put any
> > memory pressure on the system.
> 
> Agreed. And since the introduction of drop_behind &
> the deactivate_page() in generic_file_write, streaming I/O
> performance has become pretty good.
> 
> However, in the above I was particularly talking about
> swap behaviour on running dbench. Dbench is write intensive,
> and also has fair amount of re-writes. So, the I'm not
> sure why we still do not swap out _really_ old processes.

Please take a look at vmscan.c::refill_inactive()

Furthermore, we don't do background scanning on all
active pages, only on the unmapped ones.

This is one of the things we'll be able to fix in
2.5...

> If old pages are not swapped out, then dbench itself
> will get less than optimal amount of the page-cache during
> its run. I believe this is one of the reasons for
> dbench's poor showing with the new VM.

Agreed, but I don't see an "easy" solution for 2.4.

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
