Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF7F6B0033
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 08:00:25 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b195so2932663wmb.6
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 05:00:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b4si1042538edm.167.2017.09.15.05.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 05:00:23 -0700 (PDT)
Date: Fri, 15 Sep 2017 14:00:20 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
Message-ID: <20170915120020.diakzyzsx73ygnfx@dhcp22.suse.cz>
References: <20170915095849.9927-1-yuwang668899@gmail.com>
 <20170915103957.64r5xln7s6wlu3ro@dhcp22.suse.cz>
 <201709152038.BHF26323.LFOMFHOFOJSVQt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201709152038.BHF26323.LFOMFHOFOJSVQt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: yuwang668899@gmail.com, vbabka@suse.cz, mpatocka@redhat.com, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com

On Fri 15-09-17 20:38:49, Tetsuo Handa wrote:
[...]
> You said "identify _why_ we see the lockup trigerring in the first
> place" without providing means to identify it. Unless you provide
> means to identify it (in a form which can be immediately and easily
> backported to 4.9 kernels; that is, backporting not-yet-accepted
> printk() offloading patchset is not a choice), this patch cannot be
> refused.

I fail to see why. It simply workarounds an existing problem elsewhere
in the kernel without deeper understanding on where the problem is. You
can add your own instrumentation to debug and describe the problem. This
is no different to any other kernel bugs...

If our printk implementation is so weak it cannot cope with writers then
that should be fixed without spreading hacks in different subsystems. If
the lockup is a real problem under normal workloads (rather than
artificial ones) then we should try to throttle more aggresively.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
