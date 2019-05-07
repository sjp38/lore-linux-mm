Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE7B8C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:35:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C1F72053B
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:35:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C1F72053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0CA36B0005; Tue,  7 May 2019 12:35:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC00D6B0006; Tue,  7 May 2019 12:35:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5DB76B0007; Tue,  7 May 2019 12:35:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 730126B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 12:35:28 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id q15so9489922otl.8
        for <linux-mm@kvack.org>; Tue, 07 May 2019 09:35:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uaftBA0UoN/VSNTOzbOYMh9Vy7eqJmh/fNyQY1SouuI=;
        b=BRtvEs36qWwQJi6ZIHpxsaNZzwEURdOO9a+4Z9vm26f+7ubHx/oanS09mAVkZZMSPW
         Kq7i5OwZJkxR6zKjogEuhhzMLriX5V1JxwqzBjdII6UjA0/F+8JIkJa3G6xhQNDBhxSX
         +o2GgEe4pW5gHOVazu+DPduZBOn6z1BjMROE6qiqIaEncs+24/E3eVdSOE7/lbD4smUv
         OeJm2kjnxfVTiGOCzwUCZ6DDckDtgvVmubB1lSh2gV5pw9sll3jiblNFZooUwv1moPZh
         ClK3jymC/Ti6Vne2qp2+NxHjJ7K07CwrFEZuM/2Aeu9I6RkM5JepGwCIWPdye92R0o0X
         nBug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAW/IIZcGfMLTD68nbtsYT87BPA43BeDBJe+OVSJtnEEC7OObNuS
	5UEgJI7H/uo6NvnrZ6ApmoZ80rJMIhwJmiK/eQs+S9Gmz9Vl37qYtIZjvOhiQXFrpgQzmKgM+fr
	dtKDrnC85ibh1oBlJNBYwL5dYpts1DqBURQxeFoVGMc9yM6RC/e8y6P+clhhkZ2k=
X-Received: by 2002:aca:5bd7:: with SMTP id p206mr773329oib.128.1557246926859;
        Tue, 07 May 2019 09:35:26 -0700 (PDT)
X-Received: by 2002:aca:5bd7:: with SMTP id p206mr773274oib.128.1557246925909;
        Tue, 07 May 2019 09:35:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557246925; cv=none;
        d=google.com; s=arc-20160816;
        b=spsoPjp1e6NO7pFKymeYeZkWREsj+W5lPVxBSQx/c6A41spWDyDEt2VtrLH2qICVa+
         btwv3X2M/7h0zLFhVtIE2lrTBJ3BX/qb+Bn3hiZqQ2Qlw69opdEQ9Iq62fFZj/Uur6fG
         olOQ4seY9r7X/JCsEEbTdpLCnI8PVn3Cg6IG6AKrVJiHBVhSJhFLpstNCYfMj5B5rPZJ
         Y7RCihFudJ7JZOdWMxgt2MlS8TKTxYA54FMSxW4iY6Kn9lx6/LTesbSBUWItSMzq1eAr
         PvSNpUDsisi7pizFPgelrI0F1FUtgkqOzFEsoRed3/J/SRIkQU/1ZG2pGw5CV3XLmuxS
         jyqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uaftBA0UoN/VSNTOzbOYMh9Vy7eqJmh/fNyQY1SouuI=;
        b=X2rVaSTp1Sxjienp/q7sCDoh0SuO3FE+z+GTrKTE0uUywV/MTZDHRZJTHfp5O1JQay
         nHlpc3S7V/b60a1nBGbIoqSOgynKbExEthmigdxwCp8/Vy0bReDuKI7Fr/EaDiW1g3vu
         CdIauQBoAbtfXdwmkBlXVb8qOAjaq8skY6mFJKXV4fI5P1cVDTCKGF49pLi+ASyUD21w
         MW+7vxn5a2gvcNRepV9zhcR4qaM6LfTvOIZ1lLZzCA7hxuD2X+rVuHgdJhPbde5+rpEC
         lNoNSAaBVLw1lBYAdsbgS8o5O+vxDhwjgcYRAVNhXkukNyz22f6dEkPKC9uMaFeh/FtX
         8dOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l5sor6386753otk.83.2019.05.07.09.35.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 09:35:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqydLIte/a5y0Qbp7koBb1lz2oKeDENbD0wbuwwQYduw/mFVNSh7ERvEKJGGr0YtfDzHEXQceQ==
X-Received: by 2002:a9d:6c51:: with SMTP id g17mr13323687otq.171.1557246925490;
        Tue, 07 May 2019 09:35:25 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id p4sm3559359oti.70.2019.05.07.09.35.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 May 2019 09:35:24 -0700 (PDT)
Date: Tue, 7 May 2019 09:35:20 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Christian Brauner <christian@brauner.io>,
	Daniel Colascione <dancol@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>,
	Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507163520.GA1131@sultan-box.localdomain>
References: <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507153154.GA5750@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507153154.GA5750@redhat.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 05:31:54PM +0200, Oleg Nesterov wrote:
> I am not going to comment the intent, but to be honest I am skeptical too.

The general sentiment has been that this is a really bad idea, but I'm just a
frustrated Android user who wants his phone to not require mountains of zRAM
only to still manage memory poorly. Until I can go out and buy a non-Pixel phone
that uses PSI to make these decisions (and does a good job of it), I'm going to
stick to my hacky little driver for my personal devices. Many others who like to
hack their Android devices to make them last longer will probably find value in
this as well, since there are millions of people who use devices that'll never
seen any of PSI ported to their ancient 3.x kernels.

And yes, I know this would never be accepted to upstream in a million years. I
mostly wanted some code review and guidance, since mm code is pretty tricky :)

> On 05/06, Sultan Alsawaf wrote:
> >
> > +static unsigned long find_victims(struct victim_info *varr, int *vindex,
> > +				  int vmaxlen, int min_adj, int max_adj)
> > +{
> > +	unsigned long pages_found = 0;
> > +	int old_vindex = *vindex;
> > +	struct task_struct *tsk;
> > +
> > +	for_each_process(tsk) {
> > +		struct task_struct *vtsk;
> > +		unsigned long tasksize;
> > +		short oom_score_adj;
> > +
> > +		/* Make sure there's space left in the victim array */
> > +		if (*vindex == vmaxlen)
> > +			break;
> > +
> > +		/* Don't kill current, kthreads, init, or duplicates */
> > +		if (same_thread_group(tsk, current) ||
> > +		    tsk->flags & PF_KTHREAD ||
> > +		    is_global_init(tsk) ||
> > +		    vtsk_is_duplicate(varr, *vindex, tsk))
> > +			continue;
> > +
> > +		vtsk = find_lock_task_mm(tsk);
> 
> Did you test this patch with lockdep enabled?
> 
> If I read the patch correctly, lockdep should complain. vtsk_is_duplicate()
> ensures that we do not take the same ->alloc_lock twice or more, but lockdep
> can't know this.

Yeah, lockdep is fine with this, at least on 4.4.

> > +static void scan_and_kill(unsigned long pages_needed)
> > +{
> > +	static DECLARE_WAIT_QUEUE_HEAD(victim_waitq);
> > +	struct victim_info victims[MAX_VICTIMS];
> > +	int i, nr_to_kill = 0, nr_victims = 0;
> > +	unsigned long pages_found = 0;
> > +	atomic_t victim_count;
> > +
> > +	/*
> > +	 * Hold the tasklist lock so tasks don't disappear while scanning. This
> > +	 * is preferred to holding an RCU read lock so that the list of tasks
> > +	 * is guaranteed to be up to date. Keep preemption disabled until the
> > +	 * SIGKILLs are sent so the victim kill process isn't interrupted.
> > +	 */
> > +	read_lock(&tasklist_lock);
> > +	preempt_disable();
> 
> read_lock() disables preemption, every task_lock() too, so this looks
> unnecessary.

Good point.

> > +	for (i = 1; i < ARRAY_SIZE(adj_prio); i++) {
> > +		pages_found += find_victims(victims, &nr_victims, MAX_VICTIMS,
> > +					    adj_prio[i], adj_prio[i - 1]);
> > +		if (pages_found >= pages_needed || nr_victims == MAX_VICTIMS)
> > +			break;
> > +	}
> > +
> > +	/*
> > +	 * Calculate the number of tasks that need to be killed and quickly
> > +	 * release the references to those that'll live.
> > +	 */
> > +	for (i = 0, pages_found = 0; i < nr_victims; i++) {
> > +		struct victim_info *victim = &victims[i];
> > +		struct task_struct *vtsk = victim->tsk;
> > +
> > +		/* The victims' mm lock is taken in find_victims; release it */
> > +		if (pages_found >= pages_needed) {
> > +			task_unlock(vtsk);
> > +			continue;
> > +		}
> > +
> > +		/*
> > +		 * Grab a reference to the victim so it doesn't disappear after
> > +		 * the tasklist lock is released.
> > +		 */
> > +		get_task_struct(vtsk);
> 
> The comment doesn't look correct. the victim can't dissapear until task_unlock()
> below, it can't pass exit_mm().

I was always unsure about this and decided to hold a reference to the
task_struct to be safe. Thanks for clearing that up.

> > +		pages_found += victim->size;
> > +		nr_to_kill++;
> > +	}
> > +	read_unlock(&tasklist_lock);
> > +
> > +	/* Kill the victims */
> > +	victim_count = (atomic_t)ATOMIC_INIT(nr_to_kill);
> > +	for (i = 0; i < nr_to_kill; i++) {
> > +		struct victim_info *victim = &victims[i];
> > +		struct task_struct *vtsk = victim->tsk;
> > +
> > +		pr_info("Killing %s with adj %d to free %lu kiB\n", vtsk->comm,
> > +			vtsk->signal->oom_score_adj,
> > +			victim->size << (PAGE_SHIFT - 10));
> > +
> > +		/* Configure the victim's mm to notify us when it's freed */
> > +		vtsk->mm->slmk_waitq = &victim_waitq;
> > +		vtsk->mm->slmk_counter = &victim_count;
> > +
> > +		/* Accelerate the victim's death by forcing the kill signal */
> > +		do_send_sig_info(SIGKILL, SIG_INFO_TYPE, vtsk, true);
>                                                                ^^^^
> this should be PIDTYPE_TGID

Thanks, I didn't realize the last argument to do_send_sig_info changed in newer
kernels. The compiler didn't complain, so it went over my head.

> > +
> > +		/* Finally release the victim's mm lock */
> > +		task_unlock(vtsk);
> > +	}
> > +	preempt_enable_no_resched();
> 
> See above. And I don't understand how can _no_resched() really help...

Yeah, good point.

> > +
> > +	/* Try to speed up the death process now that we can schedule again */
> > +	for (i = 0; i < nr_to_kill; i++) {
> > +		struct task_struct *vtsk = victims[i].tsk;
> > +
> > +		/* Increase the victim's priority to make it die faster */
> > +		set_user_nice(vtsk, MIN_NICE);
> > +
> > +		/* Allow the victim to run on any CPU */
> > +		set_cpus_allowed_ptr(vtsk, cpu_all_mask);
> > +
> > +		/* Finally release the victim reference acquired earlier */
> > +		put_task_struct(vtsk);
> > +	}
> > +
> > +	/* Wait until all the victims die */
> > +	wait_event(victim_waitq, !atomic_read(&victim_count));
> 
> Can't we avoid the new slmk_waitq/slmk_counter members in mm_struct?
> 
> I mean, can't we export victim_waitq and victim_count and, say, set/test
> MMF_OOM_VICTIM. In fact I think you should try to re-use mark_oom_victim()
> at least.

This makes the patch less portable across different kernel versions, which is
kind of one of its major goals.

Thanks for the code review, Oleg.

Sultan

