From: David Lang <david.lang@digitalinsight.com>
Date: Thu, 23 Jan 2003 22:28:40 -0800 (PST)
Subject: Re: your mail
In-Reply-To: <42636.210.212.228.78.1043387664.webmail@mail.nitc.ac.in>
Message-ID: <Pine.LNX.4.44.0301232225030.10187-100000@dlang.diginsite.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Anoop J." <cs99001@nitc.ac.in>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

implementing a fully associative cache eliminates the need for page
coloring, but it has to be implemented in hardware. if you don't have
fully associative caches in your hardware page coloring helps avoid the
worst case memory allocations.

from what I have seen on the attempts to implement it the problem is that
the calculations needed to do page colored allocations end up costing
enough that they end up with a net loss compared to the old method.

David Lang


 On Fri, 24 Jan 2003, Anoop J.
wrote:

> Date: Fri, 24 Jan 2003 11:24:24 +0530 (IST)
> From: Anoop J. <cs99001@nitc.ac.in>
> To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
>
>
> How is this different from a fully associative cache .Would be better if u
> could deal it based on the address bits used
>
> Thanks
>
> David Lang wrote:
>
> >The idea of page coloring is based on the fact that common implementations
> >of caching can't put any page in memory in any line in the cache (such an
> >implementation is possible, but is more expensive to do so is not commonly
> >done)
> >
> >With this implementation it means that if your program happens to use
> >memory that cannot be mapped to half of the cache lines then effectivly
> >the CPU cache is half it's rated size for your program. the next time your
> >program runs it may get a more favorable memory allocation and be able to
> >use all of the cache and therefor run faster.
> >
> >Page coloring is an attampt to take this into account when allocating
> >memory to programs so that every program gets to use all of the cache.
> >
> >David Lang
> >
> >
> > On Fri, 24 Jan 2003, Anoop J. wrote:
> >
> >>Date: Fri, 24 Jan 2003 10:38:03 +0530 (IST)
> >>From: Anoop J. <cs99001@nitc.ac.in>
> >>To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
> >>
> >>
> >>How does page coloring work. Iwant its mechanism not the implementation.
> >>I went through some pages of W.L.Lynch's paper on cache and VM. Still not
> >>able to grasp it .
> >>
> >>
> >>Thanks in advance
> >>
> >>
> >>
> >>-
> >>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> >>the body of a message to majordomo@vger.kernel.org
> >>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>Please read the FAQ at  http://www.tux.org/lkml/
> >>
> >
>
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
