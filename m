Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D12D6B7FC0
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 04:22:02 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s22so2160133pgv.8
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 01:22:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p8si2507003pls.83.2018.12.07.01.22.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Dec 2018 01:22:01 -0800 (PST)
Date: Fri, 7 Dec 2018 10:21:56 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 07/17] debugobjects: Move printk out of db lock
 critical sections
Message-ID: <20181207092156.GE2237@hirez.programming.kicks-ass.net>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-8-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542653726-5655-8-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Nov 19, 2018 at 01:55:16PM -0500, Waiman Long wrote:
> The db->lock is a raw spinlock and so the lock hold time is supposed
> to be short. This will not be the case when printk() is being involved
> in some of the critical sections. In order to avoid the long hold time,
> in case some messages need to be printed, the debug_object_is_on_stack()
> and debug_print_object() calls are now moved out of those critical
> sections.

That's not why you did this patch though; you want to make these locks
terminal locks and that means no printk() inside, as that uses locks
again.

Please write relevant changelogs.
