Message-ID: <3D2CBE6A.53A720A0@zip.com.au>
Date: Wed, 10 Jul 2002 16:08:26 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
References: <3D2BC6DB.B60E010D@zip.com.au> <91460000.1026341000@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> > Here's the diff.  The kmap() and kmap_atomic() rate is way down
> > now.  Still no benefit from it all through.  Martin.  Help.
> 
> Hmmm ... well I have some preliminary results on the 16-way NUMA
> for kernel compile, and it doesn't make things faster - if anything there's
> a barely perceptible slowdown (may just be statistical error).
> 
> On the other hand, Hanna just did some dbench measurements on an
> 8-way SMP, and got about 15% improvement out of it (she mailed the
> results to lkml just now).

Yes, thanks.  Still scratching my head over that lot.

> The profile comparison between 2.4 and 2.5 is interesting. Unless I've
> screwed something up in the profiling, seems like we're spending a lot
> of time in do_page_fault (with or without your patch). It's *so* different,
> that I'm inclined to suspect my profiling .... (profile=2).

Yes, I've seen the in-kernel profiler doing odd things.  If 
you're not using the local APIC timer then I think the new
IRQ balancing code will break the profiler by steering the
clock interrupts away from busy CPUs (!).

But ISTR that the profiler has gone whacky even with CONFIG_X86_LOCAL_APIC,
which shouldn't be affected by the IRQ steering.

But NMI-based oprofile is bang-on target so I recommend you use that.
I'll publish my oprofile-for-2.5 asap.


-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
