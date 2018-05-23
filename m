Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DEE56B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:01:32 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id w1-v6so17889315iod.1
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:01:32 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id d64-v6si2062164ite.91.2018.05.23.06.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 06:01:29 -0700 (PDT)
Date: Wed, 23 May 2018 15:01:25 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 0/8] Introduce refcount_dec_and_lock_irqsave()
Message-ID: <20180523130125.GZ12217@hirez.programming.kicks-ass.net>
References: <20180509193645.830-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509193645.830-1-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>

On Wed, May 09, 2018 at 09:36:37PM +0200, Sebastian Andrzej Siewior wrote:
> This series is a v2 of the atomic_dec_and_lock_irqsave(). Now refcount_*
> is used instead of atomic_* as suggested by Peter Zijlstra.
> 
> Patch
> - 1-3 converts the user from atomic_* API to refcount_* API
> - 4 implements refcount_dec_and_lock_irqsave
> - 5-8 converts the local_irq_save() + refcount_dec_and_lock() users to
>   refcount_dec_and_lock_irqsave()
> 
> The whole series sits also at
>   git://git.kernel.org/pub/scm/linux/kernel/git/bigeasy/staging.git refcount_t_irqsave
> 

1-2, 4-6:

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
