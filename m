Message-ID: <39DBA38F.B2607361@sgi.com>
Date: Wed, 04 Oct 2000 14:39:27 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Odd swap behavior
References: <Pine.LNX.4.21.0010041212540.10197-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Tue, 3 Oct 2000, Rajagopal Ananthanarayanan wrote:
> 
> > I'm running fairly stressful tests like dbench with lots of
> > clients. Since the new VM changes (now in test9), I haven't
> > noticed _any_ swap activity, in spite of the enormous memory
> > pressures. I have lots of processes in the system, like 8
> > httpd's, 4 getty's, etc. most of which should be "idle" ... Why
> > aren't the pages (eg. mapped stacks) from these processes being
> > swapped out?
> 
> That's an interesting one. Most "complaints" I've had about
> test9 is that it swaps more than previous versions ;)
> 
> But let me give you the answer...
> 
> Small code changes in deactivate_page() have caused the
> drop_behind() code to actually WORK AS ADVERTISED right
> now, and because of that streaming IO doesn't put any
> memory pressure on the system.


Agreed. And since the introduction of drop_behind &
the deactivate_page() in generic_file_write, streaming I/O
performance has become pretty good.

However, in the above I was particularly talking about
swap behaviour on running dbench. Dbench is write intensive,
and also has fair amount of re-writes. So, the I'm not
sure why we still do not swap out _really_ old processes.

If old pages are not swapped out, then dbench itself
will get less than optimal amount of the page-cache during
its run. I believe this is one of the reasons for
dbench's poor showing with the new VM.


--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
