Message-Id: <3.0.6.32.20030124212935.007fcc10@boo.net>
Date: Fri, 24 Jan 2003 21:29:35 -0500
From: Jason Papadopoulos <jasonp@boo.net>
Subject: Re: your mail
In-Reply-To: <csl13vsmj20pfasoh5v4mmv5mv3chqm53m@4ax.com>
References: <Pine.LNX.4.44.0301232104440.10187-100000@dlang.diginsite.com>
 <40475.210.212.228.78.1043384883.webmail@mail.nitc.ac.in>
 <Pine.LNX.4.44.0301232104440.10187-100000@dlang.diginsite.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At 10:06 PM 1/23/03 -0800, John Alvord wrote:

>The big challenge in Linux is that several serious attempts to add
>page coloring have foundered on the shoals of "no benefit found". It
>may be that the typical hardware Linux runs on just doesn't experience
>the problem very much.

Another strike against page coloring is that it gives tremendous benefits
when caches are large and not very associative, but if both of these are
not present the benefits are much smaller. In the case of latter-day PCs,
neither of these is the case: the caches are very small and at least 8-way
set associative.

For the record, I finally got to try my own page coloring patch on a 1GHz
Athlon Thunderbird system with 256kB L2 cache. With the present patch, my
own number crunching benchmarks and a kernel compile don't show any benefit 
at all, and lmbench is completely unchanged except for the mmap latency, 
which is slightly worse. Hardly a compelling case for PCs!

Oh well. At least now I'll be able to port to 2.5 :)

jasonp
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
