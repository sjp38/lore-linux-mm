Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 51DDA6B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 12:45:14 -0400 (EDT)
Message-ID: <5216400D.8060903@intel.com>
Date: Thu, 22 Aug 2013 09:45:01 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [BUG REPORT]kernel panic with kmemcheck config
References: <5212D7F2.3020308@huawei.com> <521381A9.4020501@intel.com> <521429D5.8070003@huawei.com> <5214461D.9000009@intel.com> <52158C49.2040009@huawei.com>
In-Reply-To: <52158C49.2040009@huawei.com>
Content-Type: text/plain; charset=gb18030
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Libin <huawei.libin@huawei.com>
Cc: Vegard Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, guohanjun@huawei.com, zhangdianfang@huawei.com

On 08/21/2013 08:58 PM, Libin wrote:
> I test it on IBM System x3850 X5 platform, and also trigger oops in boot
> process. But if don't config the kmemcheck, it can boot up normally.
> Hardware information and oops information as following:
> 
> [    0.205976] BUG: unable to handle kernel paging request at 000000103f8ae420
> [    0.249553] IP: [<000000007e372522>] 0x7e372521
> [    0.278328] PGD 1e90067 PUD 406ff91067 PMD 406fd94067 PTE 800000103f8ae962
> [    0.321462] Oops: 0000 [#1] SMP
> [    0.342366] Modules linked in:
> [    0.362173] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.11.0-rc6-kmemcheck #3
> [    0.406711] Hardware name: IBM System x3850 X5 -[7143O3G]-/Node 1, Processor Card, BIOS -[G0E171AUS-1.71]- 09/23/2011
> [    0.473627] task: ffffffff81a11420 ti: ffffffff81a00000 task.ti: ffffffff81a00000
> [    0.521570] RIP: 0010:[<000000007e372522>]  [<000000007e372522>] 0x7e372521
> [    0.565103] RSP: 0000:ffffffff81a01e18  EFLAGS: 00010002
> [    0.598574] RAX: 000000007eb6ce18 RBX: 000000007eb6cda0 RCX: 000000103f8ae400
> [    0.643109] RDX: 000000007e371b78 RSI: 000000007e372290 RDI: 0000000060000202
> [    0.687644] RBP: ffffffff81a01f78 R08: 0000000000000000 R09: 0000000000000015
> [    0.732182] R10: 0000000000000030 R11: 8000000000000000 R12: 000077ff80000000
> [    0.776720] R13: 0000000000000030 R14: ffff8810bf8ae400 R15: 0000000000000015
> [    0.821258] FS:  0000000000000000(0000) GS:ffff88103fc00000(0000) knlGS:0000000000000000
> [    0.872889] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.908993] CR2: ffff88103f886d70 CR3: 0000000001a0c000 CR4: 00000000000006b0
> [    0.953528] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [    0.998064] DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
> [    1.042598] Stack:
> [    1.056043]  000000007e371a9f 0000000000000030 ffff8810bf8ae400 0000000000000015
> [    1.103638]  ffffffff81a01e48 ffffffff815112d9 000000007e372604 ffffffff8150daf2
> [    1.151236]  0000000000000015 ffff8810bf8ae400 0000000000000030 0000000000000001
> [    1.198824] Call Trace:
> [    1.214912]  [<ffffffff815112d9>] ? do_page_fault+0x9/0x10
> [    1.249439]  [<ffffffff8150daf2>] ? page_fault+0x22/0x30
> [    1.282913]  [<ffffffff81049b46>] ? efi_call4+0x46/0x80
> [    1.315859]  [<ffffffff81b0add8>] ? efi_enter_virtual_mode+0x105/0x3f2
> [    1.356711]  [<ffffffff81af0128>] start_kernel+0x39f/0x430
> [    1.391235]  [<ffffffff81aefb7b>] ? repair_env_string+0x58/0x58
> [    1.428397]  [<ffffffff81aef4d8>] x86_64_start_reservations+0x1b/0x35
> [    1.468721]  [<ffffffff81aef652>] x86_64_start_kernel+0x160/0x167
> [    1.506934] Code:  Bad RIP value.
> [    1.528367] RIP  [<000000007e372522>] 0x7e372521
> [    1.557667]  RSP <ffffffff81a01e18>
> [    1.580072] CR2: 000000103f8ae420
> [    1.601429] ---[ end trace 26e748e9242ceebc ]---
> [    1.630684] Kernel panic - not syncing: Attempted to kill the idle task!

Isn't that a completely different oops from your first one?

In any case, I booted your exact config on my 8-node system.  It didn't
trigger for me.  Being so far down in the sysfs code, I don't have any
great recommendations for how to debug it.  What I said earlier stands I
guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
