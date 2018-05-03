Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EAC5D6B000E
	for <linux-mm@kvack.org>; Thu,  3 May 2018 00:27:38 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f19-v6so11416893pgv.4
        for <linux-mm@kvack.org>; Wed, 02 May 2018 21:27:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u89si13292904pfa.234.2018.05.02.21.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 21:27:37 -0700 (PDT)
Date: Wed, 2 May 2018 21:27:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [lkp-robot] 486ad79630 [   15.532543] BUG: unable to handle
 kernel NULL pointer dereference at 0000000000000004
Message-Id: <20180502212735.7660515ac03cf61630f5ff6b@linux-foundation.org>
In-Reply-To: <20180503041450.pq2njvkssxtay64o@shao2-debian>
References: <20180503041450.pq2njvkssxtay64o@shao2-debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <lkp@intel.com>
Cc: kernel test robot <shun.hao@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, LKP <lkp@01.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>


(networking cc's added)

On Thu, 3 May 2018 12:14:50 +0800 kernel test robot <shun.hao@intel.com> wrote:

> Greetings,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> git://git.cmpxchg.org/linux-mmotm.git master
> 
> commit 486ad79630d0ba0b7205a8db9fe15ba392f5ee32
> Author:     Andrew Morton <akpm@linux-foundation.org>
> AuthorDate: Fri Apr 20 22:00:53 2018 +0000
> Commit:     Johannes Weiner <hannes@cmpxchg.org>
> CommitDate: Fri Apr 20 22:00:53 2018 +0000
> 
>     origin


OK, this got confusing.  origin.patch is the diff between 4.17-rc3 and
current mainline.

>
> [many lines deleted]
>
> [main] Setsockopt(101 c 1b24000 a) on fd 177 [3:5:240]
> [main] Setsockopt(1 2c 1b24000 4) on fd 178 [5:2:0]
> [main] Setsockopt(29 8 1b24000 4) on fd 180 [10:1:0]
> [main] Setsockopt(1 20 1b24000 4) on fd 181 [26:2:125]
> [main] Setsockopt(11 1 1b24000 4) on fd 183 [2:2:17]
> [   15.532543] BUG: unable to handle kernel NULL pointer dereference at 0000000000000004
> [   15.534143] PGD 800000001734b067 P4D 800000001734b067 PUD 17350067 PMD 0 
> [   15.535516] Oops: 0002 [#1] PTI
> [   15.536165] Modules linked in:
> [   15.536798] CPU: 0 PID: 363 Comm: trinity-main Not tainted 4.17.0-rc1-00001-g486ad79 #2
> [   15.538396] RIP: 0010:llc_ui_release+0x3a/0xd0
> [   15.539293] RSP: 0018:ffffc9000015bd70 EFLAGS: 00010202
> [   15.540345] RAX: 0000000000000001 RBX: ffff88001fa60008 RCX: 0000000000000006
> [   15.541802] RDX: 0000000000000006 RSI: ffff88001fdda660 RDI: ffff88001fa60008
> [   15.543139] RBP: ffffc9000015bd80 R08: 0000000000000000 R09: 0000000000000000
> [   15.544725] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> [   15.546287] R13: ffff88001fa61730 R14: ffff88001e130a60 R15: ffff880019bdb3f0
> [   15.547962] FS:  00007f2221bb1700(0000) GS:ffffffff82034000(0000) knlGS:0000000000000000
> [   15.549848] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   15.551186] CR2: 0000000000000004 CR3: 000000001734e000 CR4: 00000000000006b0
> [   15.552671] DR0: 0000000002232000 DR1: 0000000000000000 DR2: 0000000000000000
> [   15.554105] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> [   15.555534] Call Trace:
> [   15.556049]  sock_release+0x14/0x60
> [   15.556767]  sock_close+0xd/0x20
> [   15.557427]  __fput+0xba/0x1f0
> [   15.558058]  ____fput+0x9/0x10
> [   15.558682]  task_work_run+0x73/0xa0
> [   15.559416]  do_exit+0x231/0xab0
> [   15.560079]  do_group_exit+0x3f/0xc0
> [   15.560810]  __x64_sys_exit_group+0x13/0x20
> [   15.561656]  do_syscall_64+0x58/0x2f0
> [   15.562407]  ? trace_hardirqs_off_thunk+0x1a/0x1c
> [   15.563360]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [   15.564471] RIP: 0033:0x7f2221696408
> [   15.565264] RSP: 002b:00007ffe5c544c48 EFLAGS: 00000206 ORIG_RAX: 00000000000000e7
> [   15.566924] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f2221696408
> [   15.568485] RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
> [   15.570046] RBP: 0000000000000000 R08: 00000000000000e7 R09: ffffffffffffffa0
> [   15.571603] R10: 00007ffe5c5449e0 R11: 0000000000000206 R12: 0000000000000004
> [   15.573160] R13: 00007ffe5c544e30 R14: 0000000000000000 R15: 0000000000000000
> [   15.574720] Code: 7b ff 43 78 0f 88 a5 6f 14 00 31 f6 48 89 df e8 ad 33 fb ff 48 89 df e8 55 94 ff ff 85 c0 0f 84 84 00 00 00 4c 8b a3 d8 04 00 00 <41> ff 44 24 04 0f 88 7f 6f 14 00 48 8b 43 58 f6 c4 01 74 58 48 
> [   15.578679] RIP: llc_ui_release+0x3a/0xd0 RSP: ffffc9000015bd70
> [   15.579874] CR2: 0000000000000004
> [   15.580553] ---[ end trace 0dd8fdc6b7182234 ]---
>

So it's saying that something which got committed into Linus's tree
after 4.17-rc3 has caused a NULL deref in
sock_release->llc_ui_release+0x3a/0xd0
