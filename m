Date: Mon, 23 Jun 2008 23:01:29 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [BUG][PATCH -mm] avoid BUG() in __stop_machine_run()
Message-ID: <20080623210129.GB16579@elte.hu>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org> <485A806A.2090602@goop.org> <20080620132110.GB19740@elte.hu> <200806231355.39329.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200806231355.39329.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, sugita <yumiko.sugita.yf@hitachi.com>, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
List-ID: <linux-mm.kvack.org>

* Rusty Russell <rusty@rustcorp.com.au> wrote:

> On Friday 20 June 2008 23:21:10 Ingo Molnar wrote:
> > * Jeremy Fitzhardinge <jeremy@goop.org> wrote:
[...]
> > > (With the appropriate transformation of sched_setscheduler -> __)
> > >
> > > Better than scattering stray true/falses around the code.
> >
> > agreed - it would also be less intrusive on the API change side.
> 
> Yes, here's the patch.  I've put it in my tree for testing, too.
> 
> sched_setscheduler_nocheck: add a flag to control access checks

applied to tip/sched/new-API-sched_setscheduler, thanks Rusty. Also 
added it to auto-sched-next so that it shows up in linux-next.

btw., had to merge this bit manually:

> +/**
> + * sched_setscheduler_nocheck - change the scheduling policy and/or RT priority of a thread 
> from kernelspace.
> + * @p: the task in question.

as it suffered from line-warp damage.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
