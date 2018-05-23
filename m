Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B70146B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:09:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v12-v6so2355278wmc.1
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:09:39 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 142-v6si1760997wme.14.2018.05.23.06.09.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 06:09:37 -0700 (PDT)
Date: Wed, 23 May 2018 15:09:27 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH v2 0/8] Introduce refcount_dec_and_lock_irqsave()
Message-ID: <20180523130927.qhblygmszkp4iwne@linutronix.de>
References: <20180509193645.830-1-bigeasy@linutronix.de>
 <20180523130125.GZ12217@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180523130125.GZ12217@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>

On 2018-05-23 15:01:25 [+0200], Peter Zijlstra wrote:
> 1-2, 4-6:
> 
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Thank you.

Sebastian
