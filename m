Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECBB2C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 05:15:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4A2621783
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 05:15:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uMqFKvp4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4A2621783
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 110176B0003; Tue, 21 May 2019 01:15:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C0AA6B0005; Tue, 21 May 2019 01:15:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF1C96B0007; Tue, 21 May 2019 01:14:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B79486B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 01:14:59 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y1so10636605plr.13
        for <linux-mm@kvack.org>; Mon, 20 May 2019 22:14:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=awsERbP686n2vbtni9N26u6HQquz9Ce47TX91GWA22Y=;
        b=DTVlxaRFjCf3KJ+nt/w2q1ySK/Pe7GJp1Eu5qgLDgj5heXtXhNjalD0+5+sLcT3ON4
         Fx7yw0dqWxUzuy75r63gJV9xnWF0Jd1pqJxqUsJ3Q3iZeyc/zW+H0chYaWtZmwqlihZF
         Q0lZHbXUjzRf6RL9ThLioosYvqPO4P5u8vCk9MgpqNROfPPSX+hAiAQAPqEn0YCbskdM
         D41tsXMD6QoBL0x+8YQvnYS+GMukAR+GXSl5M4xM8XYTKr2oL5VxliynEIV22UtXHm1M
         5+SG8sEPwMiHVVd8IILgNXu+4dqTeU4OaNoXBEQU5njH5gsNoTfdvN6hHKJtQ3urM1CH
         eSwQ==
X-Gm-Message-State: APjAAAUmuF+8EFXSFeRb7FjaEjeFb9wu4OpHAHMXVgv9vKwt4V5wtVKv
	Cj2JmAHxtZHMhkPHPeX9+QqtCtoelbqGLeJ/VC/PzyqoejmE6bRkaPf+xEZ8av6Ygl6CCah4KNC
	uiTudVZQrtPeB4khaQaoWRDRK7a2Wa18WyYYVdmIR6LmLCh6qHW/AVAr3F/bielc=
X-Received: by 2002:aa7:93bb:: with SMTP id x27mr83934983pff.104.1558415699317;
        Mon, 20 May 2019 22:14:59 -0700 (PDT)
X-Received: by 2002:aa7:93bb:: with SMTP id x27mr83934917pff.104.1558415698573;
        Mon, 20 May 2019 22:14:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558415698; cv=none;
        d=google.com; s=arc-20160816;
        b=nWx8T8ectQVVFqWQvhT3F/MEjNoaJgrZWj7lYphWW4R/bxEz/zs8joimB9JPPaGwxf
         vcQg9WEoB0dVLaw3n0azZj1BCI0fnRNg2h8lPQghNfWSmBYN6j0WPOznzoZstcyVGqw6
         +e/6/SqVQc0fvK+TqHgM3SpBz7ZPiBoXRLWynPRZZyMmaBMfrYD5DawHRFpQMyRDB9Oo
         brqj0zgwKSC3hyyUTYUiwVjG+YcYRnXE2OayWOHGc+BpjDgTNcNHHSpBOWoGB8nPJhs6
         UMZaA2Lm0ZUDc6iXKUNFGaOfenEAcxmVb7E2mAa5A9KQHTZ2B9ANFIk8trdqSukPCX2X
         AhHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=awsERbP686n2vbtni9N26u6HQquz9Ce47TX91GWA22Y=;
        b=VsgApPKL/ljJ/kqkz+FrUD7bljn9ciczkONZm8caHnI3azEcwVedU1bg/uOPbgO5Cr
         4LJJvLENtIcefSDNmBO/3DZ59cNUJ7fF9ZY6BumxIVey7wPIMXljskgZqn19LEsromuH
         aCf1q9fFAmhkryF/UNQG32yky+VB0LysYeIzkOiHPlR9igmA9eKLtowu28uZxcUeTO39
         aaZ155R2Ox/S3jEuFPR5d0vFuIE4GCMqvTKxCizGBFef+D70fS/Whg92jN5RRm0+Ad+V
         Y308FGZxJhsC7/pK4wpoEF0ENZTCm/PAgze3Dhs6KLtUtAUmN1iubdnDLsoWdujUNl0S
         dQmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uMqFKvp4;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a22sor19749708plm.8.2019.05.20.22.14.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 22:14:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uMqFKvp4;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=awsERbP686n2vbtni9N26u6HQquz9Ce47TX91GWA22Y=;
        b=uMqFKvp4Ww8W8I+eKDvVyb/KNxp84a6Q/Pf3cBUUFp5paFjDEMSdxKkq/ue59FWxdH
         zUy/xLz9sirj7qUGaraAtzd1GL8E3xh6y+T983/HZrykvbbMvAqG8B+78WCHorI5tYPi
         bXyYhDJL0f3co7AT6j0OpIxWM7o6flYqD6dM9fbRoAFOmy+MKlSD/OVA/53ofqup15Mr
         b2t3+XMVC1884q3GXFwkqSZDMpJm29MT5jun6zOXGIEgAGfKMEIL8j4/oBf+ODtJXhi7
         ETiMYEBJehil+nwHrUTqIwZklhmEm9t2i18L76VRk7t7hIl8gQJh6xL0c4U86BQ/LjN1
         3eFg==
X-Google-Smtp-Source: APXvYqx6+uKIuM7hb/YRgMZxEe9VZOovKMMqIVawqI3F86WSoRcl86Wm7jNxLg/rw5XBlMEozv/vfg==
X-Received: by 2002:a17:902:e08b:: with SMTP id cb11mr21806155plb.122.1558415698048;
        Mon, 20 May 2019 22:14:58 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id u3sm21694200pfn.29.2019.05.20.22.14.53
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 20 May 2019 22:14:56 -0700 (PDT)
Date: Tue, 21 May 2019 14:14:51 +0900
From: Minchan Kim <minchan@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Tim Murray <timmurray@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521051451.GL10039@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <dbe801f0-4bbe-5f6e-9053-4b7deb38e235@arm.com>
 <CAEe=Sxka3Q3vX+7aWUJGKicM+a9Px0rrusyL+5bB1w4ywF6N4Q@mail.gmail.com>
 <1754d0ef-6756-d88b-f728-17b1fe5d5b07@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1754d0ef-6756-d88b-f728-17b1fe5d5b07@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 08:25:55AM +0530, Anshuman Khandual wrote:
> 
> 
> On 05/20/2019 10:29 PM, Tim Murray wrote:
> > On Sun, May 19, 2019 at 11:37 PM Anshuman Khandual
> > <anshuman.khandual@arm.com> wrote:
> >>
> >> Or Is the objective here is reduce the number of processes which get killed by
> >> lmkd by triggering swapping for the unused memory (user hinted) sooner so that
> >> they dont get picked by lmkd. Under utilization for zram hardware is a concern
> >> here as well ?
> > 
> > The objective is to avoid some instances of memory pressure by
> > proactively swapping pages that userspace knows to be cold before
> > those pages reach the end of the LRUs, which in turn can prevent some
> > apps from being killed by lmk/lmkd. As soon as Android userspace knows
> > that an application is not being used and is only resident to improve
> > performance if the user returns to that app, we can kick off
> > process_madvise on that process's pages (or some portion of those
> > pages) in a power-efficient way to reduce memory pressure long before
> > the system hits the free page watermark. This allows the system more
> > time to put pages into zram versus waiting for the watermark to
> > trigger kswapd, which decreases the likelihood that later memory
> > allocations will cause enough pressure to trigger a kill of one of
> > these apps.
> 
> So this opens up bit of LRU management to user space hints. Also because the app
> in itself wont know about the memory situation of the entire system, new system
> call needs to be called from an external process.

That's why process_madvise is introduced here.

> 
> > 
> >> Swapping out memory into zram wont increase the latency for a hot start ? Or
> >> is it because as it will prevent a fresh cold start which anyway will be slower
> >> than a slow hot start. Just being curious.
> > 
> > First, not all swapped pages will be reloaded immediately once an app
> > is resumed. We've found that an app's working set post-process_madvise
> > is significantly smaller than what an app allocates when it first
> > launches (see the delta between pswpin and pswpout in Minchan's
> > results). Presumably because of this, faulting to fetch from zram does
> 
> pswpin      417613    1392647     975034     233.00
> pswpout    1274224    2661731    1387507     108.00
> 
> IIUC the swap-in ratio is way higher in comparison to that of swap out. Is that
> always the case ? Or it tend to swap out from an active area of the working set
> which faulted back again.

I think it's because apps are alive longer via reducing being killed
so turn into from pgpgin to swapin.

> 
> > not seem to introduce a noticeable hot start penalty, not does it
> > cause an increase in performance problems later in the app's
> > lifecycle. I've measured with and without process_madvise, and the
> > differences are within our noise bounds. Second, because we're not
> 
> That is assuming that post process_madvise() working set for the application is
> always smaller. There is another challenge. The external process should ideally
> have the knowledge of active areas of the working set for an application in
> question for it to invoke process_madvise() correctly to prevent such scenarios.

There are several ways to detect workingset more accurately at the cost
of runtime. For example, with idle page tracking or clear_refs. Accuracy
is always trade-off of overhead for LRU aging.

> 
> > preemptively evicting file pages and only making them more likely to
> > be evicted when there's already memory pressure, we avoid the case
> > where we process_madvise an app then immediately return to the app and
> > reload all file pages in the working set even though there was no
> > intervening memory pressure. Our initial version of this work evicted
> 
> That would be the worst case scenario which should be avoided. Memory pressure
> must be a parameter before actually doing the swap out. But pages if know to be
> inactive/cold can be marked high priority to be swapped out.
> 
> > file pages preemptively and did cause a noticeable slowdown (~15%) for
> > that case; this patch set avoids that slowdown. Finally, the benefit
> > from avoiding cold starts is huge. The performance improvement from
> > having a hot start instead of a cold start ranges from 3x for very
> > small apps to 50x+ for larger apps like high-fidelity games.
> 
> Is there any other real world scenario apart from this app based ecosystem where
> user hinted LRU management might be helpful ? Just being curious. Thanks for the
> detailed explanation. I will continue looking into this series.

