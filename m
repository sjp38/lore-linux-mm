Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0B46B0005
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 10:40:40 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 18-v6so1832983pgn.4
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 07:40:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a17-v6si28752306pgf.443.2018.11.02.07.40.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 02 Nov 2018 07:40:39 -0700 (PDT)
Date: Fri, 2 Nov 2018 07:40:28 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181102144028.GQ10491@bombadil.infradead.org>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Fri, Nov 02, 2018 at 10:31:55PM +0900, Tetsuo Handa wrote:
>   get_printk_buffer() tries to assign a "struct printk_buffer" from
>   statically preallocated array. get_printk_buffer() returns NULL if
>   all "struct printk_buffer" are in use, but the caller does not need to
>   check for NULL.

This seems like a great way of wasting 16kB of memory.  Since you've
already made printk_buffered() work with a NULL initial argument, what's
the advantage over just doing kmalloc(1024, GFP_ATOMIC)?
