Date: Fri, 20 Jun 2008 15:21:10 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [BUG][PATCH -mm] avoid BUG() in __stop_machine_run()
Message-ID: <20080620132110.GB19740@elte.hu>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org> <485A03E6.2090509@hitachi.com> <200806192012.44459.rusty@rustcorp.com.au> <485A806A.2090602@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <485A806A.2090602@goop.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, sugita <yumiko.sugita.yf@hitachi.com>, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
List-ID: <linux-mm.kvack.org>

* Jeremy Fitzhardinge <jeremy@goop.org> wrote:

>> This simply introduces a flag to allow us to disable the capability 
>> checks for internal callers (this is simpler than splitting the 
>> sched_setscheduler() function, since it loops checking permissions).
>>   
> What about?
>
> int sched_setscheduler(struct task_struct *p, int policy,
> 		       struct sched_param *param)
> {
> 	return __sched_setscheduler(p, policy, param, true);
> }
>
>
> int sched_setscheduler_nocheck(struct task_struct *p, int policy,
> 		               struct sched_param *param)
> {
> 	return __sched_setscheduler(p, policy, param, false);
> }
>
>
> (With the appropriate transformation of sched_setscheduler -> __)
>
> Better than scattering stray true/falses around the code.

agreed - it would also be less intrusive on the API change side.

i've created a new tip/sched/new-API-sched_setscheduler topic for this 
to track it, but it would be nice to have a v2 of this patch that 
introduces the new API the way suggested by Jeremy. (Hence the new topic 
is auto-merged into tip/master but not into linux-next yet.) Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
