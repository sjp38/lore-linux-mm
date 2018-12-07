Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C91626B7FEA
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 04:52:22 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id n17so2841517pfk.23
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 01:52:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x187si2571640pgx.241.2018.12.07.01.52.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Dec 2018 01:52:21 -0800 (PST)
Date: Fri, 7 Dec 2018 10:52:17 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 08/17] locking/lockdep: Add support for nestable
 terminal locks
Message-ID: <20181207095217.GA5307@hirez.programming.kicks-ass.net>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-9-git-send-email-longman@redhat.com>
 <20181207092252.GF2237@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181207092252.GF2237@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Dec 07, 2018 at 10:22:52AM +0100, Peter Zijlstra wrote:
> On Mon, Nov 19, 2018 at 01:55:17PM -0500, Waiman Long wrote:
> > There are use cases where we want to allow nesting of one terminal lock
> > underneath another terminal-like lock. That new lock type is called
> > nestable terminal lock which can optionally allow the acquisition of
> > no more than one regular (non-nestable) terminal lock underneath it.
> 
> I think I asked for a more coherent changelog on this. The above is
> still self contradictory and doesn't explain why you'd ever want such a
> 'misfeature' :-)

So maybe call the thing penterminal (contraction of penultimate and
terminal) locks and explain why this annotation is safe -- in great
detail.
