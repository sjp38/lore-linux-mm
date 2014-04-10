Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f176.google.com (mail-ve0-f176.google.com [209.85.128.176])
	by kanga.kvack.org (Postfix) with ESMTP id 53D556B0031
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 04:45:59 -0400 (EDT)
Received: by mail-ve0-f176.google.com with SMTP id db11so3075355veb.7
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 01:45:58 -0700 (PDT)
Received: from mail-ve0-x229.google.com (mail-ve0-x229.google.com [2607:f8b0:400c:c01::229])
        by mx.google.com with ESMTPS id iy9si588352vec.33.2014.04.10.01.45.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 01:45:58 -0700 (PDT)
Received: by mail-ve0-f169.google.com with SMTP id pa12so3271917veb.28
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 01:45:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53440991.9090001@oracle.com>
References: <53440991.9090001@oracle.com>
Date: Thu, 10 Apr 2014 16:45:58 +0800
Message-ID: <CAA_GA1d_boVA67EBK5Rv7_F_8pb_5rBA10WB9ooCdjON93C03w@mail.gmail.com>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1829!
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Apr 8, 2014 at 10:37 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
> Hi all,
>
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel, I've stumbled on the following:
>

Wow! There are so many huge memory related bugs recently.
AFAIR, there were still several without fix. I wanna is there any
place can track those bugs instead of lost in maillist?
It seems this link is out of date
http://codemonkey.org.uk/projects/trinity/bugs-unfixed.php

Thanks,
-Bob

> [ 1275.253114] kernel BUG at mm/huge_memory.c:1829!
> [ 1275.253642] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 1275.254775] Dumping ftrace buffer:
> [ 1275.255631]    (ftrace buffer empty)
> [ 1275.256440] Modules linked in:
> [ 1275.257347] CPU: 20 PID: 22807 Comm: trinity-c299 Not tainted 3.14.0-next-20140407-sasha-00023-gd35b0d6 #382
> [ 1275.258686] task: ffff8803e7873000 ti: ffff8803e7896000 task.ti: ffff8803e7896000
> [ 1275.259416] RIP: __split_huge_page (mm/huge_memory.c:1829 (discriminator 1))
> [ 1275.260527] RSP: 0018:ffff8803e7897bb8  EFLAGS: 00010297
> [ 1275.261323] RAX: 000000000000012c RBX: ffff8803e789d600 RCX: 0000000000000006
> [ 1275.261323] RDX: 0000000000005b80 RSI: ffff8803e7873d00 RDI: 0000000000000282
> [ 1275.261323] RBP: ffff8803e7897c68 R08: 0000000000000000 R09: 0000000000000000
> [ 1275.261323] R10: 0000000000000001 R11: 30303320746e756f R12: 0000000000000000
> [ 1275.261323] R13: 0000000000a00000 R14: ffff8803ede73000 R15: ffffea0010030000
> [ 1275.261323] FS:  00007f899d23f700(0000) GS:ffff880437000000(0000) knlGS:0000000000000000
> [ 1275.261323] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 1275.261323] CR2: 00000000024cf048 CR3: 00000003e787f000 CR4: 00000000000006a0
> [ 1275.261323] DR0: 0000000000696000 DR1: 0000000000696000 DR2: 0000000000000000
> [ 1275.261323] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> [ 1275.261323] Stack:
> [ 1275.261323]  ffff8803e7897bd8 ffff880024dab898 ffff8803e7897bd8 ffffffffac1bea0e
> [ 1275.261323]  ffff8803e7897c28 0000000000000282 00000014b06cc072 0000000000000000
> [ 1275.261323]  0000012be7897c28 0000000000000a00 ffff880024dab8d0 ffff880024dab898
> [ 1275.261323] Call Trace:
> [ 1275.261323] ? put_lock_stats.isra.12 (arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
> [ 1275.261323] ? down_write (kernel/locking/rwsem.c:51 (discriminator 2))
> [ 1275.261323] ? split_huge_page_to_list (mm/huge_memory.c:1874)
> [ 1275.261323] split_huge_page_to_list (include/linux/vmstat.h:37 mm/huge_memory.c:1879)
> [ 1275.261323] __split_huge_page_pmd (mm/huge_memory.c:2811)
> [ 1275.261323] ? mutex_unlock (kernel/locking/mutex.c:220)
> [ 1275.261323] ? __mutex_unlock_slowpath (arch/x86/include/asm/paravirt.h:809 kernel/locking/mutex.c:713 kernel/locking/mutex.c:722)
> [ 1275.261323] ? get_parent_ip (kernel/sched/core.c:2471)
> [ 1275.261323] ? preempt_count_sub (kernel/sched/core.c:2526)
> [ 1275.261323] follow_page_mask (mm/memory.c:1518 (discriminator 1))
> [ 1275.261323] SYSC_move_pages (mm/migrate.c:1227 mm/migrate.c:1353 mm/migrate.c:1508)
> [ 1275.261323] ? SYSC_move_pages (include/linux/rcupdate.h:800 mm/migrate.c:1472)
> [ 1275.261323] ? sched_clock_local (kernel/sched/clock.c:213)
> [ 1275.261323] SyS_move_pages (mm/migrate.c:1456)
> [ 1275.261323] tracesys (arch/x86/kernel/entry_64.S:749)
> [ 1275.261323] Code: c0 01 39 45 94 74 18 41 8b 57 18 48 c7 c7 90 5e 6d b0 31 c0 8b 75 94 83 c2 01 e8 3d 6a 23 03 41 8b 47 18 83 c0 01 39 45 94 74 02 <0f> 0b 49 8b 07 48 89 c2 48 c1 e8 34 83 e0 03 48 c1 ea 36 4c 8d
> [ 1275.261323] RIP __split_huge_page (mm/huge_memory.c:1829 (discriminator 1))
> [ 1275.261323]  RSP <ffff8803e7897bb8>
>
> Looking at the code, there was supposed to be a printk printing both
> mapcounts if they're different. However, there was no matching entry
> in the log for that.
>
>
> Thanks,
> Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
