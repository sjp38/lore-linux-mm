Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 88157440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:24:13 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id f66so4234381oib.1
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:24:13 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 96si2955595ote.459.2017.11.09.02.24.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 02:24:12 -0800 (PST)
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to loadbalance console writes
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171108102723.602216b1@gandalf.local.home>
	<20171109101138.qmy3366myzjafexr@dhcp22.suse.cz>
In-Reply-To: <20171109101138.qmy3366myzjafexr@dhcp22.suse.cz>
Message-Id: <201711091922.IHJ81787.OVQFFJOSOLtHMF@I-love.SAKURA.ne.jp>
Date: Thu, 9 Nov 2017 19:22:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rostedt@goodmis.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz, peterz@infradead.org, torvalds@linux-foundation.org, jack@suse.cz, mathieu.desnoyers@efficios.com, rostedt@home.goodmis.org

Michal Hocko wrote:
> Hi,
> assuming that this passes warn stall torturing by Tetsuo, do you think
> we can drop http://lkml.kernel.org/r/1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> from the mmotm tree?

I don't think so.

The rule that "do not try to printk() faster than the kernel can write to
consoles" will remain no matter how printk() changes. Unless asynchronous
approach like https://lwn.net/Articles/723447/ is used, I think we can't
obtain useful information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
