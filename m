Message-ID: <440F9154.2080909@yahoo.com.au>
Date: Thu, 09 Mar 2006 13:22:12 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: yield during swap prefetching
References: <200603081013.44678.kernel@kolivas.org> <20060307152636.1324a5b5.akpm@osdl.org> <cone.1141774323.5234.18683.501@kolivas.org> <20060307160515.0feba529.akpm@osdl.org> <20060308222404.GA4693@elf.ucw.cz>
In-Reply-To: <20060308222404.GA4693@elf.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@osdl.org>, Con Kolivas <kernel@kolivas.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

Pavel Machek wrote:

>On Ut 07-03-06 16:05:15, Andrew Morton wrote:
>
>>Why do you want that?
>>
>>If prefetch is doing its job then it will save the machine from a pile of
>>major faults in the near future.  The fact that the machine happens
>>
>
>Or maybe not.... it is prefetch, it may prefetch wrongly, and you
>definitely want it doing nothing when system is loaded.... It only
>makes sense to prefetch when system is idle.
>

Right. Prefetching is obviously going to have a very low work/benefit,
assuming your page reclaim is working properly, because a) it doesn't
deal with file pages, and b) it is doing work to reclaim pages that
have already been deemed to be the least important.

What it is good for is working around our interesting VM that apparently
allows updatedb to swap everything out (although I haven't seen this
problem myself), and artificial memory hogs. By moving work to times of
low cost. No problem with the theory behind it.

So as much as a major fault costs in terms of performance, the tiny
chance that prefetching will avoid it means even the CPU usage is
questionable. Using sched_yield() seems like a hack though.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
