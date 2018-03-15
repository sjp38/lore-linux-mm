Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC0AE6B0007
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:23:15 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id az5-v6so3202258plb.14
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 06:23:15 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0103.outbound.protection.outlook.com. [104.47.0.103])
        by mx.google.com with ESMTPS id b3-v6si4020223pld.117.2018.03.15.06.23.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 06:23:14 -0700 (PDT)
Subject: Re: [PATCH] Improve mutex documentation
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
 <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
 <20180315115812.GA9949@bombadil.infradead.org>
 <2397831d-71b5-3cc8-9dc4-ce06e2eddfde@virtuozzo.com>
 <20180315131832.GC9949@bombadil.infradead.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <053b66a4-ce68-fe00-ef06-e09a3b14d524@virtuozzo.com>
Date: Thu, 15 Mar 2018 16:23:09 +0300
MIME-Version: 1.0
In-Reply-To: <20180315131832.GC9949@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Mauro Carvalho Chehab <mchehab@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>

On 15.03.2018 16:18, Matthew Wilcox wrote:
> On Thu, Mar 15, 2018 at 03:12:30PM +0300, Kirill Tkhai wrote:
>>> +/**
>>> + * mutex_lock_killable() - Acquire the mutex, interruptible by fatal signals.
>>
>> Shouldn't we clarify that fatal signals are SIGKILL only?
> 
> It's more complicated than it might seem (... welcome to signal handling!)
> If you send SIGINT to a task that's waiting on a mutex_killable(), it will
> still die.  I *think* that's due to the code in complete_signal():
> 
>         if (sig_fatal(p, sig) &&
>             !(signal->flags & SIGNAL_GROUP_EXIT) &&
>             !sigismember(&t->real_blocked, sig) &&
>             (sig == SIGKILL || !p->ptrace)) {
> ...
>                                 sigaddset(&t->pending.signal, SIGKILL);
> 
> You're correct that this code only checks for SIGKILL, but any fatal
> signal will result in the signal group receiving SIGKILL.
> 
> Unless I've misunderstood, and it wouldn't be the first time I've
> misunderstood signal handling.

Sure, thanks for the explanation.

Kirill
