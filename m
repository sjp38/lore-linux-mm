Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BDF26B04FC
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 06:45:24 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id 6-v6so2881356edz.10
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 03:45:24 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e7-v6si364955edj.200.2018.11.07.03.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 03:45:22 -0800 (PST)
Date: Wed, 7 Nov 2018 12:45:20 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181107114520.bi3ur2fpn62rlyje@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <42f33aae-a1d1-197f-a1d5-8c5ec88e88d1@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42f33aae-a1d1-197f-a1d5-8c5ec88e88d1@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Wed 2018-11-07 19:52:53, Tetsuo Handa wrote:
> On 2018/11/06 23:35, Sergey Senozhatsky wrote:
> > - Do not allocate seq_buf if we are in printk-safe or in printk-nmi mode.
> >   To avoid "buffering for the sake of buffering". IOW, when in printk-safe
> >   use printk-safe.
> 
> Why? Since printk_safe_flush_buffer() forcibly flushes the partial line,
> calling printk_safe_log_store() after line buffering can reduce possibility of
> flushing partial lines, can't it?

Good point.

Well, printk_safe buffers are flushed via irqwork scheduled on the
same CPU. It might get flushed prematurely from other CPU but
I am not sure if this risk is worth the double buffering.

Best Regards,
Petr
