Date: Thu, 4 Jul 2002 15:49:35 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Benchmarking Tool
In-Reply-To: <20020703060446.GA2560@SandStorm.net>
Message-ID: <Pine.LNX.4.44L.0207041540400.6047-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Abhishek Nayani <abhi@kernelnewbies.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jul 2002, Abhishek Nayani wrote:

> the matter. I would like to know what is missing in the current set of
> tools (lmbench, dbench..) and what is required.

Most of the current "VM tests" don't seem to have anything
like a working set.  This basically means that one of the
central and important parts of the VM - page replacement -
isn't getting tested AT ALL.

It might be interesting to have some "working set emulator"
where a program accesses N out of M MB of total memory a
lot and the rest a little, where N, M and the ratio between
the accesses are varied in such a way that the system is
confronted with various sizes of workload.

Of course, you could also go into multitasking such programs ;)

The way to display the result of this could be a graph, showing
the working set size on the X axis and the program "speed" on
the Y axis. It might also be useful to express the size of the
working set as a percentage of main memory.

This way you could show "VM X" runs well until the working set
reaches 50% of RAM size, while "VM Y" runs well until the working
set size reaches 70% of RAM.

This is just one example of things we could do, I'm sure there
are many more aspects of the VM subsystem for which we don't
have any benchmarks yet.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
