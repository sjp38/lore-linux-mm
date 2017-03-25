Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE4756B0343
	for <linux-mm@kvack.org>; Sat, 25 Mar 2017 14:14:05 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id c72so6839396lfh.22
        for <linux-mm@kvack.org>; Sat, 25 Mar 2017 11:14:05 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id f77si3449178lfg.388.2017.03.25.11.14.03
        for <linux-mm@kvack.org>;
        Sat, 25 Mar 2017 11:14:04 -0700 (PDT)
Date: Sat, 25 Mar 2017 19:13:44 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [locking/lockdep] 383776fa75:  INFO: trying to register
 non-static key.
Message-ID: <20170325181344.46xj4k3xsuq4xxjy@pd.tnic>
References: <58cad449.RTO+aYLdogbZs5Le%fengguang.wu@intel.com>
 <20170317134109.e7qmjwpryelpbgz2@hirez.programming.kicks-ass.net>
 <20170317144140.cpsdlpairb2falsv@linutronix.de>
 <20170320114108.kbvcsuepem45j5cr@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170320114108.kbvcsuepem45j5cr@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, kernel test robot <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, wfg@linux.intel.com

On Mon, Mar 20, 2017 at 12:41:08PM +0100, Peter Zijlstra wrote:
> Subject: lockdep: Fix per-cpu static objects
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Mon Mar 20 12:26:55 CET 2017
> 
> Since commit:
> 
>   383776fa7527 ("locking/lockdep: Handle statically initialized PER_CPU locks properly")
> 
> we try to collapse per-cpu locks into a single class by giving them
> all the same key. For this key we choose the canonical address of the
> per-cpu object, which would be the offset into the per-cpu area.
> 
> This has two problems:
> 
>  - there is a case where we run !0 lock->key through static_obj() and
>    expect this to pass; it doesn't for canonical pointers.
> 
>  - 0 is a valid canonical address.
> 
> Cure both issues by redefining the canonical address as the address of
> the per-cpu variable on the boot CPU.
> 
> Since I didn't want to rely on CPU0 being the boot-cpu, or even
> existing at all, track the boot CPU in a variable.
> 
> Fixes: 383776fa7527 ("locking/lockdep: Handle statically initialized PER_CPU locks properly")
> Reported-by: kernel test robot <fengguang.wu@intel.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Tested-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
