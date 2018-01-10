Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7346B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 09:05:51 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id e2so13907564qti.3
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 06:05:51 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y24sor11609756qty.124.2018.01.10.06.05.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 06:05:50 -0800 (PST)
Date: Wed, 10 Jan 2018 06:05:47 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110132418.7080-1-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, Jan 10, 2018 at 02:24:16PM +0100, Petr Mladek wrote:
> This is the last version of Steven's console owner/waiter logic.
> Plus my proposal to hide it into 3 helper functions. It is supposed
> to keep the code maintenable.
> 
> The handshake really works. It happens about 10-times even during
> boot of a simple system in qemu with a fast console here. It is
> definitely able to avoid some softlockups. Let's see if it is
> enough in practice.
> 
> From my point of view, it is ready to go into linux-next so that
> it can get some more test coverage.
> 
> Steven's patch is the v4, see
> https://lkml.kernel.org/r/20171108102723.602216b1@gandalf.local.home

At least for now,

 Nacked-by: Tejun Heo <tj@kernel.org>

Maybe this can be a part of solution but it's really worrying how the
whole discussion around this subject is proceeding.  You guys are
trying to railroad actual problems.  Please address actual technical
problems.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
