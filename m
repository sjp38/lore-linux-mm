Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D46786B0047
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 05:08:28 -0400 (EDT)
Received: by pvc7 with SMTP id 7so953754pvc.14
        for <linux-mm@kvack.org>; Mon, 27 Sep 2010 02:08:28 -0700 (PDT)
Date: Mon, 27 Sep 2010 17:12:58 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 0/3] Generic support for revoking mappings
Message-ID: <20100927091258.GF5785@cr0.nay.redhat.com>
References: <m1sk0x9z62.fsf@fess.ebiederm.org>
 <1933893701.2026841285577549772.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1933893701.2026841285577549772.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 27, 2010 at 04:52:29AM -0400, CAI Qian wrote:
>Just a head up. Tried to boot latest mmotm kernel with those patches applied hit this. I am wondering what I did wrong.
>

You missed the header of this oops/warning/bug, is that a BUG_ON or WARN_ON or other thing?


>Pid: 1, comm: init Not tainted 2.6.36-rc5-mm1+ #2 /KVM
>RIP: 0010:[<ffffffff811d4c78>]  [<ffffffff811d4c78>] prio_tree_insert+0x188/0x2a0
>RSP: 0018:ffff880c3b1bfcd8  EFLAGS: 00010202
>RAX: ffff880c374b40d8 RBX: 0000000000000100 RCX: ffff880c374b40d8
>RDX: 0000000000000179 RSI: 0000000000000000 RDI: 0000000000000179
>RBP: ffff880c9f4ba188 R08: 0000000000000001 R09: ffff880c374b9330
>R10: 0000000000000001 R11: 0000000000000002 R12: ffff880c374b40d8
>R13: 00000007fa7367ba R14: 00000007fa7367be R15: 0000000000000000
>FS:  00007fa7369d9700(0000) GS:ffff8800df540000(0000) knlGS:0000000000000000
>CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>CR2: ffffffffffffffc0 CR3: 0000000c374b1000 CR4: 00000000000006e0
>DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>Process init (pid: 1, threadinfo ffff880c3b1be000, task ffff880c3b1bd400)
>Stack:
> ffff880c3b1bd400 ffff880c374b4088 ffff880c374b40d8 ffff880c374b4088
><0> ffff880c9f4ba168 ffff880c9f4ba188 ffff880c374b3680 ffffffff810daff8
><0> 0000000000000002 ffff880c374b41f8 ffff880c374b42b0 ffffffff810e9171
>Call Trace:
> [<ffffffff810daff8>] ? vma_prio_tree_insert+0x28/0x120
> [<ffffffff810e9171>] ? vma_adjust+0xe1/0x560
> [<ffffffff8119715b>] ? avc_has_perm+0x6b/0xa0
> [<ffffffff810e97b9>] ? __split_vma+0x1c9/0x250
> [<ffffffff810ebf88>] ? mprotect_fixup+0x708/0x7b0
> [<ffffffff810e4aca>] ? handle_mm_fault+0x1da/0xcf0
> [<ffffffff81033910>] ? pvclock_clocksource_read+0x50/0xc0
> [<ffffffff81047220>] ? __dequeue_entity+0x40/0x50
> [<ffffffff81198a31>] ? file_has_perm+0xf1/0x100
> [<ffffffff810ec1b2>] ? sys_mprotect+0x182/0x250
> [<ffffffff8100aec2>] ? system_call_fastpath+0x16/0x1b
>Code: 56 20 e9 d4 fe ff ff bb 01 00 00 00 48 d3 e3 48 85 db 0f 84 08 01 00 00 45 31 ff 66 45 85 c0 4c 89 e1 74 78 0f 1f 80 00 00 00 00 <48> 8b 46 c0 48 2b 46 b8 4c 8b 6e 40 48 c1 e8 0c 4c 39 ef 4d 8d 
>RIP  [<ffffffff811d4c78>] prio_tree_insert+0x188/0x2a0
> RSP <ffff880c3b1bfcd8>
>CR2: ffffffffffffffc0
>---[ end trace 667258bb79b38e02 ]---
>

Looks like something wrong in page fault.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
