Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2796B003A
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 17:16:06 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id r10so3944855pdi.20
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 14:16:05 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id qs6si1796254pbc.21.2014.08.06.14.16.04
        for <linux-mm@kvack.org>;
        Wed, 06 Aug 2014 14:16:05 -0700 (PDT)
Date: Wed, 06 Aug 2014 14:16:03 -0700 (PDT)
Message-Id: <20140806.141603.1422005306896590750.davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/7] nested sleeps, fixes and debug infra
From: David Miller <davem@davemloft.net>
In-Reply-To: <20140806083134.GQ9918@twins.programming.kicks-ass.net>
References: <20140805130646.GZ19379@twins.programming.kicks-ass.net>
	<CALFYKtAVQ9Rgu_QWCqUkNHk4-wbiVK0FeiwLDttaxZC5bnnG5w@mail.gmail.com>
	<20140806083134.GQ9918@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org
Cc: ilya.dryomov@inktank.com, mingo@kernel.org, oleg@redhat.com, torvalds@linux-foundation.org, tglx@linutronix.de, umgwanakikbuti@gmail.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org

From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 6 Aug 2014 10:31:34 +0200

> On Wed, Aug 06, 2014 at 11:51:29AM +0400, Ilya Dryomov wrote:
> 
>> OK, this one is a bit different.
>> 
>> WARNING: CPU: 1 PID: 1744 at kernel/sched/core.c:7104 __might_sleep+0x58/0x90()
>> do not call blocking ops when !TASK_RUNNING; state=1 set at [<ffffffff81070e10>] prepare_to_wait+0x50 /0xa0
> 
>>  [<ffffffff8105bc38>] __might_sleep+0x58/0x90
>>  [<ffffffff8148c671>] lock_sock_nested+0x31/0xb0
>>  [<ffffffff81498aaa>] sk_stream_wait_memory+0x18a/0x2d0
> 
> Urgh, tedious. Its not an actual bug as is. Due to the condition check
> in sk_wait_event() we can call lock_sock() with ->state != TASK_RUNNING.
> 
> I'm not entirely sure what the cleanest way is to make this go away.
> Possibly something like so:

If you submit this formally to netdev with a signoff I'm willing to apply
this if it helps the debug infrastructure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
