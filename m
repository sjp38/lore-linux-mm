Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 038E86B028A
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 03:18:23 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id e89so1361894ioi.16
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 00:18:23 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r203sor347737iod.101.2017.11.07.00.18.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 00:18:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171107081143.GD3326@worktop>
References: <94eb2c05f6a018dc21055d39c05b@google.com> <20171106032941.GR21978@ZenIV.linux.org.uk>
 <CACT4Y+abiKapoG9ms6RMqNkGBJtjX_Nf5WEQiYJcJ7=XCsyD2w@mail.gmail.com>
 <20171106131544.GB4359@quack2.suse.cz> <20171106133304.GS21978@ZenIV.linux.org.uk>
 <CACT4Y+YHPOaCVO81VPuC9hDLCSx=KJmwRf7pa3b96UAowLmA2A@mail.gmail.com>
 <20171106160107.GA20227@worktop.programming.kicks-ass.net>
 <20171107005442.GA1405@X58A-UD3R> <20171107081143.GD3326@worktop>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 7 Nov 2017 09:18:01 +0100
Message-ID: <CACT4Y+bWot0Hw-z_dCY2fKpb1JSd9u_rzSqER+_Bwy3Lnd98uQ@mail.gmail.com>
Subject: Re: possible deadlock in generic_file_write_iter
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, syzbot <bot+f99f3a0db9007f4f4e32db54229a240c4fe57c15@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, npiggin@gmail.com, rgoldwyn@suse.com, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com, Ingo Molnar <mingo@redhat.com>, kernel-team@lge.com

On Tue, Nov 7, 2017 at 9:11 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, Nov 07, 2017 at 09:54:42AM +0900, Byungchul Park wrote:
>> > The best I could come up with is something like the below; its not
>> > at all pretty and I could see people objecting; least of all myself for
>> > the __complete() thing, but I ran out of creative naming juice.
>>
>> Patches assigning a lock_class per gendisk were already applied in tip.
>> I believe that solves this.
>>
>>    e319e1fbd9d42420ab6eec0bfd75eb9ad7ca63b1
>>    block, locking/lockdep: Assign a lock_class per gendisk used for
>>    wait_for_completion()
>>
>> I think the following proposal makes kernel too hacky.
>
> Ah, I tough this was with those included...

Great. Let's tell the bot when to expect this fixed:

#syz fix: block, locking/lockdep: Assign a lock_class per gendisk used
for wait_for_completion()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
