Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 778586B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 05:26:20 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c9-v6so12444063wrm.14
        for <linux-mm@kvack.org>; Wed, 30 May 2018 02:26:20 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b72-v6si13062323wmd.34.2018.05.30.02.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 30 May 2018 02:26:18 -0700 (PDT)
Date: Wed, 30 May 2018 11:26:14 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: Introduce atomic_dec_and_lock_irqsave()
Message-ID: <20180530092614.wch377xtjrjgovnl@linutronix.de>
References: <20180504154533.8833-1-bigeasy@linutronix.de>
 <20180523130241.GA12217@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20180523130241.GA12217@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org

On 2018-05-23 15:02:41 [+0200], Peter Zijlstra wrote:
> 1,5-6:
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

I sucked them into my try tree an noticed this off by one, I applied the
tags to 1,4-5:
*=E2=94=AC=E2=94=80>[PATCH 1/5] spinlock: atomic_dec_and_lock: Add an irqsa=
ve variant
 =E2=94=9C=E2=94=80>[PATCH 2/5] mm/backing-dev: Use irqsave variant of atom=
ic_dec_and_lock()
 =E2=94=9C=E2=94=80>[PATCH 3/5] kernel/user: Use irqsave variant of atomic_=
dec_and_lock()
*=E2=94=9C=E2=94=80>[PATCH 4/5] drivers/md/raid5: Use irqsave variant of at=
omic_dec_and_lock()
*=E2=94=9C=E2=94=80>[PATCH 5/5] drivers/md/raid5: Do not disable irq on rel=
ease_inactive_stripe_list() call

as we talked about it.

Sebastian
