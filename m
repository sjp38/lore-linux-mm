Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 66F5D6B0768
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 19:30:58 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 98so14276789qkp.22
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 16:30:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m2si9134095qvi.187.2018.11.10.16.30.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Nov 2018 16:30:57 -0800 (PST)
Subject: Re: [RFC PATCH 07/12] locking/lockdep: Add support for nested
 terminal locks
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <1541709268-3766-8-git-send-email-longman@redhat.com>
 <20181110142023.GG3339@worktop.programming.kicks-ass.net>
From: Waiman Long <longman@redhat.com>
Message-ID: <f3fc6819-175b-6452-4705-942a82d7e06f@redhat.com>
Date: Sat, 10 Nov 2018 19:30:54 -0500
MIME-Version: 1.0
In-Reply-To: <20181110142023.GG3339@worktop.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/10/2018 09:20 AM, Peter Zijlstra wrote:
> On Thu, Nov 08, 2018 at 03:34:23PM -0500, Waiman Long wrote:
>> There are use cases where we want to allow 2-level nesting of one
>> terminal lock underneath another one. So the terminal lock type is now
>> extended to support a new nested terminal lock where it can allow the
>> acquisition of another regular terminal lock underneath it.
> You're stretching things here... If you're allowing things under it, it
> is no longer a terminal lock.
>
> Why would you want to do such a thing?

A majority of the gain in debugobjects is to make the hash lock a kind
of terminal lock. Yes, I may be stretching it a bit here. I will take
back the nesting patch and consider doing that in a future patch.

Cheers,
Longman
