Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 09DC66B02E4
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 04:05:51 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id l2-v6so11077681pgp.22
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 01:05:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g31-v6sor14838668pgg.8.2018.11.06.01.05.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 01:05:49 -0800 (PST)
Date: Tue, 6 Nov 2018 18:05:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181106090544.GA516@jagdpanzerIV>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181102133629.GN3178@hirez.programming.kicks-ass.net>
 <20181106083856.lhmibz6vrgtkqsj7@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106083856.lhmibz6vrgtkqsj7@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>

On (11/06/18 09:38), Petr Mladek wrote:
> 
> If you would want to avoid buffering, you could set the number
> of buffers to zero. Then it would always fallback to
> the direct printk().

This printk-fallback makes me wonder if 'cont' really can ever go away.
We would totally break cont printk-s that trapped into printk-fallback;
as opposed to current sometimes-cont-works-just-fine.

	-ss
