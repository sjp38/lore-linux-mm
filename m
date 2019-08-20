Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA6FFC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 20:24:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5310B22DA7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 20:24:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="YzDGv4XO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5310B22DA7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F07BD6B0008; Tue, 20 Aug 2019 16:24:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB9026B000A; Tue, 20 Aug 2019 16:24:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D801E6B000C; Tue, 20 Aug 2019 16:24:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0104.hostedemail.com [216.40.44.104])
	by kanga.kvack.org (Postfix) with ESMTP id B84516B0008
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:24:46 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 2284C181AC9BF
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 20:24:46 +0000 (UTC)
X-FDA: 75843934572.07.cake73_63bb2539aa458
X-HE-Tag: cake73_63bb2539aa458
X-Filterd-Recvd-Size: 13259
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 20:24:45 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id f22so208291edt.4
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:24:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=sender:date:from:to:cc:subject:message-id:mail-followup-to
         :references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=d25H8YaXES8D8CXayg5AzS13dfnA0p+MfNTE8L9U9Pc=;
        b=YzDGv4XO+LwpyyKcJI0OU4N7t8BLXha4wn/3Sv43YldWD0xf7aP4v1aM765ctgROdP
         5UA0BFANzBJ3/MHYWKBlOTznKQv2McTtf3hst+NBYha3BQ90MgzDB3fWcZM3+t+/3EGL
         BFNdbUFgnpW9sVM7H/mvhP33Ibzw3ijkNfE0g=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :mail-followup-to:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=d25H8YaXES8D8CXayg5AzS13dfnA0p+MfNTE8L9U9Pc=;
        b=YVOVz4GxX9whYaul5GtjAUHtbHsDmOcvui4QatEPdoPToRYexCQJssqczHdfUAiS34
         DFW/4P01GvE/CSYkbfY5N94Bf7nBvmNdkd2WcKtoiHzZfzELCh9aZm4bsYUNfEYNv9eb
         WsxQjJNuAZxkeAH4ctHeh6/ATlehO+VPsNToJzyyOgvIWvdnx+MGnUIX1uOhhOM/Trvp
         oF9yYVgnxDyg8F4lMEf3QRW2+yLlAWXJC7W8Utafk3Idx922gf4uXjq83P5mI69kbOVY
         1D4xqrntDg71Vn1Cll1Zh17ajjcvvj2PfSWP7qs/o3OMqqrqsmFjYx9DUGYUuWULGuMm
         h/9A==
X-Gm-Message-State: APjAAAXU7rM1/0ktAiXbesRkmuub9yutvqodxQQAVcTrCCESRAeYLWgy
	82Tt8Pm5U8ceO9CsSApI5Qv3cw==
X-Google-Smtp-Source: APXvYqwUbw6adOmUx3fV3Lgun+uXklVCorSduFcswvtjlqc3XkLgvXDCsmhN8i5RTx8u9b4ccpZ5mw==
X-Received: by 2002:a17:907:390:: with SMTP id ss16mr27164544ejb.46.1566332683690;
        Tue, 20 Aug 2019 13:24:43 -0700 (PDT)
Received: from phenom.ffwll.local (212-51-149-96.fiber7.init7.net. [212.51.149.96])
        by smtp.gmail.com with ESMTPSA id gw11sm2770562ejb.29.2019.08.20.13.24.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Aug 2019 13:24:42 -0700 (PDT)
Date: Tue, 20 Aug 2019 22:24:40 +0200
From: Daniel Vetter <daniel@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 3/4] kernel.h: Add non_block_start/end()
Message-ID: <20190820202440.GH11147@phenom.ffwll.local>
Mail-Followup-To: LKML <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-4-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190820081902.24815-4-daniel.vetter@ffwll.ch>
X-Operating-System: Linux phenom 5.2.0-2-amd64 
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 10:19:01AM +0200, Daniel Vetter wrote:
> In some special cases we must not block, but there's not a
> spinlock, preempt-off, irqs-off or similar critical section already
> that arms the might_sleep() debug checks. Add a non_block_start/end()
> pair to annotate these.
>=20
> This will be used in the oom paths of mmu-notifiers, where blocking is
> not allowed to make sure there's forward progress. Quoting Michal:
>=20
> "The notifier is called from quite a restricted context - oom_reaper -
> which shouldn't depend on any locks or sleepable conditionals. The code
> should be swift as well but we mostly do care about it to make a forwar=
d
> progress. Checking for sleepable context is the best thing we could com=
e
> up with that would describe these demands at least partially."
>=20
> Peter also asked whether we want to catch spinlocks on top, but Michal
> said those are less of a problem because spinlocks can't have an
> indirect dependency upon the page allocator and hence close the loop
> with the oom reaper.
>=20
> Suggested by Michal Hocko.
>=20
> v2:
> - Improve commit message (Michal)
> - Also check in schedule, not just might_sleep (Peter)
>=20
> v3: It works better when I actually squash in the fixup I had lying
> around :-/
>=20
> v4: Pick the suggestion from Andrew Morton to give non_block_start/end
> some good kerneldoc comments. I added that other blocking calls like
> wait_event pose similar issues, since that's the other example we
> discussed.
>=20
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: "Christian K=F6nig" <christian.koenig@amd.com>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Wei Wang <wvw@google.com>
> Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Jann Horn <jannh@google.com>
> Cc: Feng Tang <feng.tang@intel.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: linux-kernel@vger.kernel.org
> Acked-by: Christian K=F6nig <christian.koenig@amd.com> (v1)
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>

Hi Peter,

Iirc you've been involved at least somewhat in discussing this. -mm folks
are a bit undecided whether these new non_block semantics are a good idea=
.
Michal Hocko still is in support, but Andrew Morton and Jason Gunthorpe
are less enthusiastic. Jason said he's ok with merging the hmm side of
this if scheduler folks ack. If not, then I'll respin with the
preempt_disable/enable instead like in v1.

So ack/nack for this from the scheduler side?

Thanks, Daniel

> ---
>  include/linux/kernel.h | 25 ++++++++++++++++++++++++-
>  include/linux/sched.h  |  4 ++++
>  kernel/sched/core.c    | 19 ++++++++++++++-----
>  3 files changed, 42 insertions(+), 6 deletions(-)
>=20
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index 4fa360a13c1e..82f84cfe372f 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -217,7 +217,9 @@ extern void __cant_sleep(const char *file, int line=
, int preempt_offset);
>   * might_sleep - annotation for functions that can sleep
>   *
>   * this macro will print a stack trace if it is executed in an atomic
> - * context (spinlock, irq-handler, ...).
> + * context (spinlock, irq-handler, ...). Additional sections where blo=
cking is
> + * not allowed can be annotated with non_block_start() and non_block_e=
nd()
> + * pairs.
>   *
>   * This is a useful debugging help to be able to catch problems early =
and not
>   * be bitten later when the calling function happens to sleep when it =
is not
> @@ -233,6 +235,25 @@ extern void __cant_sleep(const char *file, int lin=
e, int preempt_offset);
>  # define cant_sleep() \
>  	do { __cant_sleep(__FILE__, __LINE__, 0); } while (0)
>  # define sched_annotate_sleep()	(current->task_state_change =3D 0)
> +/**
> + * non_block_start - annotate the start of section where sleeping is p=
rohibited
> + *
> + * This is on behalf of the oom reaper, specifically when it is callin=
g the mmu
> + * notifiers. The problem is that if the notifier were to block on, fo=
r example,
> + * mutex_lock() and if the process which holds that mutex were to perf=
orm a
> + * sleeping memory allocation, the oom reaper is now blocked on comple=
tion of
> + * that memory allocation. Other blocking calls like wait_event() pose=
 similar
> + * issues.
> + */
> +# define non_block_start() \
> +	do { current->non_block_count++; } while (0)
> +/**
> + * non_block_end - annotate the end of section where sleeping is prohi=
bited
> + *
> + * Closes a section opened by non_block_start().
> + */
> +# define non_block_end() \
> +	do { WARN_ON(current->non_block_count-- =3D=3D 0); } while (0)
>  #else
>    static inline void ___might_sleep(const char *file, int line,
>  				   int preempt_offset) { }
> @@ -241,6 +262,8 @@ extern void __cant_sleep(const char *file, int line=
, int preempt_offset);
>  # define might_sleep() do { might_resched(); } while (0)
>  # define cant_sleep() do { } while (0)
>  # define sched_annotate_sleep() do { } while (0)
> +# define non_block_start() do { } while (0)
> +# define non_block_end() do { } while (0)
>  #endif
> =20
>  #define might_sleep_if(cond) do { if (cond) might_sleep(); } while (0)
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 9f51932bd543..c5630f3dca1f 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -974,6 +974,10 @@ struct task_struct {
>  	struct mutex_waiter		*blocked_on;
>  #endif
> =20
> +#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
> +	int				non_block_count;
> +#endif
> +
>  #ifdef CONFIG_TRACE_IRQFLAGS
>  	unsigned int			irq_events;
>  	unsigned long			hardirq_enable_ip;
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 2b037f195473..57245770d6cc 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -3700,13 +3700,22 @@ static noinline void __schedule_bug(struct task=
_struct *prev)
>  /*
>   * Various schedule()-time debugging checks and statistics:
>   */
> -static inline void schedule_debug(struct task_struct *prev)
> +static inline void schedule_debug(struct task_struct *prev, bool preem=
pt)
>  {
>  #ifdef CONFIG_SCHED_STACK_END_CHECK
>  	if (task_stack_end_corrupted(prev))
>  		panic("corrupted stack end detected inside scheduler\n");
>  #endif
> =20
> +#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
> +	if (!preempt && prev->state && prev->non_block_count) {
> +		printk(KERN_ERR "BUG: scheduling in a non-blocking section: %s/%d/%i=
\n",
> +			prev->comm, prev->pid, prev->non_block_count);
> +		dump_stack();
> +		add_taint(TAINT_WARN, LOCKDEP_STILL_OK);
> +	}
> +#endif
> +
>  	if (unlikely(in_atomic_preempt_off())) {
>  		__schedule_bug(prev);
>  		preempt_count_set(PREEMPT_DISABLED);
> @@ -3813,7 +3822,7 @@ static void __sched notrace __schedule(bool preem=
pt)
>  	rq =3D cpu_rq(cpu);
>  	prev =3D rq->curr;
> =20
> -	schedule_debug(prev);
> +	schedule_debug(prev, preempt);
> =20
>  	if (sched_feat(HRTICK))
>  		hrtick_clear(rq);
> @@ -6570,7 +6579,7 @@ void ___might_sleep(const char *file, int line, i=
nt preempt_offset)
>  	rcu_sleep_check();
> =20
>  	if ((preempt_count_equals(preempt_offset) && !irqs_disabled() &&
> -	     !is_idle_task(current)) ||
> +	     !is_idle_task(current) && !current->non_block_count) ||
>  	    system_state =3D=3D SYSTEM_BOOTING || system_state > SYSTEM_RUNNI=
NG ||
>  	    oops_in_progress)
>  		return;
> @@ -6586,8 +6595,8 @@ void ___might_sleep(const char *file, int line, i=
nt preempt_offset)
>  		"BUG: sleeping function called from invalid context at %s:%d\n",
>  			file, line);
>  	printk(KERN_ERR
> -		"in_atomic(): %d, irqs_disabled(): %d, pid: %d, name: %s\n",
> -			in_atomic(), irqs_disabled(),
> +		"in_atomic(): %d, irqs_disabled(): %d, non_block: %d, pid: %d, name:=
 %s\n",
> +			in_atomic(), irqs_disabled(), current->non_block_count,
>  			current->pid, current->comm);
> =20
>  	if (task_stack_end_corrupted(current))
> --=20
> 2.23.0.rc1
>=20

--=20
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

