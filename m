Date: Wed, 4 Oct 2000 12:14:07 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Odd swap behavior
In-Reply-To: <39DA787E.B31422B4@sgi.com>
Message-ID: <Pine.LNX.4.21.0010041212540.10197-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Oct 2000, Rajagopal Ananthanarayanan wrote:

> I'm running fairly stressful tests like dbench with lots of
> clients. Since the new VM changes (now in test9), I haven't
> noticed _any_ swap activity, in spite of the enormous memory
> pressures. I have lots of processes in the system, like 8
> httpd's, 4 getty's, etc. most of which should be "idle" ... Why
> aren't the pages (eg. mapped stacks) from these processes being
> swapped out?

That's an interesting one. Most "complaints" I've had about
test9 is that it swaps more than previous versions ;)

But let me give you the answer...

Small code changes in deactivate_page() have caused the
drop_behind() code to actually WORK AS ADVERTISED right
now, and because of that streaming IO doesn't put any
memory pressure on the system.

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
