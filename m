Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFB86B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 17:36:36 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so108207276pdb.1
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 14:36:35 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id co1si642862pad.63.2015.03.27.14.36.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 14:36:33 -0700 (PDT)
Message-ID: <5515CD4C.1050806@oracle.com>
Date: Fri, 27 Mar 2015 17:36:12 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: lru_add_drain_all hangs
References: <5514CF37.1020403@oracle.com> <55152BED.9050500@suse.cz>
In-Reply-To: <55152BED.9050500@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On 03/27/2015 06:07 AM, Vlastimil Babka wrote:
>> [ 3614.918852] trinity-c7      D ffff8802f4487b58 26976 16252   9410 0x10000000
>> > [ 3614.919580]  ffff8802f4487b58 ffff8802f6b98ca8 0000000000000000 0000000000000000
>> > [ 3614.920435]  ffff88017d3e0558 ffff88017d3e0530 ffff8802f6b98008 ffff88016bad0000
>> > [ 3614.921219]  ffff8802f6b98000 ffff8802f4487b38 ffff8802f4480000 ffffed005e890002
>> > [ 3614.922069] Call Trace:
>> > [ 3614.922346] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
>> > [ 3614.923023] schedule_preempt_disabled (kernel/sched/core.c:2859)
>> > [ 3614.923707] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
>> > [ 3614.924486] ? lru_add_drain_all (mm/swap.c:867)
>> > [ 3614.925211] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
>> > [ 3614.925970] ? lru_add_drain_all (mm/swap.c:867)
>> > [ 3614.926692] ? mutex_trylock (kernel/locking/mutex.c:621)
>> > [ 3614.927464] ? mpol_new (mm/mempolicy.c:285)
>> > [ 3614.928044] lru_add_drain_all (mm/swap.c:867)
>> > [ 3614.928608] migrate_prep (mm/migrate.c:64)
>> > [ 3614.929092] SYSC_mbind (mm/mempolicy.c:1188 mm/mempolicy.c:1319)
>> > [ 3614.929619] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
>> > [ 3614.930318] ? __mpol_equal (mm/mempolicy.c:1304)
>> > [ 3614.930877] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
>> > [ 3614.931485] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
>> > [ 3614.932184] SyS_mbind (mm/mempolicy.c:1301)
> That looks like trinity-c7 is waiting ot in too, but later on (after some more
> listings like this for trinity-c7, probably threads?) we have:
> 

It keeps changing constantly, even in this trace the process is blocking on the mutex
rather than doing something useful, and in the next trace it's a different process.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
