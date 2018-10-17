Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 039676B026A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 07:29:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e5-v6so16394307eda.4
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:29:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y16si2732215edw.172.2018.10.17.04.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 04:29:33 -0700 (PDT)
Date: Wed, 17 Oct 2018 13:29:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181017112931.GP18839@dhcp22.suse.cz>
References: <1539770782-3343-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181017102821.GM18839@dhcp22.suse.cz>
 <20181017111724.GA459@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181017111724.GA459@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On Wed 17-10-18 20:17:24, Sergey Senozhatsky wrote:
> On (10/17/18 12:28), Michal Hocko wrote:
> > > Michal proposed ratelimiting dump_header() [2]. But I don't think that
> > > that patch is appropriate because that patch does not ratelimit
> > > 
> > >   "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
> > >   "Out of memory and no killable processes...\n"
> [..]
> > > Let's make sure that next dump_header() waits for at least 60 seconds from
> > > previous "Out of memory and no killable processes..." message.
> > 
> > Could you explain why this is any better than using a well established
> > ratelimit approach?
> 
> Tetsuo, let's use a well established rate-limit approach both in
> dump_hedaer() and out_of_memory(). I actually was under impression
> that Michal added rate-limiting to both of these functions.

I have http://lkml.kernel.org/r/20181010151135.25766-1-mhocko@kernel.org
Then the discussion took the usual direction of back and forth resulting
in "you do not ratelimit the allocation oom context" and "please do that
as an incremental patch" route and here we are. I do not have time and
energy to argue in an endless loop.

> The appropriate rate-limit value looks like something that printk()
> should know and be able to tell to the rest of the kernel. I don't
> think that middle ground will ever be found elsewhere.

Yes, that makes sense.
-- 
Michal Hocko
SUSE Labs
