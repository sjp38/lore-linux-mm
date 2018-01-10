Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 398696B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 08:24:33 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z24so11387145pgu.20
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 05:24:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y5si5535759plr.470.2018.01.10.05.24.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Jan 2018 05:24:31 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Date: Wed, 10 Jan 2018 14:24:16 +0100
Message-Id: <20180110132418.7080-1-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

This is the last version of Steven's console owner/waiter logic.
Plus my proposal to hide it into 3 helper functions. It is supposed
to keep the code maintenable.

The handshake really works. It happens about 10-times even during
boot of a simple system in qemu with a fast console here. It is
definitely able to avoid some softlockups. Let's see if it is
enough in practice.

>From my point of view, it is ready to go into linux-next so that
it can get some more test coverage.

Steven's patch is the v4, see
https://lkml.kernel.org/r/20171108102723.602216b1@gandalf.local.home

Petr Mladek (1):
  printk: Hide console waiter logic into helpers

Steven Rostedt (1):
  printk: Add console owner and waiter logic to load balance console
    writes

 kernel/printk/printk.c | 156 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 155 insertions(+), 1 deletion(-)

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
