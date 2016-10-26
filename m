Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 60EBE6B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 17:01:54 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i128so706200wme.2
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 14:01:54 -0700 (PDT)
Received: from mx3-phx2.redhat.com (mx3-phx2.redhat.com. [209.132.183.24])
        by mx.google.com with ESMTPS id y8si12671010wme.140.2016.10.26.14.01.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Oct 2016 14:01:53 -0700 (PDT)
Date: Wed, 26 Oct 2016 17:01:24 -0400 (EDT)
From: Bob Peterson <rpeterso@redhat.com>
Message-ID: <1731570270.13088320.1477515684152.JavaMail.zimbra@redhat.com>
In-Reply-To: <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com> <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com> <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com> <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com> <CA+55aFyRv0YttbLUYwDem=-L5ZAET026umh6LOUQ6hWaRur_VA@mail.gmail.com> <996124132.13035408.1477505043741.JavaMail.zimbra@redhat.com> <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

----- Original Message -----
| On Wed, Oct 26, 2016 at 11:04 AM, Bob Peterson <rpeterso@redhat.com> wrote:
| >
| > I can test it for you, if you give me about an hour.
| 
| I can definitely wait an hour, it would be lovely to see more testing.
| Especially if you have a NUMA machine and an interesting workload.
| 
| And if you actually have that NUMA machine and a load that shows the
| page_waietutu effects, it would also be lovely if you can then
| _additionally_ test the patch that PeterZ wrote a few weeks ago, it
| was on the mm list about a month ago:
| 
|   Date: Thu, 29 Sep 2016 15:08:27 +0200
|   From: Peter Zijlstra <peterz@infradead.org>
|   Subject: Re: page_waitqueue() considered harmful
|   Message-ID: <20160929130827.GX5016@twins.programming.kicks-ass.net>
| 
| and if you don't find it I can forward it to you (Peter had a few
| versions, that latest one is the one that looked best).
| 
|                 Linus
| 

Hm. It didn't even boot, at least on my amd box in the lab.
I've made no attempt to debug this.

[    2.368403] NetLabel:  unlabeled traffic allowed by default
[    2.374271] ------------[ cut here ]------------
[    2.378877] kernel BUG at arch/x86/mm/physaddr.c:26!
[    2.383829] invalid opcode: 0000 [#1] SMP
[    2.387826] Modules linked in:
[    2.390882] CPU: 11 PID: 1 Comm: swapper/0 Not tainted 4.9.0-rc2+ #1
[    2.397219] Hardware name: Dell Inc. PowerEdge R815/06JC9T, BIOS 1.2.1 08/02/2010
[    2.404683] task: ffff947136548000 task.stack: ffffb36043130000
[    2.410588] RIP: 0010:[<ffffffffbe06848c>]  [<ffffffffbe06848c>] __phys_addr+0x3c/0x50
[    2.418500] RSP: 0018:ffffb36043133e10  EFLAGS: 00010287
[    2.423798] RAX: fffff39132a822fc RBX: 0000000000000000 RCX: 0000000000000000
[    2.430915] RDX: ffffffff00000001 RSI: 0000000000000000 RDI: ffff8800b2a822fc
[    2.438032] RBP: ffffb36043133e10 R08: ffff9475364026f8 R09: 0000000000000000
[    2.445151] R10: 0000000000000004 R11: 0000000000000000 R12: ffffffffbef8ce3d
[    2.452269] R13: ffffffffbf0e0428 R14: ffffffffbef7a8cd R15: 0000000000000000
[    2.459387] FS:  0000000000000000(0000) GS:ffff94773fa40000(0000) knlGS:0000000000000000
[    2.467458] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    2.473188] CR2: 0000000000000000 CR3: 000000057de07000 CR4: 00000000000006e0
[    2.480306] Stack:
[    2.482312]  ffffb36043133e38 ffffffffbef8d543 ffffb36043133e38 ffffffffbe34689b
[    2.489729]  000000007f4214f8 ffffb36043133e48 ffffffffbef8ce79 ffffb36043133ec0
[    2.497144]  ffffffffbe002190 0000000000000000 0000000000000000 ffffffffbed42f50
[    2.504561] Call Trace:
[    2.507005]  [<ffffffffbef8d543>] save_microcode_in_initrd_amd+0x31/0x106
[    2.513778]  [<ffffffffbe34689b>] ? debugfs_create_u64+0x2b/0x30
[    2.519769]  [<ffffffffbef8ce79>] save_microcode_in_initrd+0x3c/0x45
[    2.526110]  [<ffffffffbe002190>] do_one_initcall+0x50/0x180
[    2.531756]  [<ffffffffbef7a8cd>] ? set_debug_rodata+0x12/0x12
[    2.537573]  [<ffffffffbef7b17b>] kernel_init_freeable+0x194/0x230
[    2.543740]  [<ffffffffbe7f3430>] ? rest_init+0x80/0x80
[    2.548952]  [<ffffffffbe7f343e>] kernel_init+0xe/0x100
[    2.554164]  [<ffffffffbe800c55>] ret_from_fork+0x25/0x30
[    2.559548] Code: 48 89 f8 72 28 48 2b 05 7b a0 dc 00 48 05 00 00 00 80 48 39 c7 72 14 0f b6 0d 6a 75 ee 00 48 89 c2 48 d3 ea 48 85 d2 75 02 5d c3 <0f> 0b 48 03 05 7b 5b da 00 48 81 ff ff ff ff 3f 76 ec 0f 0b 0f 
[    2.579022] RIP  [<ffffffffbe06848c>] __phys_addr+0x3c/0x50
[    2.584590]  RSP <ffffb36043133e10>
[    2.588117] ---[ end trace 5c9b40c31651bd33 ]---
[    2.592745] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
[    2.592745] 
[    2.601900] ---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b

Regards,

Bob Peterson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
