Date: Wed, 8 Mar 2006 23:24:04 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] mm: yield during swap prefetching
Message-ID: <20060308222404.GA4693@elf.ucw.cz>
References: <200603081013.44678.kernel@kolivas.org> <20060307152636.1324a5b5.akpm@osdl.org> <cone.1141774323.5234.18683.501@kolivas.org> <20060307160515.0feba529.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20060307160515.0feba529.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Con Kolivas <kernel@kolivas.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Ut 07-03-06 16:05:15, Andrew Morton wrote:
> Con Kolivas <kernel@kolivas.org> wrote:
> >
> > > yield() really sucks if there are a lot of runnable tasks.  And the amount
> > > of CPU which that thread uses isn't likely to matter anyway.
> > > 
> > > I think it'd be better to just not do this.  Perhaps alter the thread's
> > > static priority instead?  Does the scheduler have a knob which can be used
> > > to disable a tasks's dynamic priority boost heuristic?
> > 
> > We do have SCHED_BATCH but even that doesn't really have the desired effect. 
> > I know how much yield sucks and I actually want it to suck as much as yield 
> > does.
> 
> Why do you want that?
> 
> If prefetch is doing its job then it will save the machine from a pile of
> major faults in the near future.  The fact that the machine happens

Or maybe not.... it is prefetch, it may prefetch wrongly, and you
definitely want it doing nothing when system is loaded.... It only
makes sense to prefetch when system is idle.
								Pavel
-- 
Web maintainer for suspend.sf.net (www.sf.net/projects/suspend) wanted...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
