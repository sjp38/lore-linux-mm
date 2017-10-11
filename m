Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA8E6B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 07:15:17 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u130so1002694oib.21
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 04:15:17 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x4si5745884oti.73.2017.10.11.04.15.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 04:15:14 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170915095849.9927-1-yuwang668899@gmail.com>
	<20170915143732.GA8397@cmpxchg.org>
	<201709161312.CAJ73470.FSOHFMVJLFQOOt@I-love.SAKURA.ne.jp>
In-Reply-To: <201709161312.CAJ73470.FSOHFMVJLFQOOt@I-love.SAKURA.ne.jp>
Message-Id: <201710112014.CCJ78649.tOMFSHOFVLOJFQ@I-love.SAKURA.ne.jp>
Date: Wed, 11 Oct 2017 20:14:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: yuwang668899@gmail.com, mhocko@suse.com, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com, akpm@linux-foundation.org

Tetsuo Handa wrote:
> Johannes Weiner wrote:
> > On Fri, Sep 15, 2017 at 05:58:49PM +0800, wang Yu wrote:
> > > From: "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>
> > > 
> > > I found a softlockup when running some stress testcase in 4.9.x,
> > > but i think the mainline have the same problem.
> > > 
> > > call trace:
> > > [365724.502896] NMI watchdog: BUG: soft lockup - CPU#31 stuck for 22s!
> > > [jbd2/sda3-8:1164]
> > 
> > We've started seeing the same thing on 4.11. Tons and tons of
> > allocation stall warnings followed by the soft lock-ups.
> 
> Forgot to comment. Since you are able to reproduce the problem (aren't you?),
> please try setting 1 to /proc/sys/kernel/softlockup_all_cpu_backtrace so that
> we can know what other CPUs are doing. It does not need to patch kernels.
> 
Johannes, were you able to reproduce the problem? I'd like to continue
warn_alloc() serialization patch if you can confirm that uncontrolled
flooding of allocation stall warning can lead to soft lockups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
