From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Date: Mon, 23 Apr 2001 06:55:23 +0100
Message-ID: <eng7eto17h5k5s32ued74vt988bhb4eiml@4ax.com>
References: <2ch6etcc6mvtt83g45gu5dta6ftp8kudoe@4ax.com> <Pine.LNX.4.21.0104221826000.1685-100000@imladris.rielhome.conectiva> <l03130317b70908428b4b@[192.168.239.105]>
In-Reply-To: <l03130317b70908428b4b@[192.168.239.105]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Rik van Riel <riel@conectiva.com.br>, "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 22 Apr 2001 23:26:37 +0100, you wrote:

>>> We've crossed wires here: I know that's how the suspension approach
>>> works, I'm talking about the "working set" approach - which to me,
>>> sounds more likely to give both processes 50Mb each, and spend the
>>> next six weeks grinding the disks to powder!
>>
>>Indeed, in this case the working set approach won't work.
>
>Going back to my description of my algorithm from a few days ago, it
>selects *one* process at a time to penalise.  If processes are not
>re-ordered and remain with the same-sized working set, it will ensure that
>one of the large processes remains fully resident and runs to completion

"remains"? Neither process was able to get 100Mb of RAM; one got 75Mb,
the other got 25Mb. They are both now thrashing, and will continue
until the disks melt.

If you "penalise" one process, you are effectively suspending it - but
in a way that wastes CPU time and I/O bandwidth. Why bother?

>(as I described).  Thus the period in which the disks get churned is quite
>short.  When combined with suspension, the intensity of disk activity would
>also be reduced.
>
>Of course, if the working set of the swapped-out process decreases (as a
>result of being swapped out and/or suspended), it will eventually come off
>the penalised list and replace the resident one.  It is important to keep
>the period over which the working set is calculated fairly long, to
>minimise the frequency of oscillations resulting from this effect.  My
>algorithm takes this into account as well, with the period being
>approximately 5.5 minutes on 100Hz hardware.
>
>If further processes come in, increasing the working set further beyond the
>system limits, my algorithm selects another *single* process at a time to
>add to the penalised list.  This ensures that at any time, the maximum
>amount of physical memory is utilised by processes which are not subject to
>suspension or thrashing.

Your "penalised" processes are thrashing anyway. They might as well be
suspended, freeing up system resources which are otherwise wasted.

>Now, I suspect you guys have been thinking "hey, he's going to give
>processes memory *proportionate* to their working sets, which doesn't
>work!" - well, I realised early on it wasn't going to work that way.  :)

You seem to be creeping subtly towards process suspension :)


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
