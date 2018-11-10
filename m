Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10CDA6B027C
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 17:43:19 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b4-v6so1236725plb.3
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 14:43:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q13-v6si11684006pgq.526.2018.11.10.14.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 10 Nov 2018 14:43:17 -0800 (PST)
Date: Sat, 10 Nov 2018 15:20:23 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 07/12] locking/lockdep: Add support for nested
 terminal locks
Message-ID: <20181110142023.GG3339@worktop.programming.kicks-ass.net>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <1541709268-3766-8-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541709268-3766-8-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Nov 08, 2018 at 03:34:23PM -0500, Waiman Long wrote:
> There are use cases where we want to allow 2-level nesting of one
> terminal lock underneath another one. So the terminal lock type is now
> extended to support a new nested terminal lock where it can allow the
> acquisition of another regular terminal lock underneath it.

You're stretching things here... If you're allowing things under it, it
is no longer a terminal lock.

Why would you want to do such a thing?
