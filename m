Date: Mon, 4 Sep 2000 12:22:31 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Bad page count   with 2.4.0-t8p1-vmpatch2b
In-Reply-To: <39B33D14.C7239FB8@sgi.com>
Message-ID: <Pine.LNX.4.21.0009041221280.8855-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 3 Sep 2000, Rajagopal Ananthanarayanan wrote:

> The previous boot problem was apparently due to a
> bad run of lilo: at that time test8-pre2 was on
> the system, so may be there is some problem in test8-pre2.
> Anyway, I can now boot test8-pre1 + 2.4.0-t8p1-vmpatch2b.
> But a simple copy of a large file (filesize > memsize)
> brings out lots of messages on the console:
> 
> ---------
> Bad page count
> Bad page count
> Bad page count
> Bad page count
> ---------------

Bad debugging check. This was a false alarm (which slipped
in under pressure to locate the SMP race)

2.4.0-t8p1-vmpatch2 (without the b) should be better...

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
