Subject: Re: kswapd eating too much CPU on ac16/ac18
References: <Pine.LNX.4.21.0006171227230.31955-100000@duckman.distro.conectiva>
From: Goswin Brederlow <goswin.brederlow@student.uni-tuebingen.de>
Date: 19 Jun 2000 23:22:58 +0200
In-Reply-To: Rik van Riel's message of "Sat, 17 Jun 2000 12:33:52 -0300 (BRST)"
Message-ID: <877lbl8ix9.fsf@mose.informatik.uni-tuebingen.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Cesar Eduardo Barros <cesarb@nitnet.com.br>, Mike Galbraith <mikeg@weiden.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> " " == Rik van Riel <riel@conectiva.com.br> writes:

     > I think the phenomenon you're seeing is not at all related to
     > deferred/non-deferred swapout. That doesn't have anything to do
     > with kswapd CPU usage.

     > The changed feedback loop in do_try_to_free_pages, however may
     > have something to do with this. It works well on machines with
     > more than 1 memory zone, but I can envision it breaking on
     > machines with just one zone...

     > I'm thinking of a way to fix this cleanly, I'll keep you
     > posted.

I have two boxes with 2.4.0-test1 kernels:

First one a Celeron 466 with 128 Mb ram:
BIOS-provided physical RAM map:
 e820: 000000000009f000 @ 0000000000000000 (usable)
 e820: 0000000007f00000 @ 0000000000100000 (usable)
On node 0 totalpages: 32768
zone(0): 4096 pages.
zone(1): 28672 pages.
zone(2): 0 pages.

Second one a P120 with 16 MB ram (probably in one zone, but its not in
reach at the moment).

On the Celeron 2.4.0-test1 runs fine (responsiveness is a bit low, but
kswapd useage is fine).

On the P120 kswapd needs 95-99% cpu time. and the system is realy
realy slow. I teste plain 2.4.0-test1 to 2.2.4-test1-ac19 with various
steps inbetween. The disk behaviour (how often the ide led blinks)
differs and the amount swap used is different, but the kswap allways
uses all cpu time.

This could realy be a "number of zones" problem, so pleas thing about
it.

MfG
	Goswin

PS: I will add a zone mapping for the P120 when I get to it next time.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
