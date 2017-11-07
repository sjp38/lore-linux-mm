Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17BD66B0286
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 03:12:04 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id f20so1397840ioj.2
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 00:12:04 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m13si849150iti.12.2017.11.07.00.12.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 00:12:03 -0800 (PST)
Date: Tue, 7 Nov 2017 09:11:43 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in generic_file_write_iter
Message-ID: <20171107081143.GD3326@worktop>
References: <94eb2c05f6a018dc21055d39c05b@google.com>
 <20171106032941.GR21978@ZenIV.linux.org.uk>
 <CACT4Y+abiKapoG9ms6RMqNkGBJtjX_Nf5WEQiYJcJ7=XCsyD2w@mail.gmail.com>
 <20171106131544.GB4359@quack2.suse.cz>
 <20171106133304.GS21978@ZenIV.linux.org.uk>
 <CACT4Y+YHPOaCVO81VPuC9hDLCSx=KJmwRf7pa3b96UAowLmA2A@mail.gmail.com>
 <20171106160107.GA20227@worktop.programming.kicks-ass.net>
 <20171107005442.GA1405@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171107005442.GA1405@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, syzbot <bot+f99f3a0db9007f4f4e32db54229a240c4fe57c15@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, npiggin@gmail.com, rgoldwyn@suse.com, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com, Ingo Molnar <mingo@redhat.com>, kernel-team@lge.com

On Tue, Nov 07, 2017 at 09:54:42AM +0900, Byungchul Park wrote:
> > The best I could come up with is something like the below; its not
> > at all pretty and I could see people objecting; least of all myself for
> > the __complete() thing, but I ran out of creative naming juice.
> 
> Patches assigning a lock_class per gendisk were already applied in tip.
> I believe that solves this.
> 
>    e319e1fbd9d42420ab6eec0bfd75eb9ad7ca63b1
>    block, locking/lockdep: Assign a lock_class per gendisk used for
>    wait_for_completion()
> 
> I think the following proposal makes kernel too hacky.

Ah, I tough this was with those included...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
