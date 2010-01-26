Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B34C36003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 12:59:16 -0500 (EST)
Date: Tue, 26 Jan 2010 19:55:33 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 00 of 31] Transparent Hugepage support #7
Message-ID: <20100126175532.GA3359@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <patchbomb.1264513915@v2.random>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

So I applied this patchset (got it here:
http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.33-rc5/transparent_hugepage-7/)
on top of 2.6.33-rc5 and got this on boot:

[   16.484060] BUG: unable to handle kernel paging request at ffffea0002df0738
[   16.485027] IP: [<ffffffff810ec0ac>] khugepaged+0x381/0xb3d
[   16.485027] PGD 2080067 PUD 2081067 PMD 0 
[   16.485027] Oops: 0000 [#1] PREEMPT SMP 
[   16.485027] last sysfs file: /sys/class/firmware/timeout
[   16.485027] CPU 1 
[   16.485027] Pid: 580, comm: khugepaged Not tainted 2.6.33-rc5-aa #38 2241B48/2241B48
[   16.485027] RIP: 0010:[<ffffffff810ec0ac>]  [<ffffffff810ec0ac>] khugepaged+0x381/0xb3d
[   16.485027] RSP: 0000:ffff88007aefde10  EFLAGS: 00010282
[   16.485027] RAX: ffffea0002df0738 RBX: 0000000000000dc0 RCX: ffff880079e71480
[   16.485027] RDX: ffffea0000000000 RSI: 0000000000000001 RDI: ffff880079e72000
[   16.485027] RBP: ffff88007aefdee0 R08: 0000000000000200 R09: ffff88007c379100
[   16.485027] R10: 0000000000000020 R11: 0000000000000020 R12: 0000000000000018
[   16.485027] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[   16.485027] FS:  0000000000000000(0000) GS:ffff880001e80000(0000) knlGS:0000000000000000
[   16.485027] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   16.485027] CR2: ffffea0002df0738 CR3: 0000000001a08000 CR4: 00000000000006e0
[   16.485027] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   16.485027] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   16.485027] Process khugepaged (pid: 580, threadinfo ffff88007aefc000, task ffff88007aef43e0)
[   16.485027] Stack:
[   16.485027]  ffff88007aefdee0 0000200000002000 0000042200000001 ffff88007abe4d10
[   16.485027] <0> ffff880079e489c0 ffff880079ece000 ffff880079e48a20 00000000f7000000
[   16.485027] <0> ffff88007aefc000 0000000000013cc0 ffff880079e48a38 ffff88007c3a16a0
[   16.485027] Call Trace:
[   16.485027]  [<ffffffff8105cc98>] ? autoremove_wake_function+0x0/0x38
[   16.485027]  [<ffffffff815e2fa3>] ? _raw_spin_unlock_irqrestore+0x25/0x30
[   16.485027]  [<ffffffff810ebd2b>] ? khugepaged+0x0/0xb3d
[   16.485027]  [<ffffffff8105c7c2>] kthread+0x7d/0x85
[   16.485027]  [<ffffffff81003894>] kernel_thread_helper+0x4/0x10
[   16.485027]  [<ffffffff8105c745>] ? kthread+0x0/0x85
[   16.485027]  [<ffffffff81003890>] ? kernel_thread_helper+0x0/0x10
[   16.485027] Code: 20 ba 01 00 00 00 0f 45 f2 48 ba 00 f0 ff ff ff 3f 00 00 48 21 d0 48 ba 00 00 00 00 00 ea ff ff 48 c1 e8 0c 48 6b c0 38 48 01 d0 <48> 8b 10 f6 c2 20 0f 84 b6 04 00 00 f6 c2 01 0f 85 ad 04 00 00 
[   16.485027] RIP  [<ffffffff810ec0ac>] khugepaged+0x381/0xb3d
[   16.485027]  RSP <ffff88007aefde10>
[   16.485027] CR2: ffffea0002df0738
[   16.485027] ---[ end trace d42a4bb81928b65f ]---


addr2line tells me it is here:
mm/huge_memory.o khugepaged + 0x381 = 0xbcc
/scm/linux-2.6/mm/huge_memory.c:1543
constant_test_bit():
/scm/linux-2.6/arch/x86/include/asm/bitops.h:311
     bcc:       48 8b 10                mov    (%rax),%rdx

and code looks like this:

1536         for (_pte = pte; _pte < pte+HPAGE_PMD_NR; _pte++) {
1537                 pte_t pteval = *_pte;
1538                 barrier(); /* read from memory */
1539                 if (!pte_present(pteval) || !pte_write(pteval))
1540                         goto out_unmap;
1541                 if (pte_young(pteval))
1542                         referenced = 1;
1543                 page = pte_page(pteval);
1544                 VM_BUG_ON(PageCompound(page));
1545                 if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
1546                         goto out_unmap;
1547                 /* cannot use mapcount: can't collapse if there's a gup pin */
1548                 if (page_count(page) != 1)
1549                         goto out_unmap;
1550         }

Got to go, hope this helps.
-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
