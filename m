Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id C47F38E0001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 15:57:43 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id p17-v6so9427742ywp.15
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 12:57:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u126-v6sor1785393ybf.201.2018.09.07.12.57.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 12:57:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <14d5bccf-f12d-0fc1-eddc-9fb24dc0cf14@I-love.SAKURA.ne.jp>
References: <000000000000e16cba057549aab6@google.com> <14d5bccf-f12d-0fc1-eddc-9fb24dc0cf14@I-love.SAKURA.ne.jp>
From: Kees Cook <keescook@google.com>
Date: Fri, 7 Sep 2018 12:57:41 -0700
Message-ID: <CAGXu5jLLYCGnN66UNeYqcPCPN4EAb=PzGLuQj4-UZr_A0AHp-g@mail.gmail.com>
Subject: Re: BUG: bad usercopy in __check_object_size (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+a3c9d2673837ccc0f22b@syzkaller.appspotmail.com>, Chris von Recklinghausen <crecklin@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>

On Fri, Sep 7, 2018 at 9:17 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> On 2018/09/08 0:29, syzbot wrote:
>> syzbot has found a reproducer for the following crash on:
>>
>> HEAD commit:    28619527b8a7 Merge git://git.kernel.org/pub/scm/linux/kern..
>> git tree:       bpf
>> console output: https://syzkaller.appspot.com/x/log.txt?x=124e64d1400000
>> kernel config:  https://syzkaller.appspot.com/x/.config?x=62e9b447c16085cf
>> dashboard link: https://syzkaller.appspot.com/bug?extid=a3c9d2673837ccc0f22b
>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=179f9cd1400000
>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=11b3e8be400000
>>
>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>> Reported-by: syzbot+a3c9d2673837ccc0f22b@syzkaller.appspotmail.com
>>
>>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>> RIP: 0033:0x440479
>> usercopy: Kernel memory overwrite attempt detected to spans multiple pages (offset 0, size 64)!
>
> Kees, is this because check_page_span() is failing to allow on-stack variable
>
>    u8 opcodes[OPCODE_BUFSIZE];
>
> which by chance crossed PAGE_SIZE boundary?

There are a lot of failure conditions for the PAGESPAN check. This
might be one (and one that I'm hoping to solve separately).

-Kees

-- 
Kees Cook
Pixel Security
