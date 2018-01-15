Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B67C6B0069
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 09:01:01 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w186so7776623pgb.10
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 06:01:01 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p3sor4602670pgs.373.2018.01.15.06.01.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 06:01:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201801152256.HDH17623.tSJHFLFOFMVOQO@I-love.SAKURA.ne.jp>
References: <CACT4Y+ZPHerom6rNYj8HL8vSySi7n4ArySnpFbxQX31n-QumNg@mail.gmail.com>
 <201801081948.HAE82801.FQOSHtMOFVLFOJ@I-love.SAKURA.ne.jp>
 <CACT4Y+bkuk3dkwdn7QCbWWWJ=R_nW8Qi6+y35VofLEHYu+6m7w@mail.gmail.com>
 <201801151944.FII09821.FMVQFJtHOOOSLF@I-love.SAKURA.ne.jp>
 <CACT4Y+ZE_7wuJV1V8J+zO2E+CKp8wpCsVfUMqCLXazmjrCRrUQ@mail.gmail.com> <201801152256.HDH17623.tSJHFLFOFMVOQO@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 15 Jan 2018 15:00:39 +0100
Message-ID: <CACT4Y+Z2d6aV86rj5OYiv5Xw=D9xi=vW7RpdzP2X+vTnUjFqfQ@mail.gmail.com>
Subject: Re: INFO: task hung in filemap_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, Jens Axboe <axboe@kernel.dk>, Ming Lei <tom.leiming@gmail.com>, Hannes Reinecke <hare@suse.de>, Omar Sandoval <osandov@fb.com>, shli@fb.com

On Mon, Jan 15, 2018 at 2:56 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Dmitry Vyukov wrote:
>> > No problem. In the "tty: User triggerable soft lockup." case, I manually
>> > trimmed the reproducer at https://marc.info/?l=linux-mm&m=151368630414963 .
>> > That is,
>> >
>> >  (1) Can the problem be reproduced even if setup_tun(0, true); is commented out?
>> >
>> >  (2) Can the problem be reproduced even if NONFAILING(A = B); is replaced with
>> >      plain A = B; assignment?
>> >
>> >  (3) Can the problem be reproduced even if install_segv_handler(); is commented
>> >      out?
>> >
>> >  (4) Can the problem be reproduced even if some syscalls (e.g. __NR_memfd_create,
>> >      __NR_getsockopt, __NR_perf_event_open) are replaced with no-op?
>> >
>> > and so on. Then, I finally reached a reproducer which I sent, and the bug was fixed.
>> >
>> > What is important is that everyone can try simplifying the reproducer written
>> > in plain C in order to narrow down the culprit. Providing a (e.g.) CGI service
>> > which generates plain C reproducer like gistfile1.txt will be helpful to me.
>>
>> I am not completely following. You previously mentioned raw.log, which
>> is a collection of multiple programs, but now you seem to be talking
>> about a single reproducer. When syzbot manages to reproduce the bug
>> only with syzkaller program but not with a corresponding C program, it
>> provides only syzkaller program. It such case it can sense to convert.
>> But the case you pointed to actually contains C program. So there is
>> no need to do the conversion at all... What am I missing?
>>
>
> raw.log is not readable for me.
> I want to see C program even if syzbot did not manage to reproduce the bug.
> If C program is available, everyone can try reproducing the bug with manually
> trimmed C program.

If it did not manage to reproduce the bug, there is no C program.
There is no program at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
