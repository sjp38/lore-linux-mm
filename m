Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D75956B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 10:57:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so1784566wmz.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 07:57:49 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id ay2si7516073wjc.89.2016.07.27.07.57.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 07:57:48 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o80so6873211wme.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 07:57:48 -0700 (PDT)
Date: Wed, 27 Jul 2016 16:57:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PowerPC] Kernel OOPS while compiling LTP test suite on linus
 mainline
Message-ID: <20160727145746.GA21891@dhcp22.suse.cz>
References: <2a9abff6-7820-a95b-0de3-8e6723707cb6@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2a9abff6-7820-a95b-0de3-8e6723707cb6@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au, linux-mm@kvack.org

[CC linux-mm]

On Wed 27-07-16 16:45:35, Abdul Haleem wrote:
> Hi,
> 
> Kernel OOPS messages were seen while compiling linux test project (LTP) source on 4.7.0-rc5 mainline.
> 
> Kernel config : pseries_le_defconfig
> Machine Type  : PowerVM LPAR
> Machine hardware : LPAR uses 16 vCPUs, and 29G memory
> 
> trace messages:
> *15:34:57* [  862.548866] Unable to handle kernel paging request for data at address 0x00000000
> *15:34:57* [  862.548904] Faulting instruction address: 0xc000000000260900
> *15:34:57* [  862.548911] Oops: Kernel access of bad area, sig: 11 [#1]
> *15:34:57* [  862.548917] SMP NR_CPUS=2048 NUMA pSeries
> *15:34:57* [  862.548924] Modules linked in: rtc_generic(E) pseries_rng(E) autofs4(E)
> *15:34:57* [  862.548938] CPU: 0 PID: 129 Comm: kswapd2 Tainted: G            E   4.7.0-rc5-autotest #1
> *15:34:57* [  862.548946] task: c0000007766a2600 ti: c000000776764000 task.ti: c000000776764000
> *15:34:57* [  862.548953] NIP: c000000000260900 LR: c00000000026452c CTR: 0000000000000000
> *15:34:57* [  862.548961] REGS: c000000776767830 TRAP: 0300   Tainted: G            E    (4.7.0-rc5-autotest)
> *15:34:57* [  862.548968] MSR: 800000010280b033 <SF,VEC,VSX,EE,FP,ME,IR,DR,RI,LE,TM[E]>  CR: 24000222  XER: 20000001
> *15:34:57* [  862.548996] CFAR: c000000000008468 DAR: 0000000000000000 DSISR: 40000000 SOFTE: 0
> *15:34:57* GPR00: c00000000026452c c000000776767ab0 c0000000013ac100 c00000077ff54200
> *15:34:57* GPR04: 0000000000000000 c000000776767ba0 0000000000000001 c00000000151c100
> *15:34:57* GPR08: 0000000000000000 00000000000b4057 0000000080000000 c00000071664b7a0
> *15:34:57* GPR12: 0000000000000000 c00000000e800000 0000000000000001 f0000000015dc000
> *15:34:57* GPR16: c00000077ff54700 0000000000000000 0000000000000000 c00000077ff54700
> *15:34:57* GPR20: 0000000000000001 0000000000000100 0000000000000200 c00000077ff54200
> *15:34:57* GPR24: c000000776767ba0 0000000000000020 0000000000000000 0000000000000001
> *15:34:57* GPR28: 0000000000000010 0000000000000000 c000000776767ba0 f0000000015dc020
> *15:34:57* [  862.549094] NIP [c000000000260900] move_active_pages_to_lru.isra.16+0xa0/0x380
> *15:34:57* [  862.549102] LR [c00000000026452c] shrink_active_list+0x2fc/0x510

Could you map this to the kernel source line please?

> *15:34:57* [  862.549108] Call Trace:
> *15:34:57* [  862.549112] [c000000776767ab0] [f0000000015dc000] 0xf0000000015dc000 (unreliable)
> *15:34:57* [  862.549122] [c000000776767b60] [c00000000026452c] shrink_active_list+0x2fc/0x510
> *15:34:57* [  862.549131] [c000000776767c50] [c0000000002665d4] kswapd+0x434/0xa70
> *15:34:57* [  862.549139] [c000000776767d80] [c0000000000f1b50] kthread+0x110/0x130
> *15:34:57* [  862.549148] [c000000776767e30] [c0000000000095f0] ret_from_kernel_thread+0x5c/0x6c
> *15:34:57* [  862.549155] Instruction dump:
> *15:34:57* [  862.549161] 60000000 3b200020 3a800001 7b7c26e4 3aa00100 3ac00200 3a400000 3a770500
> *15:34:57* [  862.549174] 3a200000 60000000 60000000 60420000 <e93d0000> 7fbd4840 419e01b8 ebfd0008
> *15:34:57* [  862.549193] ---[ end trace fcc50906d9164c56 ]---
> *15:34:57* [  862.550562]
> *15:35:18* [  883.551577] INFO: rcu_sched self-detected stall on CPU
> *15:35:18* [  883.551578] INFO: rcu_sched self-detected stall on CPU
> *15:35:18* [  883.551588] 	2-...: (5249 ticks this GP) idle=cc5/140000000000001/0 softirq=50260/50260 fqs=5249
> *15:35:18* [  883.551591] 	 (t=5250 jiffies g=48365 c=48364 q=182)
> 
> Regard's
> Abdul

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
