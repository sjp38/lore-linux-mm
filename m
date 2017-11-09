Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C99A440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:26:17 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b189so3732976wmd.9
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:26:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b18si5092731edh.47.2017.11.09.02.26.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 02:26:16 -0800 (PST)
Date: Thu, 9 Nov 2017 11:26:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to
 loadbalance console writes
Message-ID: <20171109102613.hp6waybyxbkb3crz@dhcp22.suse.cz>
References: <20171108102723.602216b1@gandalf.local.home>
 <20171109101138.qmy3366myzjafexr@dhcp22.suse.cz>
 <201711091922.IHJ81787.OVQFFJOSOLtHMF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711091922.IHJ81787.OVQFFJOSOLtHMF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz, peterz@infradead.org, torvalds@linux-foundation.org, jack@suse.cz, mathieu.desnoyers@efficios.com, rostedt@home.goodmis.org

On Thu 09-11-17 19:22:58, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Hi,
> > assuming that this passes warn stall torturing by Tetsuo, do you think
> > we can drop http://lkml.kernel.org/r/1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> > from the mmotm tree?
> 
> I don't think so.
> 
> The rule that "do not try to printk() faster than the kernel can write to
> consoles" will remain no matter how printk() changes. Unless asynchronous
> approach like https://lwn.net/Articles/723447/ is used, I think we can't
> obtain useful information.

Does that mean that the patch doesn't pass your test?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
