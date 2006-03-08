Date: Tue, 7 Mar 2006 16:05:15 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mm: yield during swap prefetching
Message-Id: <20060307160515.0feba529.akpm@osdl.org>
In-Reply-To: <cone.1141774323.5234.18683.501@kolivas.org>
References: <200603081013.44678.kernel@kolivas.org>
	<20060307152636.1324a5b5.akpm@osdl.org>
	<cone.1141774323.5234.18683.501@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

Con Kolivas <kernel@kolivas.org> wrote:
>
> > yield() really sucks if there are a lot of runnable tasks.  And the amount
> > of CPU which that thread uses isn't likely to matter anyway.
> > 
> > I think it'd be better to just not do this.  Perhaps alter the thread's
> > static priority instead?  Does the scheduler have a knob which can be used
> > to disable a tasks's dynamic priority boost heuristic?
> 
> We do have SCHED_BATCH but even that doesn't really have the desired effect. 
> I know how much yield sucks and I actually want it to suck as much as yield 
> does.

Why do you want that?

If prefetch is doing its job then it will save the machine from a pile of
major faults in the near future.  The fact that the machine happens to be
running a number of busy tasks doesn't alter that.  It's _worth_ stealing a
few cycles from those tasks now to avoid lengthy D-state sleeps in the near
future?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
