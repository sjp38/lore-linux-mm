Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 544276B01EF
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 11:44:59 -0400 (EDT)
Message-ID: <4BC1EE13.7080702@redhat.com>
Date: Sun, 11 Apr 2010 18:43:15 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: hugepages will matter more in the future
References: <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <4BC0E2C4.8090101@redhat.com> <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com> <4BC0E556.30304@redhat.com> <4BC19663.8080001@redhat.com> <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com> <4BC19916.20100@redhat.com> <20100411110015.GA10149@elte.hu> <4BC1B034.4050302@redhat.com> <20100411115229.GB10952@elte.hu> <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

On 04/11/2010 06:22 PM, Linus Torvalds wrote:
>
> On Sun, 11 Apr 2010, Ingo Molnar wrote:
>    
>> Both Xorg, xterms and firefox have rather huge RSS's on my boxes. (Even a
>> phone these days easily has more than 512 MB RAM.) Andrea measured
>> multi-percent improvement in gcc performance. I think it's real.
>>      
> Reality check: he got multiple percent with
>
>   - one huge badly written file being compiled that took 22s because it's
>     such a horrible monster.
>    

Not everything is a kernel build.  Template heavy C++ code will also 
allocate tons of memory.  gcc -flto will also want lots of memory.

>   - magic libc malloc flags tghat are totally and utterly unrealistic in
>     anything but a benchmark
>    

Having glibc allocate in chunks of 2MB instead of 1MB is not 
unrealistic.  I agree about MMAP_THRESHOLD.

>   - by basically keeping one CPU totally busy doing defragmentation.
>    

I never saw khugepaged take any significant amount of cpu.

> Quite frankly, that kind of "performance analysis" makes me _less_
> interested rather than more. Because all it shows is that you're willing
> to do anything at all to get better numbers, regardless of whether it is
> _realistic_ or not.
>
> Seriously, guys.  Get a grip. If you start talking about special malloc
> algorithms, you have ALREADY LOST. Google for memory fragmentation with
> various malloc implementations in multi-threaded applications. Thinking
> that you can just allocate in 2MB chunks is so _fundamnetally_ broken that
> this whole thread should have been laughed out of the room.
>    

And yet Oracle and java have options to use large pages, and we know 
google and HPC like 'em.  Maybe they just haven't noticed the 
fundamental brokenness yet.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
