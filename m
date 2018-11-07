Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A865B6B050A
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 09:06:04 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id p25-v6so4213699eds.15
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 06:06:04 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2-v6si475174ejx.251.2018.11.07.06.06.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 06:06:03 -0800 (PST)
Date: Wed, 7 Nov 2018 15:06:01 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181107140601.53y5vlubtugeczyt@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Fri 2018-11-02 22:31:55, Tetsuo Handa wrote:
> How to use this API:
> 
>   (1) Call get_printk_buffer() and acquire "struct printk_buffer *".
> 
>   (2) Rewrite printk() calls in the following way. The "ptr" is
>       "struct printk_buffer *" obtained in step (1).
> 
>       printk(fmt, ...)     => printk_buffered(ptr, fmt, ...)
>       vprintk(fmt, args)   => vprintk_buffered(ptr, fmt, args)
>       pr_emerg(fmt, ...)   => bpr_emerg(ptr, fmt, ...)
>       pr_alert(fmt, ...)   => bpr_alert(ptr, fmt, ...)
>       pr_crit(fmt, ...)    => bpr_crit(ptr, fmt, ...)
>       pr_err(fmt, ...)     => bpr_err(ptr, fmt, ...)
>       pr_warning(fmt, ...) => bpr_warning(ptr, fmt, ...)
>       pr_warn(fmt, ...)    => bpr_warn(ptr, fmt, ...)
>       pr_notice(fmt, ...)  => bpr_notice(ptr, fmt, ...)
>       pr_info(fmt, ...)    => bpr_info(ptr, fmt, ...)
>       pr_cont(fmt, ...)    => bpr_cont(ptr, fmt, ...)

I am looking at the sample conversions. We actually won't need
bpr_cont(). We will use buffer_printk() instead.

Well, I think about renaming buffer_printk() to bprintk() or
define it as a wrapper at least.

Best Regards,
Petr
