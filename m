Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 31DDA6B0005
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:02:45 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bd7-v6so14203694plb.20
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:02:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d5-v6si14889163pgc.150.2018.05.23.06.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 06:02:43 -0700 (PDT)
Date: Wed, 23 May 2018 15:02:41 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Introduce atomic_dec_and_lock_irqsave()
Message-ID: <20180523130241.GA12217@hirez.programming.kicks-ass.net>
References: <20180504154533.8833-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180504154533.8833-1-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org

On Fri, May 04, 2018 at 05:45:28PM +0200, Sebastian Andrzej Siewior wrote:
> This series introduces atomic_dec_and_lock_irqsave() and converts a few
> users to use it. They were using local_irq_save() +
> atomic_dec_and_lock() before that series.

1,5-6:

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
