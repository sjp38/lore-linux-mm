Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA06441
	for <linux-mm@kvack.org>; Sun, 6 Oct 2002 15:33:27 -0700 (PDT)
Message-ID: <3DA0BA33.5B295A46@digeo.com>
Date: Sun, 06 Oct 2002 15:33:23 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.40-mm2
References: <3DA0B422.C23B23D4@digeo.com> <1033943021.27093.29.camel@phantasy>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Dave Hansen <haveblue@us.ibm.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

Robert Love wrote:
> 
> On Sun, 2002-10-06 at 18:07, Andrew Morton wrote:
> 
> > > -                       while (base->running_timer == timer) {
> > > +                       while (base->running_timer == timer)
> > >                                 cpu_relax();
> > > -                               preempt_disable();
> > > -                               preempt_enable();
> 
> I am confused as to why Ingo would put these here.  He knows very well
> what he is doing... surely he had a reason.
> 
> If he intended to force a preemption point here, then the lines needs to
> be reversed.  This assumes, of course, preemption is disabled here.  But
> I do not think it is.
> 
> If he just wanted to check for preemption, we have a
> preempt_check_resched() which does just that (I even think he wrote
> it).  Note as long as interrupts are enabled this probably does not
> achieve much anyhow.
> 

I think it's a way of doing "cond_resched() if cond_resched() is
a legal thing to do right now".

I'm sure David isn't using preempt though.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
