Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC934C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 21:45:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6615B206DD
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 21:45:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6615B206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rjwysocki.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1E6F6B0010; Wed,  3 Apr 2019 17:45:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECD746B0269; Wed,  3 Apr 2019 17:45:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6DAB6B026A; Wed,  3 Apr 2019 17:45:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 693B86B0010
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 17:45:21 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id d19so50227lfm.22
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 14:45:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fjfKjBALFmX3df2Ieu/RJvL7HTJTUzAsEOVPXBVlz1w=;
        b=QPjKz9F5e4AUR6ZF0U0ddRbCvcsX4jSChOq0M19ZTokgZBf0UVANwpkbFlGhboqJLK
         6po2fAr6xGQnLsTEX7gI56mUQFbDwIMjkaGQN8OBPnCfDI1hUtwqViZRvcVcMQN7Qwu1
         anqvCe0yD6OZHwU4ezRwWfTQDKgErf5axgXjlqhqx1JApQ4KobE3vtWOIqW1VOBmQM5p
         HWbWP9IjIGDq9dSPrLPWxqLuE2BS4gO5A6hA6d0SzAeAJdBJ2Z239u0/RUeCNmlbduzW
         EgNYwYhEZhRrnFxU6/turUFznPSZAHcGrqtluX98Tg6AiqyiNzgFVxm4hqgtcAlAcuBP
         7AkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
X-Gm-Message-State: APjAAAXfmRe7DQPGj6CRjyhVHE5kCG1Q5XvK0VR2Z8nRHve+Ra82p85R
	j7u+ezezc3qslTRRofUP4h97wJTN7O6vso0qsy3P6C0qdH8Tdr5ccIgOJe0DMhR2j6HQHeMqMtv
	Z7GInumAWLGn5VFLbOMYl06ub2VyoVPqRCaKrW+3H2+DhzWCDUFAZoG55JXTh7ZGRGw==
X-Received: by 2002:a2e:6a14:: with SMTP id f20mr1225500ljc.65.1554327920774;
        Wed, 03 Apr 2019 14:45:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEnwlyfCFGMBNU3x1ufiPE2MkkialStp3vJeXPI+YkgBG4mg+7fWpajWjE1xxz7+unFnJR
X-Received: by 2002:a2e:6a14:: with SMTP id f20mr1225459ljc.65.1554327919489;
        Wed, 03 Apr 2019 14:45:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554327919; cv=none;
        d=google.com; s=arc-20160816;
        b=y2NcGsKmTx/CRDZA35KgpYlDSKoc/qMVkY8UTMoZ77r6q1d04+WBtFmO173y2hWRJT
         FBV619/0CJjBV+AXGSWphgJvd6Q2oNfzaNUaKsh5cJAR1fqiEnKJr+7C5w0dBa9c4WTd
         4vGXV7b2iolKRq4QQ6bqcoC/qP7SKYlpeQRUmG2G6Wjpzd03rovTNemqgIhNRzfPuHoP
         adh7wvndfplTrpv2XqFrdtQWvPg69UpKqKs0Id/j/793X4O11kB7cx6/4PoAG3PPFAiC
         ItSw7L16Yf7B9/ccjvAqwTWUdhmhhgSDZxLwp8bNt4dKw/FArQVVFvzHwqx3AbnPRlnK
         ngfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=fjfKjBALFmX3df2Ieu/RJvL7HTJTUzAsEOVPXBVlz1w=;
        b=y45xxkwPR6WOF+5OLNbtqT+haf+Y4EF8IZVFCY5xt/T0YXX5NiMZM4FsKlYeNduU3o
         Y9ilc3qDq1gO5pVkHoMfSsXQTrTJw2RbUkl9KT7OQSqsGeNSlrrOppBINNZBvlS360+L
         VpEZdPeQFFdkF5GYAb/XCsZ6W+cyGz+VI4elt/TxsovqTL2lY5iGZy1vYoc5wGtVSXjp
         AgHcOu8nYamsfkDe65d1Isj4JXAmtgHhtSGYguB81EI9+H7DfUC3+kUZGnSc2ovNhvlE
         BjuGfxXm7tZtbp1gGEhIlDqWSp46dC42DtZjrWrg0R5v5liZXSde1jD1TV08a/pwtGVh
         8dvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
Received: from cloudserver094114.home.pl (cloudserver094114.home.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id f10si6349563ljk.64.2019.04.03.14.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 14:45:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) client-ip=79.96.170.134;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
Received: from 79.184.254.219.ipv4.supernova.orange.pl (79.184.254.219) (HELO aspire.rjw.lan)
 by serwer1319399.home.pl (79.96.170.134) with SMTP (IdeaSmtpServer 0.83.213)
 id 711508f9338ff3e2; Wed, 3 Apr 2019 23:45:18 +0200
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
To: Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rodolfo =?ISO-8859-1?Q?Garc=EDa_Pe=F1as_=28kix=29?= <kix@kix.es>, Oliver Winker <oliverml1@oli1170.net>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Maxim Patlasov <mpatlasov@parallels.com>, Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>, killian.de.volder@megasoft.be, atillakaraca72@hotmail.com, jrf@mailbox.org, matheusfillipeag@gmail.com
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving 506031 image data pages () ..."
Date: Wed, 03 Apr 2019 23:43:10 +0200
Message-ID: <1892727.yFHGcz2naH@aspire.rjw.lan>
In-Reply-To: <20190403093432.GD8836@quack2.suse.cz>
References: <20140505233358.GC19914@cmpxchg.org> <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org> <20190403093432.GD8836@quack2.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday, April 3, 2019 11:34:32 AM CEST Jan Kara wrote:
> On Tue 02-04-19 16:25:00, Andrew Morton wrote:
> > 
> > I cc'ed a bunch of people from bugzilla.
> > 
> > Folks, please please please remember to reply via emailed
> > reply-to-all.  Don't use the bugzilla interface!
> > 
> > On Mon, 16 Jun 2014 18:29:26 +0200 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com> wrote:
> > 
> > > On 6/13/2014 6:55 AM, Johannes Weiner wrote:
> > > > On Fri, Jun 13, 2014 at 01:50:47AM +0200, Rafael J. Wysocki wrote:
> > > >> On 6/13/2014 12:02 AM, Johannes Weiner wrote:
> > > >>> On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysocki wrote:
> > > >>>> On 5/6/2014 1:33 AM, Johannes Weiner wrote:
> > > >>>>> Hi Oliver,
> > > >>>>>
> > > >>>>> On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrote:
> > > >>>>>> Hello,
> > > >>>>>>
> > > >>>>>> 1) Attached a full function-trace log + other SysRq outputs, see [1]
> > > >>>>>> attached.
> > > >>>>>>
> > > >>>>>> I saw bdi_...() calls in the s2disk paths, but didn't check in detail
> > > >>>>>> Probably more efficient when one of you guys looks directly.
> > > >>>>> Thanks, this looks interesting.  balance_dirty_pages() wakes up the
> > > >>>>> bdi_wq workqueue as it should:
> > > >>>>>
> > > >>>>> [  249.148009]   s2disk-3327    2.... 48550413us : global_dirty_limits <-balance_dirty_pages_ratelimited
> > > >>>>> [  249.148009]   s2disk-3327    2.... 48550414us : global_dirtyable_memory <-global_dirty_limits
> > > >>>>> [  249.148009]   s2disk-3327    2.... 48550414us : writeback_in_progress <-balance_dirty_pages_ratelimited
> > > >>>>> [  249.148009]   s2disk-3327    2.... 48550414us : bdi_start_background_writeback <-balance_dirty_pages_ratelimited
> > > >>>>> [  249.148009]   s2disk-3327    2.... 48550414us : mod_delayed_work_on <-balance_dirty_pages_ratelimited
> > > >>>>> but the worker wakeup doesn't actually do anything:
> > > >>>>> [  249.148009] kworker/-3466    2d... 48550431us : finish_task_switch <-__schedule
> > > >>>>> [  249.148009] kworker/-3466    2.... 48550431us : _raw_spin_lock_irq <-worker_thread
> > > >>>>> [  249.148009] kworker/-3466    2d... 48550431us : need_to_create_worker <-worker_thread
> > > >>>>> [  249.148009] kworker/-3466    2d... 48550432us : worker_enter_idle <-worker_thread
> > > >>>>> [  249.148009] kworker/-3466    2d... 48550432us : too_many_workers <-worker_enter_idle
> > > >>>>> [  249.148009] kworker/-3466    2.... 48550432us : schedule <-worker_thread
> > > >>>>> [  249.148009] kworker/-3466    2.... 48550432us : __schedule <-worker_thread
> > > >>>>>
> > > >>>>> My suspicion is that this fails because the bdi_wq is frozen at this
> > > >>>>> point and so the flush work never runs until resume, whereas before my
> > > >>>>> patch the effective dirty limit was high enough so that image could be
> > > >>>>> written in one go without being throttled; followed by an fsync() that
> > > >>>>> then writes the pages in the context of the unfrozen s2disk.
> > > >>>>>
> > > >>>>> Does this make sense?  Rafael?  Tejun?
> > > >>>> Well, it does seem to make sense to me.
> > > >>>  From what I see, this is a deadlock in the userspace suspend model and
> > > >>> just happened to work by chance in the past.
> > > >> Well, it had been working for quite a while, so it was a rather large
> > > >> opportunity
> > > >> window it seems. :-)
> > > > No doubt about that, and I feel bad that it broke.  But it's still a
> > > > deadlock that can't reasonably be accommodated from dirty throttling.
> > > >
> > > > It can't just put the flushers to sleep and then issue a large amount
> > > > of buffered IO, hoping it doesn't hit the dirty limits.  Don't shoot
> > > > the messenger, this bug needs to be addressed, not get papered over.
> > > >
> > > >>> Can we patch suspend-utils as follows?
> > > >> Perhaps we can.  Let's ask the new maintainer.
> > > >>
> > > >> Rodolfo, do you think you can apply the patch below to suspend-utils?
> > > >>
> > > >>> Alternatively, suspend-utils
> > > >>> could clear the dirty limits before it starts writing and restore them
> > > >>> post-resume.
> > > >> That (and the patch too) doesn't seem to address the problem with existing
> > > >> suspend-utils
> > > >> binaries, however.
> > > > It's userspace that freezes the system before issuing buffered IO, so
> > > > my conclusion was that the bug is in there.  This is arguable.  I also
> > > > wouldn't be opposed to a patch that sets the dirty limits to infinity
> > > > from the ioctl that freezes the system or creates the image.
> > > 
> > > OK, that sounds like a workable plan.
> > > 
> > > How do I set those limits to infinity?
> > 
> > Five years have passed and people are still hitting this.
> > 
> > Killian described the workaround in comment 14 at
> > https://bugzilla.kernel.org/show_bug.cgi?id=75101.
> > 
> > People can use this workaround manually by hand or in scripts.  But we
> > really should find a proper solution.  Maybe special-case the freezing
> > of the flusher threads until all the writeout has completed.  Or
> > something else.
> 
> I've refreshed my memory wrt this bug and I believe the bug is really on
> the side of suspend-utils (uswsusp or however it is called). They are low
> level system tools, they ask the kernel to freeze all processes
> (SNAPSHOT_FREEZE ioctl), and then they rely on buffered writeback (which is
> relatively heavyweight infrastructure) to work. That is wrong in my
> opinion.
> 
> I can see Johanness was suggesting in comment 11 to use O_SYNC in
> suspend-utils which worked but was too slow. Indeed O_SYNC is rather big
> hammer but using O_DIRECT should be what they need and get better
> performance - no additional buffering in the kernel, no dirty throttling,
> etc. They only need their buffer & device offsets sector aligned - they
> seem to be even page aligned in suspend-utils so they should be fine. And
> if the performance still sucks (currently they appear to do mostly random
> 4k writes so it probably would for rotating disks), they could use AIO DIO
> to get multiple pages in flight (as many as they dare to allocate buffers)
> and then the IO scheduler will reorder things as good as it can and they
> should get reasonable performance.
> 
> Is there someone who works on suspend-utils these days?

Not that I know of.

> Because the repo I've found on kernel.org seems to be long dead
> (last commit in 2012).

And that's where the things are as of today, AFAICS.

Cheers,
Rafael

