Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 281086B0033
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 08:14:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e64so2984778wmi.0
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 05:14:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g91si1051387ede.460.2017.09.15.05.14.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 05:14:04 -0700 (PDT)
Date: Fri, 15 Sep 2017 14:14:01 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
Message-ID: <20170915121401.eaoncsmahh2stqn2@dhcp22.suse.cz>
References: <20170915095849.9927-1-yuwang668899@gmail.com>
 <20170915103957.64r5xln7s6wlu3ro@dhcp22.suse.cz>
 <201709152038.BHF26323.LFOMFHOFOJSVQt@I-love.SAKURA.ne.jp>
 <20170915120020.diakzyzsx73ygnfx@dhcp22.suse.cz>
 <201709152109.AID48261.FtHOFMFQOJVLOS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201709152109.AID48261.FtHOFMFQOJVLOS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: yuwang668899@gmail.com, vbabka@suse.cz, mpatocka@redhat.com, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com

On Fri 15-09-17 21:09:29, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 15-09-17 20:38:49, Tetsuo Handa wrote:
> > [...]
> > > You said "identify _why_ we see the lockup trigerring in the first
> > > place" without providing means to identify it. Unless you provide
> > > means to identify it (in a form which can be immediately and easily
> > > backported to 4.9 kernels; that is, backporting not-yet-accepted
> > > printk() offloading patchset is not a choice), this patch cannot be
> > > refused.
> > 
> > I fail to see why. It simply workarounds an existing problem elsewhere
> > in the kernel without deeper understanding on where the problem is. You
> > can add your own instrumentation to debug and describe the problem. This
> > is no different to any other kernel bugs...
> 
> Please do show us your patch for that. Normal users cannot afford developing
> such instrumentation to debug and describe the problem.

Stop this nonsense already! Any kernel bug/lockup needs a debugging
which might be non-trivial and it is necessary to understand the real
culprit. We do not add random hacks to silence a problem. We aim at
fixing it!
 
> > If our printk implementation is so weak it cannot cope with writers then
> > that should be fixed without spreading hacks in different subsystems. If
> > the lockup is a real problem under normal workloads (rather than
> > artificial ones) then we should try to throttle more aggresively.
> 
> No throttle please. Throttling makes warn_alloc() more and more useless.

so does try_lock approach...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
