Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4E6A6B026B
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 15:03:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w22-v6so1416609edr.14
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:03:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x6-v6si3438875eds.237.2018.06.28.12.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 12:03:54 -0700 (PDT)
Date: Thu, 28 Jun 2018 12:30:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v10 2/2] Refactor part of the oom report in dump_header
Message-ID: <20180628103002.GZ32348@dhcp22.suse.cz>
References: <1529763171-29240-1-git-send-email-ufo19890607@gmail.com>
 <1529763171-29240-2-git-send-email-ufo19890607@gmail.com>
 <20180627191041.509893a3b43f95a27df32266@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627191041.509893a3b43f95a27df32266@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ufo19890607@gmail.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

On Wed 27-06-18 19:10:41, Andrew Morton wrote:
> On Sat, 23 Jun 2018 22:12:51 +0800 ufo19890607@gmail.com wrote:
> 
> > From: yuzhoujian <yuzhoujian@didichuxing.com>
> > 
> > The current system wide oom report prints information about the victim
> > and the allocation context and restrictions. It, however, doesn't
> > provide any information about memory cgroup the victim belongs to. This
> > information can be interesting for container users because they can find
> > the victim's container much more easily.
> > 
> > I follow the advices of David Rientjes and Michal Hocko, and refactor
> > part of the oom report. After this patch, users can get the memcg's
> > path from the oom report and check the certain container more quickly.
> > 
> > The oom print info after this patch:
> > oom-kill:constraint=<constraint>,nodemask=<nodemask>,oom_memcg=<memcg>,task_memcg=<memcg>,task=<commm>,pid=<pid>,uid=<uid>
> > 
> > Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
> > ---
> > Below is the part of the oom report in the dmesg
> > ...
> > [  134.873392] panic invoked oom-killer: gfp_mask=0x6280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
> >
> > ...
> >
> > [  134.873480] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),task_memcg=/test/test1/test2,task=panic,pid= 8669,  uid=    0
> 
> We're displaying nodemask twice there.  Avoidable?
> 
> Also, the spaces after pid= and uid= don't seem useful.  Why not use
> plain old %d?

I've been discussing this with yuzhoujian off-list so please drop the
current pile
-- 
Michal Hocko
SUSE Labs
