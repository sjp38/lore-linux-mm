Date: Tue, 15 Aug 2000 11:08:28 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [prePATCH] new VM for linux-2.4.0-test4
In-Reply-To: <Pine.Linu.4.10.10008151344170.1404-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.21.0008151106220.10491-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@weiden.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, 15 Aug 2000, Mike Galbraith wrote:
> On Mon, 14 Aug 2000, Rik van Riel wrote:
> 
> > OK, I overlooked one of the bad bad bad mistakes watashi 
> > saw .. here is an -incremental- patch to fix the last
> > possible source of memory leakage...
> 
> I put vm6 and this bugfix into test7-pre4.ikd, checked for leakage
> with memleak.. found absolutely nothing.

The patch I posted yesterday (and at my website) does not
leak any memory.

http://www.surriel.com/patches/2.4.0-t4-vmpatch

> I then disabled ikd and did some light performance comparison using
> my favorite generic test (make -j30 bzImage [1]).  Tests conducted in
> identical as possible manner compiling the same tree.

[snip]

> Definite improvement over stock vm, but still not as good at keeping
> 30 hungry tasks fed as classzone (on my 128mb single PIII box).  All
> numbers fully repeatable +- normal test jitter.
> 
> Streaming I/O seems to be suffering a bit, but I didn't measure enough
> to be 100% sure of that.

Well, my new VM patch is still completely untuned. I'm sure
we could improve things quite a bit by carefully tuning the
patch a bit ;)

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
