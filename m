Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42D74C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:21:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A290D217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:21:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amarulasolutions.com header.i=@amarulasolutions.com header.b="hYNIx/+f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A290D217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amarulasolutions.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 417BE8E012D; Mon, 11 Feb 2019 22:21:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C81F8E0103; Mon, 11 Feb 2019 22:21:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B7988E012D; Mon, 11 Feb 2019 22:21:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id CAD998E0103
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:21:31 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id f4so429205wrj.11
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:21:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hLXs27rPVddlIN2Y+VY1rZ6x4qsTrdDdtBkRfaDycQ8=;
        b=JYzRJVM56v26eO03bQJwx9KCgKS0FKnUlVZlsX0C2NKNnx2sa4SPBEMQNuxi7URg08
         7l+Uv1u13HqzeH7xpjNHjTH2SNhYm7ZakvFRUXFF8r8SW3CZGKE1J/oaextND1hNddV3
         7AzTBrhVdznU9S6xZ5RGqdHbKDaCXOTw1r84ebhUrGRe6U8aULDYZVtqasE8b5IltycN
         mFVHOCS6dqU8kbIlZBvA0QYXPap9HhbwKUi8YYKC9bointckE3ADWCYzZUETSohbRyOl
         ik5Z9OHfo7S45ofZOA3GxMXf6ot+50ZS9GTc01Jw/n1xu5RMz7eWz2JrFZIOuplwjb+R
         KY9A==
X-Gm-Message-State: AHQUAuZvE2uhAhs+++zhCgCeOT7ZxKIUwUnuWm0RaFItLvx4V+u7biZB
	BgUD4DioIVWVAbOthXMS9/whxBRaiue9H6R9Bv12dx0QLAlgLQYH/GaW0ABsN/rPbk2nN5t0nBz
	6FvOwwI6TH035tT/n04Dx/iLSuQ5TJjRWjuSC54Q8nQ+2esne2VEFFd+h98DrT++cKKau67klYW
	aRsQDWX3jy4+XKOmorvEiXK+GvdQ/lIXt3G/0b4dUZZJGv0J+lSP5vynNCkkdtyPc9kBtngWBoO
	Hd4EVZcu+prcqoh0ugqLmF+iaYrgnMJkM6Dyf9obcYlXonqSlkbQfcmVscYFusdUBkGxItVWHuZ
	hZV4TNlrDDLXOZDazU5ETRvemeKJIX8S/bjhaqsA+DM+xjxnnJM3/SM7C+cYFk5hG8Bm4JbJTEl
	O
X-Received: by 2002:a7b:cf1a:: with SMTP id l26mr998069wmg.76.1549941691397;
        Mon, 11 Feb 2019 19:21:31 -0800 (PST)
X-Received: by 2002:a7b:cf1a:: with SMTP id l26mr998032wmg.76.1549941690574;
        Mon, 11 Feb 2019 19:21:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549941690; cv=none;
        d=google.com; s=arc-20160816;
        b=K5nNd2fpXeeiBIzEUge8jGUO+z6f4JbK00XmggYsvDCm4ETZRb1Mh0UZNs/quNw+qB
         pdkasC4bkCjkMsLPtrH/tukUMangrv1/JXDb5NUmSi2i7xrdIS/A32S6dIpApi+grMTG
         wFx8lAH1/1J8EWB5kA8h/9kAYhRIvlNm/mbbr9nEjOArdIg0bpgWtPHhv8MQ2hO2NvzU
         YQ83KCSU1HQtlbtWU8b58ScAE/332oeOlpZcheZAksJ4/G3a75Rqe4xvpUihgVcbaN/C
         rKFcTRt1V9ffkaAr2zDES9V2KD8WjZHC1gYZXB1DTpoQmr+TA1GM+b7UZ31ZfKrxYV+2
         tRKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hLXs27rPVddlIN2Y+VY1rZ6x4qsTrdDdtBkRfaDycQ8=;
        b=rzLGeiJ9B1zKBD7ZE6jBeex5yDZRAlFS4hHCAlCF/yQR3ldTQtoYwh6KUTgVMutIgO
         vM+X4miX1I9vZDyA8gSjyoQA9PecELcwCevyCJLueYEfHw4iVRgFgdnOSn3+GX0IYpHI
         +5KkPC5uxQA5pjkVujvRgy/irY19alsEIraty0Tq///gDpo143UrrM18xjP6ouX1Sa09
         L3k500mXRqAsYTtDrfSCwTgtI+VNtR/fJ+WbJqCt3OSFYjH9oMVELmrftlcDP0l/3rJ2
         LBgITqtb1bDyuLKf9BHBHfBhPVAHeBeOvKFqmN+hQyyhN/YjqM6mGcYUdzoy4q6Tr+fm
         ucvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b="hYNIx/+f";
       spf=pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=andrea.parri@amarulasolutions.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u13sor10439wrq.41.2019.02.11.19.21.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 19:21:30 -0800 (PST)
Received-SPF: pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b="hYNIx/+f";
       spf=pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=andrea.parri@amarulasolutions.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amarulasolutions.com; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=hLXs27rPVddlIN2Y+VY1rZ6x4qsTrdDdtBkRfaDycQ8=;
        b=hYNIx/+fk/bGYAS2+WwLqvKoiPxJutjp2NNdAaH4IO5Xft3SQgLmo0/0W+iOst95ce
         NN6FRvJppnNOMFp8cVcbTseaUPEeAKgKGFlZI2Ff2Vq2o/hIj0tRcEnsZQ2xW7epHxKo
         c6adUEh13UoF2lC9nQ7e2Y18JYHddeupS/B/k=
X-Google-Smtp-Source: AHgI3IYQlZs1R9XBHjuFplPiz6hJrtSGlTv38M2J/qPbf6gBkDJIx5iGwneN1TqZFFM3tfFYBQ9npA==
X-Received: by 2002:a5d:4ccb:: with SMTP id c11mr1027963wrt.241.1549941689950;
        Mon, 11 Feb 2019 19:21:29 -0800 (PST)
Received: from andrea ([89.22.71.151])
        by smtp.gmail.com with ESMTPSA id k126sm2200699wme.27.2019.02.11.19.21.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 19:21:29 -0800 (PST)
Date: Tue, 12 Feb 2019 04:21:21 +0100
From: Andrea Parri <andrea.parri@amarulasolutions.com>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: "Huang, Ying" <ying.huang@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap
 operations
Message-ID: <20190212032121.GA2723@andrea>
References: <20190211083846.18888-1-ying.huang@intel.com>
 <20190211190646.j6pdxqirc56inbbe@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211190646.j6pdxqirc56inbbe@ca-dmjordan1.us.oracle.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > +	if (!si)
> > +		goto bad_nofile;
> > +
> > +	preempt_disable();
> > +	if (!(si->flags & SWP_VALID))
> > +		goto unlock_out;
> 
> After Hugh alluded to barriers, it seems the read of SWP_VALID could be
> reordered with the write in preempt_disable at runtime.  Without smp_mb()
> between the two, couldn't this happen, however unlikely a race it is?
> 
> CPU0                                CPU1
> 
> __swap_duplicate()
>     get_swap_device()
>         // sees SWP_VALID set
>                                    swapoff
>                                        p->flags &= ~SWP_VALID;
>                                        spin_unlock(&p->lock); // pair w/ smp_mb
>                                        ...
>                                        stop_machine(...)
>                                        p->swap_map = NULL;
>         preempt_disable()
>     read NULL p->swap_map


I don't think that that smp_mb() is necessary.  I elaborate:

An important piece of information, I think, that is missing in the
diagram above is the stopper thread which executes the work queued
by stop_machine().  We have two cases to consider, that is,

  1) the stopper is "executed before" the preempt-disable section

	CPU0

	cpu_stopper_thread()
	...
	preempt_disable()
	...
	preempt_enable()

  2) the stopper is "executed after" the preempt-disable section

	CPU0

	preempt_disable()
	...
	preempt_enable()
	...
	cpu_stopper_thread()

Notice that the reads from p->flags and p->swap_map in CPU0 cannot
cross cpu_stopper_thread().  The claim is that CPU0 sees SWP_VALID
unset in (1) and that it sees a non-NULL p->swap_map in (2).

I consider the two cases separately:

  1) CPU1 unsets SPW_VALID, it locks the stopper's lock, and it
     queues the stopper work; CPU0 locks the stopper's lock, it
     dequeues this work, and it reads from p->flags.

     Diagrammatically, we have the following MP-like pattern:

	CPU0				CPU1

	lock(stopper->lock)		p->flags &= ~SPW_VALID
	get @work			lock(stopper->lock)
	unlock(stopper->lock)		add @work
	reads p->flags 			unlock(stopper->lock)

     where CPU0 must see SPW_VALID unset (if CPU0 sees the work
     added by CPU1).

  2) CPU0 reads from p->swap_map, it locks the completion lock,
     and it signals completion; CPU1 locks the completion lock,
     it checks for completion, and it writes to p->swap_map.

     (If CPU0 doesn't signal the completion, or CPU1 doesn't see
     the completion, then CPU1 will have to iterate the read and
     to postpone the control-dependent write to p->swap_map.)

     Diagrammatically, we have the following LB-like pattern:

	CPU0				CPU1

	reads p->swap_map		lock(completion)
	lock(completion)		read completion->done
	completion->done++		unlock(completion)
	unlock(completion)		p->swap_map = NULL

     where CPU0 must see a non-NULL p->swap_map if CPU1 sees the
     completion from CPU0.

Does this make sense?

  Andrea

