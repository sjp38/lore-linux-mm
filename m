Date: Sat, 06 Jul 2002 22:16:19 -0700
From: "Martin J. Bligh" <fletch@aracnet.com>
Subject: Re: vm lock contention reduction
Message-ID: <1044858948.1025993779@[10.10.2.3]>
In-Reply-To: <Pine.LNX.4.44.0207061949240.1558-100000@home.transmeta.com>
References: <Pine.LNX.4.44.0207061949240.1558-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> I'd like to enhance the profiling support a bit, to create some
> infrastructure for doing different kinds of profiles, not just 
> the current timer-based one (and not just for the kernel).
> 
> There's also the P4 native support for "event buffers" or whatever intel
> calls them, that allows profiling at a lower level by interrupting not for
> every event, but only when the hw buffer overflows.

kernprof is capable of monitoring the CPU's stats gathering 
counters I believe. The following is thanks to Mala Anand,
and I think she was monitoring the cacheline misses like this,
though the mechanism allows access to various things, I can't
remember if there's a TLB hit rate counter of the top of my
head ...

M.

-------------------------

The following script is what I used to collect performance counter
profiling data using kernprof:

sleep 5
kernprof -r -a 0xc0 -d pmc -f 1000 -t pc -b
sleep 30
kernprof -e -i -m /usr/src/linux/System.map > kpg.out
sort -nr +2 kpg.out > kpg26sort.out
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
