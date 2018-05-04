Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 968996B0269
	for <linux-mm@kvack.org>; Fri,  4 May 2018 12:21:07 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id t2-v6so20020174iob.23
        for <linux-mm@kvack.org>; Fri, 04 May 2018 09:21:07 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id v98-v6si14612958iov.120.2018.05.04.09.21.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 09:21:06 -0700 (PDT)
Date: Fri, 4 May 2018 18:21:02 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Introduce atomic_dec_and_lock_irqsave()
Message-ID: <20180504162102.GQ12217@hirez.programming.kicks-ass.net>
References: <20180504154533.8833-1-bigeasy@linutronix.de>
 <20180504155446.GP12217@hirez.programming.kicks-ass.net>
 <20180504160726.ikotgmd5fbix7b6b@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180504160726.ikotgmd5fbix7b6b@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org

On Fri, May 04, 2018 at 06:07:26PM +0200, Sebastian Andrzej Siewior wrote:

> do you intend to kill refcount_dec_and_lock() in the longterm?

You meant to say atomic_dec_and_lock() ? Dunno if we ever get there, but
typically dec_and_lock is fairly refcounty, but I suppose it is possible
to have !refcount users, in which case we're eternally stuck with it.

But a quick look at the sites you converted, they all appear to be true
refcounts, and would thus benefit from being converted to refcount_t.
