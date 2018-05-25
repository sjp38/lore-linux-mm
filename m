Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC6866B0008
	for <linux-mm@kvack.org>; Fri, 25 May 2018 07:46:36 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j75-v6so2498766oib.5
        for <linux-mm@kvack.org>; Fri, 25 May 2018 04:46:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id e195-v6si295876oig.91.2018.05.25.04.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 04:46:35 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180524115017.GE20441@dhcp22.suse.cz>
	<201805250117.w4P1HgdG039943@www262.sakura.ne.jp>
	<20180525083118.GI11881@dhcp22.suse.cz>
	<201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
	<20180525114213.GJ11881@dhcp22.suse.cz>
In-Reply-To: <20180525114213.GJ11881@dhcp22.suse.cz>
Message-Id: <201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
Date: Fri, 25 May 2018 20:46:21 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Fri 25-05-18 19:57:32, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > What is wrong with the folliwing? should_reclaim_retry should be a
> > > natural reschedule point. PF_WQ_WORKER is a special case which needs a
> > > stronger rescheduling policy. Doing that unconditionally seems more
> > > straightforward than depending on a zone being a good candidate for a
> > > further reclaim.
> > 
> > Where is schedule_timeout_uninterruptible(1) for !PF_KTHREAD threads?
> 
> Re-read what I've said.

Please show me as a complete patch. Then, I will test your patch.
