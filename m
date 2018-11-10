Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BB9A6B075C
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 18:36:02 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id n68so13888999qkn.8
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 15:36:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r95si10105458qkh.131.2018.11.10.15.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Nov 2018 15:36:01 -0800 (PST)
Subject: Re: [RFC PATCH 00/12] locking/lockdep: Add a new class of terminal
 locks
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <20181109080412.GC86700@gmail.com>
 <20181110141045.GD3339@worktop.programming.kicks-ass.net>
From: Waiman Long <longman@redhat.com>
Message-ID: <dfa0a2fa-0094-3ae0-4f27-2930233132a3@redhat.com>
Date: Sat, 10 Nov 2018 18:35:57 -0500
MIME-Version: 1.0
In-Reply-To: <20181110141045.GD3339@worktop.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 11/10/2018 09:10 AM, Peter Zijlstra wrote:
> On Fri, Nov 09, 2018 at 09:04:12AM +0100, Ingo Molnar wrote:
>> BTW., if you are interested in more radical approaches to optimize 
>> lockdep, we could also add a static checker via objtool driven call graph 
>> analysis, and mark those locks terminal that we can prove are terminal.
>>
>> This would require the unified call graph of the kernel image and of all 
>> modules to be examined in a final pass, but that's within the principal 
>> scope of objtool. (This 'final pass' could also be done during bootup, at 
>> least in initial versions.)
> Something like this is needed for objtool LTO support as well. I just
> dread the build time 'regressions' this will introduce :/
>
> The final link pass is already by far the most expensive part (as
> measured in wall-time) of building a kernel, adding more work there
> would really suck :/

I think the idea is to make objtool have the capability to do that. It
doesn't mean we need to turn it on by default in every build.

Cheers,
Longman
