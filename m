Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55B5B6B027A
	for <linux-mm@kvack.org>; Sat, 16 Sep 2017 00:12:45 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id q7so9114248ioi.3
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 21:12:45 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i87si2175148ioo.219.2017.09.15.21.12.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 21:12:43 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170915095849.9927-1-yuwang668899@gmail.com>
	<20170915143732.GA8397@cmpxchg.org>
In-Reply-To: <20170915143732.GA8397@cmpxchg.org>
Message-Id: <201709161312.CAJ73470.FSOHFMVJLFQOOt@I-love.SAKURA.ne.jp>
Date: Sat, 16 Sep 2017 13:12:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: yuwang668899@gmail.com, mhocko@suse.com, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com, akpm@linux-foundation.org

Johannes Weiner wrote:
> On Fri, Sep 15, 2017 at 05:58:49PM +0800, wang Yu wrote:
> > From: "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>
> > 
> > I found a softlockup when running some stress testcase in 4.9.x,
> > but i think the mainline have the same problem.
> > 
> > call trace:
> > [365724.502896] NMI watchdog: BUG: soft lockup - CPU#31 stuck for 22s!
> > [jbd2/sda3-8:1164]
> 
> We've started seeing the same thing on 4.11. Tons and tons of
> allocation stall warnings followed by the soft lock-ups.

Forgot to comment. Since you are able to reproduce the problem (aren't you?),
please try setting 1 to /proc/sys/kernel/softlockup_all_cpu_backtrace so that
we can know what other CPUs are doing. It does not need to patch kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
