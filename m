Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B174B6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:31:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 136so1078870wmm.1
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 13:31:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f16si1584866edf.188.2018.04.24.13.31.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 13:31:51 -0700 (PDT)
Date: Tue, 24 Apr 2018 14:31:48 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaperunmap
Message-ID: <20180424203148.GW17484@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1804191214130.157851@chino.kir.corp.google.com>
 <20180420082349.GW17484@dhcp22.suse.cz>
 <20180420124044.GA17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804212019400.84222@chino.kir.corp.google.com>
 <201804221248.CHE35432.FtOMOLSHOFJFVQ@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1804231706340.18716@chino.kir.corp.google.com>
 <20180424130432.GB17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804241256000.231037@chino.kir.corp.google.com>
 <20180424201352.GV17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804241317200.231037@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1804241317200.231037@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 24-04-18 13:22:45, David Rientjes wrote:
[...]
> > > My patch has passed intensive testing on both x86 and powerpc, so I'll ask 
> > > that it's pushed for 4.17-rc3.  Many thanks to Tetsuo for the suggestion 
> > > on calling __oom_reap_task_mm() from exit_mmap().
> > 
> > Yeah, but your patch does have a problem with blockable mmu notifiers
> > IIUC.
> 
> What on earth are you talking about?  exit_mmap() does 
> mmu_notifier_release().  There are no blockable mmu notifiers.

MMF_OOM_SKIP - remember? The thing that guarantees a forward progress.
So we cannot really depend on setting MMF_OOM_SKIP if a
mmu_notifier_release blocks for an excessive/unbounded amount of time.

Look I am not really interested in disussing this to death but it would
be really _nice_ if you could calm down a bit, stop fighting for the solution
you have proposed and ignore the feedback you are getting.

There are two things to care about here. Stop the race that can blow up
and do not regress MMF_OOM_SKIP guarantee. Can we please do that.
-- 
Michal Hocko
SUSE Labs
