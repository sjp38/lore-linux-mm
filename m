Date: Fri, 28 Mar 2003 11:45:10 +0100 (CET)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.5.66-mm1
In-Reply-To: <20030327205912.753c6d53.akpm@digeo.com>
Message-ID: <Pine.LNX.4.44.0303281139500.6678-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Ed Tomlinson <tomlins@cam.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Galbraith <efault@gmx.de>
List-ID: <linux-mm.kvack.org>

On Thu, 27 Mar 2003, Andrew Morton wrote:

> That longer Code: line is really handy.
> 
> You died in schedule()->deactivate_task()->dequeue_task().
> 
> static inline void dequeue_task(struct task_struct *p, prio_array_t *array)
> {
> 	array->nr_active--;
> 
> `array' is zero.
> 
> I'm going to Cc Ingo and run away.  Ed uses preempt.

hm, this is an 'impossible' scenario from the scheduler code POV. Whenever
we deactivate a task, we remove it from the runqueue and set p->array to
NULL. Whenever we activate a task again, we set p->array to non-NULL. A
double-deactivate is not possible. I tried to reproduce it with various
scheduler workloads, but didnt succeed.

Mike, do you have a backtrace of the crash you saw?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
