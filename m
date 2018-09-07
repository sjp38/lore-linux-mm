Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2E26B7F39
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 12:18:36 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a8-v6so7327328pla.10
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 09:18:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id b1-v6si8778622pli.54.2018.09.07.09.18.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 09:18:35 -0700 (PDT)
Subject: Re: BUG: bad usercopy in __check_object_size (2)
References: <000000000000e16cba057549aab6@google.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <14d5bccf-f12d-0fc1-eddc-9fb24dc0cf14@I-love.SAKURA.ne.jp>
Date: Sat, 8 Sep 2018 01:17:44 +0900
MIME-Version: 1.0
In-Reply-To: <000000000000e16cba057549aab6@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, keescook@google.com
Cc: syzbot <syzbot+a3c9d2673837ccc0f22b@syzkaller.appspotmail.com>, crecklin@redhat.com, dvyukov@google.com, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, mingo@redhat.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, x86@kernel.org

On 2018/09/08 0:29, syzbot wrote:
> syzbot has found a reproducer for the following crash on:
> 
> HEAD commit:A A A  28619527b8a7 Merge git://git.kernel.org/pub/scm/linux/kern..
> git tree:A A A A A A  bpf
> console output: https://syzkaller.appspot.com/x/log.txt?x=124e64d1400000
> kernel config:A  https://syzkaller.appspot.com/x/.config?x=62e9b447c16085cf
> dashboard link: https://syzkaller.appspot.com/bug?extid=a3c9d2673837ccc0f22b
> compiler:A A A A A A  gcc (GCC) 8.0.1 20180413 (experimental)
> syz repro:A A A A A  https://syzkaller.appspot.com/x/repro.syz?x=179f9cd1400000
> C reproducer:A A  https://syzkaller.appspot.com/x/repro.c?x=11b3e8be400000
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+a3c9d2673837ccc0f22b@syzkaller.appspotmail.com
> 
> A entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x440479
> usercopy: Kernel memory overwrite attempt detected to spans multiple pages (offset 0, size 64)!

Kees, is this because check_page_span() is failing to allow on-stack variable

   u8 opcodes[OPCODE_BUFSIZE];

which by chance crossed PAGE_SIZE boundary?
