Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E88506B0033
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 10:14:54 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id g15so415804oib.2
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 07:14:54 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r64si8922944oib.355.2017.09.13.07.14.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 07:14:53 -0700 (PDT)
Subject: Re: [PATCH] mm: respect the __GFP_NOWARN flag when warning about stalls
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170911082650.dqfirwc63xy7i33q@dhcp22.suse.cz>
	<alpine.LRH.2.02.1709111926480.31898@file01.intranet.prod.int.rdu2.redhat.com>
	<20170913115442.4tpbiwu77y7lrz6g@dhcp22.suse.cz>
	<201709132254.DEE34807.LQOtMFOFJSOVHF@I-love.SAKURA.ne.jp>
	<bcd7002d-d352-1f24-e15b-49642f978267@suse.cz>
In-Reply-To: <bcd7002d-d352-1f24-e15b-49642f978267@suse.cz>
Message-Id: <201709132314.BID39077.HMFOJSLFtVOFOQ@I-love.SAKURA.ne.jp>
Date: Wed, 13 Sep 2017 23:14:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, mhocko@kernel.org, mpatocka@redhat.com
Cc: hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Vlastimil Babka wrote:
> On 09/13/2017 03:54 PM, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> >> Let's see what others think about this.
> > 
> > Whether __GFP_NOWARN should warn about stalls is not a topic to discuss.
> 
> It is the topic of this thread, which tries to address a concrete
> problem somebody has experienced. In that context, the rest of your
> concerns seem to me not related to this problem, IMHO.

I suggested replacing warn_alloc() with safe/useful one rather than tweaking
warn_alloc() about __GFP_NOWARN.

> 
> > I consider warn_alloc() for reporting stalls is broken. It fails to provide
> > backtrace of stalling location. For example, OOM lockup with oom_lock held
> > cannot be reported by warn_alloc(). It fails to provide readable output when
> > called concurrently. For example, concurrent calls can cause printk()/
> > schedule_timeout_killable() lockup with oom_lock held. printk() offloading is
> > not an option, for there will be situations where printk() offloading cannot
> > be used (e.g. queuing via printk() is faster than writing to serial consoles
> > which results in unreadable logs due to log_bug overflow).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
