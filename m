Message-Id: <5.2.0.9.2.20030328152305.019b3e70@pop.gmx.net>
Date: Fri, 28 Mar 2003 15:26:52 +0100
From: Mike Galbraith <efault@gmx.de>
Subject: Re: 2.5.66-mm1
In-Reply-To: <Pine.LNX.4.44.0303281139500.6678-100000@localhost.localdom
 ain>
References: <20030327205912.753c6d53.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@digeo.com>, Ed Tomlinson <tomlins@cam.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At 11:45 AM 3/28/2003 +0100, Ingo Molnar wrote:

>On Thu, 27 Mar 2003, Andrew Morton wrote:
>
> > That longer Code: line is really handy.
> >
> > You died in schedule()->deactivate_task()->dequeue_task().
> >
> > static inline void dequeue_task(struct task_struct *p, prio_array_t *array)
> > {
> >       array->nr_active--;
> >
> > `array' is zero.
> >
> > I'm going to Cc Ingo and run away.  Ed uses preempt.
>
>hm, this is an 'impossible' scenario from the scheduler code POV. Whenever
>we deactivate a task, we remove it from the runqueue and set p->array to
>NULL. Whenever we activate a task again, we set p->array to non-NULL. A
>double-deactivate is not possible. I tried to reproduce it with various
>scheduler workloads, but didnt succeed.
>
>Mike, do you have a backtrace of the crash you saw?

No, I didn't save it due to "grubby fingerprints".

         -Mike 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
