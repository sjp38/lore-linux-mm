Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC586B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 12:07:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q67-v6so2014001wrb.12
        for <linux-mm@kvack.org>; Fri, 04 May 2018 09:07:30 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id e81si1564532wmi.124.2018.05.04.09.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 04 May 2018 09:07:29 -0700 (PDT)
Date: Fri, 4 May 2018 18:07:26 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: Introduce atomic_dec_and_lock_irqsave()
Message-ID: <20180504160726.ikotgmd5fbix7b6b@linutronix.de>
References: <20180504154533.8833-1-bigeasy@linutronix.de>
 <20180504155446.GP12217@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180504155446.GP12217@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org

On 2018-05-04 17:54:46 [+0200], Peter Zijlstra wrote:
> On Fri, May 04, 2018 at 05:45:28PM +0200, Sebastian Andrzej Siewior wrote:
> > This series introduces atomic_dec_and_lock_irqsave() and converts a few
> > users to use it. They were using local_irq_save() +
> > atomic_dec_and_lock() before that series.
> 
> Should not all these users be converted to refcount_t, and thus, should
> we not introduce refcount_dec_and_lock_irqsave() instead?

do you intend to kill refcount_dec_and_lock() in the longterm?
I haz this but instead we do
- atomic_dec_and_lock() -> refcount_dec_and_lock()
- add refcount_dec_and_lock_irqsave()
- patch 2+ use refcount_dec_and_lock_irqsave().

Sebastian
