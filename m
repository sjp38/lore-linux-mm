Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 459846B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 15:46:23 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so3759821pdi.2
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 12:46:22 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id my2si4975360pbc.283.2014.04.04.12.46.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 04 Apr 2014 12:46:22 -0700 (PDT)
Message-ID: <533F09F0.1050206@oracle.com>
Date: Fri, 04 Apr 2014 15:37:20 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in do_huge_pmd_wp_page
References: <51559150.3040407@oracle.com> <515D882E.6040001@oracle.com>
In-Reply-To: <515D882E.6040001@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

And another ping exactly a year later :)

Yes, this is still happening in -next:

[  370.615914] BUG: unable to handle kernel paging request at ffff880768c72000
[  370.620246] IP: copy_page (arch/x86/lib/copy_page_64.S:34)
[  370.620246] PGD 1091c067 PUD 102c5e6067 PMD 102c49f067 PTE 8000000768c72060
[  370.620246] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  370.620246] Dumping ftrace buffer:
[  370.620246]    (ftrace buffer empty)
[  370.620246] Modules linked in:
[  370.620246] CPU: 18 PID: 9480 Comm: trinity-c149 Not tainted 3.14.0-next-20140403-sasha-00019-g7474aa9 #375
[  370.620246] task: ffff8805e92c0000 ti: ffff8805e92c8000 task.ti: ffff8805e92c8000
[  370.620246] RIP: copy_page (arch/x86/lib/copy_page_64.S:34)
[  370.620246] RSP: 0000:ffff8805e92c9c20  EFLAGS: 00010206
[  370.620246] RAX: 0000000000000002 RBX: fffffffff6040000 RCX: 000000000000003a
[  370.620246] RDX: ffff8805e92c0000 RSI: ffff880768c72000 RDI: ffff8804e9c72000
[  370.620246] RBP: ffff8805e92c9c78 R08: 000000000000004a R09: 0a0074656e0a0018
[  370.620246] R10: 0000000000000001 R11: 0000000000000000 R12: 000000001da31c80
[  370.620246] R13: ffff880000000000 R14: 000000001da38000 R15: ffffea001da30000
[  370.620246] FS:  00007f65d8d9e700(0000) GS:ffff8804ecc00000(0000) knlGS:0000000000000000
[  370.620246] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  370.620246] CR2: ffff880768c72000 CR3: 00000005e92a1000 CR4: 00000000000006a0
[  370.620246] Stack:
[  370.620246]  fffffffff6040000 000000001da31c80 ffffffff892ae6de 0000000000000200
[  370.620246]  ffff8805e92a3028 0000000000a00000 ffffea001da30000 ffffea0013a70000
[  370.620246]  ffff8805e92a3028 0000000000a00000 ffff8805e929a000 ffff8805e92c9d28
[  370.620246] Call Trace:
[  370.620246] ? copy_user_huge_page (include/linux/uaccess.h:36 (discriminator 2) include/linux/highmem.h:75 (discriminator 2) include/linux/highmem.h:232 (discriminator 2) mm/memory.c:4398 (discriminator 2))
[  370.620246] do_huge_pmd_wp_page (arch/x86/include/asm/bitops.h:95 include/linux/page-flags.h:301 mm/huge_memory.c:1122)
[  370.620246] ? kvm_clock_read (arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
[  370.620246] ? sched_clock_local (kernel/sched/clock.c:214)
[  370.620246] ? get_parent_ip (kernel/sched/core.c:2472)
[  370.620246] __handle_mm_fault (mm/memory.c:3877)
[  370.620246] ? __const_udelay (arch/x86/lib/delay.c:126)
[  370.620246] handle_mm_fault (include/linux/memcontrol.h:148 mm/memory.c:3935)
[  370.620246] __do_page_fault (arch/x86/mm/fault.c:1220)
[  370.620246] ? vtime_account_user (kernel/sched/cputime.c:687)
[  370.620246] ? get_parent_ip (kernel/sched/core.c:2472)
[  370.620246] ? context_tracking_user_exit (include/linux/vtime.h:89 include/linux/jump_label.h:105 include/trace/events/context_tracking.h:47 kernel/context_tracking.c:178)
[  370.620246] ? preempt_count_sub (kernel/sched/core.c:2527)
[  370.620246] ? context_tracking_user_exit (kernel/context_tracking.c:182)
[  370.620246] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  370.620246] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2638 (discriminator 2))
[  370.620246] do_page_fault (arch/x86/mm/fault.c:1272 include/linux/jump_label.h:105 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1273)
[  370.620246] do_async_page_fault (arch/x86/kernel/kvm.c:263)
[  370.620246] async_page_fault (arch/x86/kernel/entry_64.S:1496)
[  370.620246] Code: c3 0f 1f 80 00 00 00 00 48 83 ec 10 48 89 1c 24 4c 89 64 24 08 b9 3b 00 00 00 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 ff c9 <48> 8b 06 48 8b 5e 08 48 8b 56 10 4c 8b 46 18 4c 8b 4e 20 4c 8b
[  370.620246] RIP copy_page (arch/x86/lib/copy_page_64.S:34)
[  370.620246]  RSP <ffff8805e92c9c20>
[  370.620246] CR2: ffff880768c72000


Thanks,
Sasha

On 04/04/2013 10:03 AM, Sasha Levin wrote:
> Ping? I'm seeing a whole bunch of these with current -next.
> 
> 
> Thanks,
> Sasha
> 
> On 03/29/2013 09:04 AM, Sasha Levin wrote:
>> Hi all,
>>
>> While fuzzing with trinity inside a KVM tools guest running latest -next kernel,
>> I've stumbled on the following.
>>
>> It seems that the code in do_huge_pmd_wp_page() was recently modified in
>> "thp: do_huge_pmd_wp_page(): handle huge zero page".
>>
>> Here's the trace:
>>
>> [  246.244708] BUG: unable to handle kernel paging request at ffff88009c422000
>> [  246.245743] IP: [<ffffffff81a0a795>] copy_page_rep+0x5/0x10
>> [  246.250569] PGD 7232067 PUD 7235067 PMD bfefe067 PTE 800000009c422060
>> [  246.251529] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>> [  246.252325] Dumping ftrace buffer:
>> [  246.252791]    (ftrace buffer empty)
>> [  246.252869] Modules linked in:
>> [  246.252869] CPU 3
>> [  246.252869] Pid: 11985, comm: trinity-child12 Tainted: G        W    3.9.0-rc4-next-20130328-sasha-00014-g91a3267 #319
>> [  246.252869] RIP: 0010:[<ffffffff81a0a795>]  [<ffffffff81a0a795>] copy_page_rep+0x5/0x10
>> [  246.252869] RSP: 0018:ffff88000015bc40  EFLAGS: 00010286
>> [  246.252869] RAX: ffff88000015bfd8 RBX: 0000000002710880 RCX: 0000000000000200
>> [  246.252869] RDX: 0000000000000000 RSI: ffff88009c422000 RDI: ffff88009a422000
>> [  246.252869] RBP: ffff88000015bc98 R08: 0000000002718000 R09: 0000000000000001
>> [  246.252869] R10: 0000000000000001 R11: 0000000000000000 R12: ffff880000000000
>> [  246.252869] R13: ffff88000015bfd8 R14: ffff88000015bfd8 R15: fffffffffff80000
>> [  246.252869] FS:  00007f53db93f700(0000) GS:ffff8800bba00000(0000) knlGS:0000000000000000
>> [  246.252869] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [  246.252869] CR2: ffff88009c422000 CR3: 0000000000159000 CR4: 00000000000406e0
>> [  246.252869] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [  246.252869] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> [  246.252869] Process trinity-child12 (pid: 11985, threadinfo ffff88000015a000, task ffff88009c60b000)
>> [  246.252869] Stack:
>> [  246.252869]  ffffffff81234aae ffff88000015bc88 ffffffff81273639 0000000000a00000
>> [  246.252869]  0000000002718000 ffff8800ab36d050 ffff880000153800 ffffea0002690000
>> [  246.252869]  0000000000a00000 ffff8800ab36d000 ffffea0002710000 ffff88000015bd48
>> [  246.252869] Call Trace:
>> [  246.252869]  [<ffffffff81234aae>] ? copy_user_huge_page+0x1de/0x240
>> [  246.252869]  [<ffffffff81273639>] ? mem_cgroup_charge_common+0xa9/0xc0
>> [  246.252869]  [<ffffffff8126b4d7>] do_huge_pmd_wp_page+0x9f7/0xc60
>> [  246.252869]  [<ffffffff81a0acd9>] ? __const_udelay+0x29/0x30
>> [  246.252869]  [<ffffffff8123364e>] handle_mm_fault+0x26e/0x650
>> [  246.252869]  [<ffffffff8117dc1a>] ? __lock_is_held+0x5a/0x80
>> [  246.252869]  [<ffffffff83db3814>] ? __do_page_fault+0x514/0x5e0
>> [  246.252869]  [<ffffffff83db3870>] __do_page_fault+0x570/0x5e0
>> [  246.252869]  [<ffffffff811c6500>] ? rcu_eqs_exit_common+0x60/0x260
>> [  246.252869]  [<ffffffff811c740e>] ? rcu_eqs_enter_common+0x33e/0x3b0
>> [  246.252869]  [<ffffffff811c679c>] ? rcu_eqs_exit+0x9c/0xb0
>> [  246.252869]  [<ffffffff83db3912>] do_page_fault+0x32/0x50
>> [  246.252869]  [<ffffffff83db2ef0>] do_async_page_fault+0x30/0xc0
>> [  246.252869]  [<ffffffff83db01e8>] async_page_fault+0x28/0x30
>> [  246.252869] Code: 90 90 90 90 90 90 9c fa 65 48 3b 06 75 14 65 48 3b 56 08 75 0d 65 48 89 1e 65 48 89 4e 08 9d b0 01 c3 9d 30
>> c0 c3 b9 00 02 00 00 <f3> 48 a5 c3 0f 1f 80 00 00 00 00 eb ee 66 66 66 90 66 66 66 90
>> [  246.252869] RIP  [<ffffffff81a0a795>] copy_page_rep+0x5/0x10
>> [  246.252869]  RSP <ffff88000015bc40>
>> [  246.252869] CR2: ffff88009c422000
>> [  246.252869] ---[ end trace 09fbe37b108d5766 ]---
>>
>> And this is the code:
>>
>>         if (is_huge_zero_pmd(orig_pmd))
>>                 clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
>>         else
>>                 copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR); <--- this
>>
>>
>> Thanks,
>> Sasha
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
