Message-ID: <3D3F56C6.B045E8A@mvista.com>
Date: Wed, 24 Jul 2002 18:39:18 -0700
From: george anzinger <george@mvista.com>
MIME-Version: 1.0
Subject: Re: [PATCH] updated low-latency zap_page_range
References: <Pine.LNX.4.44.0207241820170.5944-100000@home.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Robert Love <rml@tech9.net>, Andrew Morton <akpm@zip.com.au>, riel@conectiva.com.br, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On 24 Jul 2002, Robert Love wrote:
> >
> >       if (preempt_count() == 1 && need_resched())
> >
> > Then we get "if (0 && ..)" which should hopefully be evaluated away.
> 
> I think preempt_count() is not unconditionally 0 for non-preemptible
> kernels, so I don't think this is a compile-time constant.
> 
> That may be a bug in preempt_count(), of course.
> 
Didn't we just put bh_count and irq_count in the same
word???
-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
