Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A91F6B0763
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 19:28:05 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id w185so14570061qka.9
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 16:28:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s12si2501223qtn.255.2018.11.10.16.28.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Nov 2018 16:28:04 -0800 (PST)
Subject: Re: [RFC PATCH 02/12] locking/lockdep: Add a new terminal lock type
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <1541709268-3766-3-git-send-email-longman@redhat.com>
 <20181110141734.GF3339@worktop.programming.kicks-ass.net>
From: Waiman Long <longman@redhat.com>
Message-ID: <7294253b-a928-4bf6-8bf5-73d532ca0a7e@redhat.com>
Date: Sat, 10 Nov 2018 19:28:01 -0500
MIME-Version: 1.0
In-Reply-To: <20181110141734.GF3339@worktop.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/10/2018 09:17 AM, Peter Zijlstra wrote:
> On Thu, Nov 08, 2018 at 03:34:18PM -0500, Waiman Long wrote:
>> A terminal lock is a lock where further locking or unlocking on another
>> lock is not allowed. IOW, no forward dependency is permitted.
>>
>> With such a restriction in place, we don't really need to do a full
>> validation of the lock chain involving a terminal lock.  Instead,
>> we just check if there is any further locking or unlocking on another
>> lock when a terminal lock is being held.
>> @@ -263,6 +270,7 @@ struct held_lock {
>>  	unsigned int hardirqs_off:1;
>>  	unsigned int references:12;					/* 32 bits */
>>  	unsigned int pin_count;
>> +	unsigned int flags;
>>  };
> I'm thinking we can easily steal some bits off of the pin_count field if
> we have to.

OK, I will take a look at that.

Cheers,
Longman
