Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8BC506B028E
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 03:30:07 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id z11so13666202pfk.23
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 00:30:07 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 33si616987plv.670.2017.11.07.00.30.05
        for <linux-mm@kvack.org>;
        Tue, 07 Nov 2017 00:30:06 -0800 (PST)
Subject: Re: possible deadlock in generic_file_write_iter
References: <94eb2c05f6a018dc21055d39c05b@google.com>
 <20171106032941.GR21978@ZenIV.linux.org.uk>
 <CACT4Y+abiKapoG9ms6RMqNkGBJtjX_Nf5WEQiYJcJ7=XCsyD2w@mail.gmail.com>
 <20171106131544.GB4359@quack2.suse.cz>
 <20171106133304.GS21978@ZenIV.linux.org.uk>
 <CACT4Y+YHPOaCVO81VPuC9hDLCSx=KJmwRf7pa3b96UAowLmA2A@mail.gmail.com>
 <20171106160107.GA20227@worktop.programming.kicks-ass.net>
 <20171107005442.GA1405@X58A-UD3R> <20171107081143.GD3326@worktop>
From: Byungchul Park <byungchul.park@lge.com>
Message-ID: <8352ad42-8437-4e25-29f4-c3b93c6eed18@lge.com>
Date: Tue, 7 Nov 2017 17:30:03 +0900
MIME-Version: 1.0
In-Reply-To: <20171107081143.GD3326@worktop>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: ko
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, syzbot <bot+f99f3a0db9007f4f4e32db54229a240c4fe57c15@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, npiggin@gmail.com, rgoldwyn@suse.com, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com, Ingo Molnar <mingo@redhat.com>, kernel-team@lge.com

11/7/2017 5:11 PMi?? Peter Zijlstra i?'(e??) i?' e,?:
> On Tue, Nov 07, 2017 at 09:54:42AM +0900, Byungchul Park wrote:
>>> The best I could come up with is something like the below; its not
>>> at all pretty and I could see people objecting; least of all myself for
>>> the __complete() thing, but I ran out of creative naming juice.
>>
>> Patches assigning a lock_class per gendisk were already applied in tip.
>> I believe that solves this.
>>
>>     e319e1fbd9d42420ab6eec0bfd75eb9ad7ca63b1
>>     block, locking/lockdep: Assign a lock_class per gendisk used for
>>     wait_for_completion()
>>
>> I think the following proposal makes kernel too hacky.
> 
> Ah, I tough this was with those included...

Please CC me for issues wrt. crossrelease.

--
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
