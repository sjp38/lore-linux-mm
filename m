Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C21CD6B4FE1
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 02:26:54 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s14-v6so6737628ioc.0
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 23:26:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d199-v6sor342242itb.66.2018.08.29.23.26.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 23:26:53 -0700 (PDT)
Subject: Re: mmotm 2018-08-23-17-26 uploaded
References: <20180824002731.XMNCl%akpm@linux-foundation.org>
 <049c3fa9-f888-6a2d-413b-872992b269f9@gmail.com>
 <20180829162213.fa1c7c54c801a036e64bacd2@linux-foundation.org>
 <7ae81ca1-46ca-af47-8260-c52736aa4453@gmail.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <cf4acbb6-2815-56e2-829c-4e4c3a549e21@gmail.com>
Date: Thu, 30 Aug 2018 14:26:51 +0800
MIME-Version: 1.0
In-Reply-To: <7ae81ca1-46ca-af47-8260-c52736aa4453@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org

Hi Andrew

On 8/30/2018 9:00 AM, Jia He Wrote:
> 
> 
> On 8/30/2018 7:22 AM, Andrew Morton Wrote:
>> On Tue, 28 Aug 2018 12:20:46 +0800 Jia He <hejianet@gmail.com> wrote:
>>
>>> Hi Andrew
>>> FYI,I watched a lockdep warning based on your mmotm master branch[1]
>>
>> Thanks.  We'll need help from ARM peeps on this please.
>>
>>> [    6.692731] ------------[ cut here ]------------
>>> [    6.696391] DEBUG_LOCKS_WARN_ON(!current->hardirqs_enabled)
>>> [    6.696404] WARNING: CPU: 3 PID: 320 at kernel/locking/lockdep.c:3845
>>> check_flags.part.38+0x9c/0x16c
>>> [    6.711082] Modules linked in:
>>> [    6.714101] CPU: 3 PID: 320 Comm: modprobe Not tainted 4.18.0-rc4-mm1+ #56
>>> [    6.720956] Hardware name: WIWYNN HXT REP-1 System H001-00001-0/HXT REP-1
>>> CRB, BIOS 0ACJA530 03/20/2018
>>> [    6.730332] pstate: 60400085 (nZCv daIf +PAN -UAO)
>>> [    6.735106] pc : check_flags.part.38+0x9c/0x16c
>>> [    6.739619] lr : check_flags.part.38+0x9c/0x16c
>>> [    6.744133] sp : ffff80178536fbf0
>>> [    6.747432] x29: ffff80178536fbf0 x28: ffff8017905a1b00
>>> [    6.752727] x27: 0000000000000002 x26: 0000000000000000
>>> [    6.758022] x25: ffff000008abeb14 x24: 0000000000000000
>>> [    6.763317] x23: 0000000000000001 x22: 0000000000000001
>>> [    6.768612] x21: 0000000000000001 x20: 0000000000000000
>>> [    6.773908] x19: ffff00000a041000 x18: 0000000000000000
>>> [    6.779202] x17: 0000000000000000 x16: 0000000000000000
>>> [    6.784498] x15: 0000000000000000 x14: 0000000000000000
>>> [    6.789793] x13: ffff000008d6b190 x12: 752ce9eb60de3f00
>>> [    6.795088] x11: ffff80178536f7f0 x10: ffff80178536f7f0
>>> [    6.800383] x9 : 00000000ffffffd0 x8 : 0000000000000000
>>> [    6.805678] x7 : ffff00000816fe48 x6 : ffff801794ba62b8
>>> [    6.810973] x5 : 0000000000000000 x4 : 0000000000000000
>>> [    6.816269] x3 : ffffffffffffffff x2 : ffff0000091ed988
>>> [    6.821564] x1 : 752ce9eb60de3f00 x0 : 752ce9eb60de3f00
>>> [    6.826859] Call trace:
>>> [    6.829290]  check_flags.part.38+0x9c/0x16c
>>> [    6.833457]  lock_acquire+0x12c/0x280
>>> [    6.837104]  down_read_trylock+0x78/0x98
>>> [    6.841011]  do_page_fault+0x150/0x480
>>> [    6.844742]  do_translation_fault+0x74/0x80
>>> [    6.848909]  do_mem_abort+0x60/0x108
>>> [    6.852467]  el0_da+0x24/0x28
>>> [    6.855418] irq event stamp: 250
>>> [    6.858633] hardirqs last  enabled at (249): [<ffff00000830e518>]
>>> mem_cgroup_commit_charge+0x9c/0x13c
>>> [    6.867833] hardirqs last disabled at (250): [<ffff000008095f40>]
>>> el0_svc_handler+0xc4/0x16c
>>> [    6.876252] softirqs last  enabled at (242): [<ffff000008081c48>]
>>> __do_softirq+0x2f8/0x554
>>> [    6.884501] softirqs last disabled at (229): [<ffff0000080f1bec>]
>>> irq_exit+0x180/0x194
>>> [    6.892399] ---[ end trace b45768f94a7b7d9f ]---
>>> [    6.896998] possible reason: unannotated irqs-on.
>>> [    6.901685] irq event stamp: 250
>>> [    6.904898] hardirqs last  enabled at (249): [<ffff00000830e518>]
>>> mem_cgroup_commit_charge+0x9c/0x13c
>>> [    6.914100] hardirqs last disabled at (250): [<ffff000008095f40>]
>>> el0_svc_handler+0xc4/0x16c
>>> [    6.922519] softirqs last  enabled at (242): [<ffff000008081c48>]
>>> __do_softirq+0x2f8/0x554
>>> [    6.930766] softirqs last disabled at (229): [<ffff0000080f1bec>]
>>> irq_exit+0x180/0x194
>>> [    7.023827] Initialise system trusted keyrings
>>> [    7.027414] workingset: timestamp_bits=45 max_order=25 bucket_order=0
>>
>> Lockdep says current->hardirqs_enabled is false and that is indeed an
>> error.  arch/arm64/kernel/entry.S:el0_da does enable_daif which might
>> be an attempt to enable hardirqs, but how does that get propagated into
>> lockdep's ->hardirqs_enabled?  By calling
>> local_irq_enable()->trace_hardirqs_on(), but that's C, not assembler.
>>
>> And what changed to cause this?
>>
>> I dunno anything.  Help!
>>
>>> I thought the root cause might be at [2] which seems not in your branch yet.
>>>
>>> [1] http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git
>>> [2]
>>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit?id=efd112
>>
>> I agree, that doesn't look like the culprit.  But something may well
>> have gone wrong in "the recent conversion of the syscall entry/exit
>> code to C".
> Sorry for my unclearly previously description.
> 1. no such lockdep warning in latest mainline kernel git tree.
> 2. there is a 100% producible warning based on your latest mmotm tree
> 3. after applying the commit efd112 based on your mmotm tree, the warning
> disappearred
> 
> I will do some further digging to answer your question if no other experts' help
> 
1. in el0_svc->el0_svc_common, without commit efd112
		local_daif_mask();   //disable the irq and trace irq off
		flags = current_thread_info()->flags;
		if (!has_syscall_work(flags))
			------------    //1
			return;
If el0_svc_common enters the logic at line 1, the irq is disabled and
current->hardirqs_enabled is 0.

2. then it goes to el0_da
in el0_da, it enables the irq without changing current->hardirqs_enabled to 1

3. goes to el0_da->do_mem_abort->... the lockdep warning happens

The commit efd112 fixes it by invoking trace_hardirqs_off at line 1.
It closes the inconsistency window.

Cheers,
Jia

-- 
Cheers,
Jia
